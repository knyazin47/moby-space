// Package grpcapi is a native protobuf transport over the shared typed
// application. It never creates HTTP requests, JSON payloads, or HTTP handlers.
package grpcapi

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"net"
	"strconv"
	"strings"
	"sync"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	pb "moby.local/family/gen/moby/family/v1"
	"moby.local/family/internal/api"
)

const MaxRequestBytes = 8192
const MaxSnapshotBytes = 2 << 20

type Options struct {
	Heartbeat, SendTimeout, ReauthInterval        time.Duration
	MaxWatches, MaxSessionWatches, MaxPeerWatches int
}
type Service struct {
	pb.UnimplementedFamilyServiceServer
	store           *api.Server
	options         Options
	mu              sync.Mutex
	total           int
	sessions, peers map[string]int
	projections     chan struct{}
}
type tokenKey struct{}

func NewService(store *api.Server, options Options) *Service {
	if options.Heartbeat <= 0 {
		options.Heartbeat = 10 * time.Second
	}
	if options.SendTimeout <= 0 {
		options.SendTimeout = 10 * time.Second
	}
	if options.ReauthInterval <= 0 {
		options.ReauthInterval = time.Second
	}
	if options.MaxWatches <= 0 {
		options.MaxWatches = 6
	}
	if options.MaxSessionWatches <= 0 {
		options.MaxSessionWatches = 2
	}
	if options.MaxPeerWatches <= 0 {
		options.MaxPeerWatches = 6
	}
	return &Service{store: store, options: options, sessions: map[string]int{}, peers: map[string]int{}, projections: make(chan struct{}, 8)}
}
func NewServer(store *api.Server, options Options) *grpc.Server {
	s := NewService(store, options)
	server := grpc.NewServer(grpc.MaxRecvMsgSize(MaxRequestBytes), grpc.MaxSendMsgSize(MaxSnapshotBytes), grpc.MaxHeaderListSize(4096), grpc.MaxConcurrentStreams(32), grpc.StatsHandler(s), grpc.ChainUnaryInterceptor(s.UnaryInterceptor), grpc.ChainStreamInterceptor(s.StreamInterceptor))
	pb.RegisterFamilyServiceServer(server, s)
	return server
}
func credential(ctx context.Context) string { v, _ := ctx.Value(tokenKey{}).(string); return v }
func peerIP(ctx context.Context) string {
	if p, ok := peer.FromContext(ctx); ok {
		host, _, e := net.SplitHostPort(p.Addr.String())
		if e == nil {
			return host
		}
		return p.Addr.String()
	}
	return "unknown"
}
func failure(ctx context.Context, e *api.DomainError) error {
	if e == nil {
		return nil
	}
	code := codes.Internal
	switch e.Status {
	case 400, 422:
		code = codes.InvalidArgument
	case 401:
		code = codes.Unauthenticated
	case 403:
		code = codes.PermissionDenied
	case 404:
		code = codes.NotFound
	case 409, 410:
		code = codes.FailedPrecondition
	case 429:
		code = codes.ResourceExhausted
	case 499:
		code = codes.Canceled
	case 503:
		code = codes.Unavailable
	}
	_ = grpc.SetTrailer(ctx, metadata.Pairs("moby-error-code", e.Code, "moby-semantic-status", strconv.Itoa(e.Status)))
	st := status.New(code, e.Code)
	if detailed, err := st.WithDetails(&pb.DomainErrorDetail{SemanticStatus: int32(e.Status), Code: e.Code}); err == nil {
		st = detailed
	}
	return st.Err()
}
func invalid(ctx context.Context, code string) error {
	return failure(ctx, &api.DomainError{Status: 400, Code: code})
}
func finish[T, P any](ctx context.Context, r api.Result[T], e *api.DomainError, mapper func(T) P) (P, error) {
	if e != nil {
		var zero P
		return zero, failure(ctx, e)
	}
	if snap, ok := any(r.Value).(api.Snapshot); ok && snapshotEstimate(snap) > MaxSnapshotBytes {
		var zero P
		return zero, failure(ctx, &api.DomainError{Status: 503, Code: "snapshot_limit"})
	}
	return mapper(r.Value), nil
}
func (s *Service) authorize(ctx context.Context, method string) (context.Context, error) {
	name := method[strings.LastIndex(method, "/")+1:]

	class := "children"
	max := 240
	public := false
	switch name {
	case "LoginAdult":
		class = "auth"
		max = 12
		public = true
	case "Logout":
		class = "auth"
	case "CreatePairing":
		class = "pairing_create"
		max = 20
		public = true
	case "ConsumePairing":
		class = "pairing_consume"
		max = 20
	case "PollPairing":
		class = "pairing_poll"
		public = true
	case "CancelPairing":
		class = "pairing_cancel"
		public = true
	case "GetSnapshot":
		class = "snapshot"
	case "WatchSnapshots":
		class = "events"
	case "CompleteFamilyIntro":
		class = "preferences"
	case "ListSessions", "RevokeSession":
		class = "sessions"
	case "DecideOperation":
		class = "operations"
	case "ExecuteFamilySpaceCommand":
		class = "family-space"
	}

	if !s.store.AllowTransportRequest(peerIP(ctx), class, max) {
		return ctx, failure(ctx, &api.DomainError{Status: 429, Code: "rate_limited"})
	}
	if public {
		return context.WithValue(ctx, tokenKey{}, ""), nil
	}
	md, _ := metadata.FromIncomingContext(ctx)
	values := md.Get("authorization")
	if len(values) != 1 || !strings.HasPrefix(values[0], "Bearer ") {
		return ctx, failure(ctx, &api.DomainError{Status: 401, Code: "unauthorized"})
	}
	token := strings.TrimPrefix(values[0], "Bearer ")
	if e := s.store.Authorize(token); e != nil {
		return ctx, failure(ctx, e)
	}
	return context.WithValue(ctx, tokenKey{}, token), nil
}
func (s *Service) UnaryInterceptor(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (response any, err error) {
	defer func() {
		if recover() != nil {
			response = nil
			err = failure(ctx, &api.DomainError{Status: 500, Code: "internal_error"})
		}
	}()
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	ctx, err = s.authorize(ctx, info.FullMethod)
	if err != nil {
		return nil, err
	}
	if msg, ok := req.(proto.Message); !ok || hasUnknown(msg.ProtoReflect()) {
		return nil, invalid(ctx, "invalid_body")
	}
	if err := s.admitProjection(ctx); err != nil {
		return nil, err
	}
	return handler(ctx, req)
}

type streamContext struct {
	grpc.ServerStream
	ctx context.Context
}

func (s streamContext) Context() context.Context { return s.ctx }
func (s *Service) StreamInterceptor(server any, stream grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
	ctx, e := s.authorize(stream.Context(), info.FullMethod)
	if e != nil {
		return e
	}
	if err := s.admitProjection(ctx); err != nil {
		return err
	}
	return handler(server, streamContext{ServerStream: stream, ctx: ctx})
}
func hasUnknown(m protoreflect.Message) bool {
	if len(m.GetUnknown()) != 0 {
		return true
	}
	bad := false
	m.Range(func(fd protoreflect.FieldDescriptor, v protoreflect.Value) bool {
		if fd.IsMap() {
			if fd.MapValue().Kind() == protoreflect.MessageKind {
				v.Map().Range(func(_ protoreflect.MapKey, x protoreflect.Value) bool { bad = hasUnknown(x.Message()); return !bad })
			}
		} else if fd.IsList() {
			if fd.Kind() == protoreflect.MessageKind {
				l := v.List()
				for i := 0; i < l.Len(); i++ {
					if hasUnknown(l.Get(i).Message()) {
						bad = true
						break
					}
				}
			}
		} else if fd.Kind() == protoreflect.MessageKind {
			bad = hasUnknown(v.Message())
		}
		return !bad
	})
	return bad
}

func (s *Service) WatchSnapshots(request *pb.Empty, stream grpc.ServerStreamingServer[pb.Snapshot]) error {
	ctx := stream.Context()
	if hasUnknown(request.ProtoReflect()) {
		return invalid(ctx, "invalid_body")
	}
	token := credential(ctx)
	sum := sha256.Sum256([]byte(token))
	sessionKey := hex.EncodeToString(sum[:])
	ip := peerIP(ctx)
	s.mu.Lock()
	if s.total >= s.options.MaxWatches || s.sessions[sessionKey] >= s.options.MaxSessionWatches || s.peers[ip] >= s.options.MaxPeerWatches {
		s.mu.Unlock()
		return failure(ctx, &api.DomainError{Status: 429, Code: "watch_limit"})
	}
	s.total++
	s.sessions[sessionKey]++
	s.peers[ip]++
	s.mu.Unlock()
	defer func() {
		s.mu.Lock()
		defer s.mu.Unlock()
		s.total--
		s.sessions[sessionKey]--
		s.peers[ip]--
		if s.sessions[sessionKey] == 0 {
			delete(s.sessions, sessionKey)
		}
		if s.peers[ip] == 0 {
			delete(s.peers, ip)
		}
	}()
	heartbeat := time.NewTicker(s.options.Heartbeat)
	defer heartbeat.Stop()
	reauth := time.NewTicker(s.options.ReauthInterval)
	defer reauth.Stop()
	for {
		snap, changed, e := s.store.SubscribeSnapshot(ctx, token)
		if e != nil {
			return failure(ctx, e)
		}
		if snapshotEstimate(snap) > MaxSnapshotBytes {
			return failure(ctx, &api.DomainError{Status: 503, Code: "snapshot_limit"})
		}
		message := mapSnapshot(snap)
		if proto.Size(message) > MaxSnapshotBytes {
			return failure(ctx, &api.DomainError{Status: 503, Code: "snapshot_limit"})
		}
		// Exactly one Send goroutine may exist per bounded watch. Returning the RPC
		// closes its transport context, which unblocks a flow-controlled Send. No
		// transaction mutex is held and intermediate snapshots are coalesced.
		sent := make(chan error, 1)
		go func() { sent <- stream.Send(message) }()
		timer := time.NewTimer(s.options.SendTimeout)
		dirty := false
		waiting := true
		for waiting {
			select {
			case err := <-sent:
				if !timer.Stop() {
					select {
					case <-timer.C:
					default:
					}
				}
				if err != nil {
					return err
				}
				waiting = false
			case <-ctx.Done():
				timer.Stop()
				return status.FromContextError(ctx.Err()).Err()
			case <-timer.C:
				return failure(ctx, &api.DomainError{Status: 429, Code: "slow_consumer"})
			case <-changed:
				_, next, err := s.store.SubscribeSnapshot(ctx, token)
				if err != nil {
					timer.Stop()
					return failure(ctx, err)
				}
				changed = next
				dirty = true
			case <-reauth.C:
				if err := s.store.Authorize(token); err != nil {
					timer.Stop()
					return failure(ctx, err)
				}
			}
		}
		if dirty {
			continue
		}
		waiting = true
		for waiting {
			select {
			case <-ctx.Done():
				return status.FromContextError(ctx.Err()).Err()
			case <-changed:
				waiting = false
			case <-heartbeat.C:
				waiting = false
			case <-reauth.C:
				if e := s.store.Authorize(token); e != nil {
					return failure(ctx, e)
				}
			}
		}
	}
}
