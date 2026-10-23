package grpcapi

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/encoding/protojson"
	pb "moby.local/family/gen/moby/family/v1"
	"moby.local/family/internal/api"
)

const bootstrap = "native-synthetic-test-bootstrap-32-characters"

type rpcFixture struct {
	t          *testing.T
	store      *api.Server
	server     *grpc.Server
	service    *Service
	listener   net.Listener
	connection *grpc.ClientConn
	client     pb.FamilyServiceClient
	rest       *httptest.Server
	cfg        api.Config
	adult      string
}

func newRPCFixture(t *testing.T, options Options, interceptor grpc.UnaryServerInterceptor) *rpcFixture {
	t.Helper()
	f := &rpcFixture{t: t, cfg: api.Config{DatabasePath: filepath.Join(t.TempDir(), "family.sqlite"), BootstrapSecret: bootstrap}}
	f.start(options, interceptor)
	t.Cleanup(f.close)
	r, e := f.client.LoginAdult(context.Background(), &pb.LoginAdultRequest{BootstrapSecret: ptr(bootstrap), DeviceName: ptr("adult")})
	if e != nil {
		t.Fatal(e)
	}
	f.adult = r.GetToken()
	return f
}
func (f *rpcFixture) start(options Options, extra grpc.UnaryServerInterceptor) {
	f.t.Helper()
	var e error
	f.store, e = api.New(f.cfg)
	if e != nil {
		f.t.Fatal(e)
	}
	f.service = NewService(f.store, options)
	chain := []grpc.UnaryServerInterceptor{f.service.UnaryInterceptor}
	if extra != nil {
		chain = append(chain, extra)
	}
	f.server = grpc.NewServer(grpc.MaxRecvMsgSize(MaxRequestBytes), grpc.MaxSendMsgSize(MaxSnapshotBytes), grpc.MaxHeaderListSize(4096), grpc.MaxConcurrentStreams(32), grpc.StatsHandler(f.service), grpc.ChainUnaryInterceptor(chain...), grpc.ChainStreamInterceptor(f.service.StreamInterceptor))
	pb.RegisterFamilyServiceServer(f.server, f.service)
	f.listener, e = net.Listen("tcp", "127.0.0.1:0")
	if e != nil {
		f.t.Fatal(e)
	}
	go f.server.Serve(f.listener)
	f.connection, e = grpc.NewClient("passthrough:///"+f.listener.Addr().String(), grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithDefaultCallOptions(grpc.MaxCallRecvMsgSize(MaxSnapshotBytes)))
	if e != nil {
		f.t.Fatal(e)
	}
	f.client = pb.NewFamilyServiceClient(f.connection)
	f.rest = httptest.NewServer(f.store)
}
func (f *rpcFixture) close() {
	f.connection.Close()
	f.server.Stop()
	f.listener.Close()
	f.rest.Close()
	f.store.Close()
}
func (f *rpcFixture) auth(token string) context.Context {
	f.t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	f.t.Cleanup(cancel)
	return metadata.AppendToOutgoingContext(ctx, "authorization", "Bearer "+token)
}
func (f *rpcFixture) restCall(method, path, token string, body any) (int, map[string]any) {
	f.t.Helper()
	raw, _ := json.Marshal(body)
	r, _ := http.NewRequest(method, f.rest.URL+path, bytes.NewReader(raw))
	r.Header.Set("Authorization", "Bearer "+token)
	response, e := f.rest.Client().Do(r)
	if e != nil {
		f.t.Fatal(e)
	}
	defer response.Body.Close()
	data, _ := io.ReadAll(response.Body)
	var v map[string]any
	if e = json.Unmarshal(data, &v); e != nil {
		f.t.Fatal(e)
	}
	return response.StatusCode, v
}
func (f *rpcFixture) child(name string) (string, string, string) {
	f.t.Helper()
	c, e := f.client.CreateChild(f.auth(f.adult), &pb.CreateChildRequest{DisplayName: ptr(name), LegalName: ptr("Synthetic " + name), DateOfBirth: ptr("2015-01-02"), IdempotencyKey: ptr("create-" + name)})
	if e != nil {
		f.t.Fatal(e)
	}
	p, e := f.client.CreatePairing(context.Background(), &pb.CreatePairingRequest{DeviceName: ptr(name)})
	if e != nil {
		f.t.Fatal(e)
	}
	_, e = f.client.ConsumePairing(f.auth(f.adult), &pb.ConsumePairingRequest{Code: p.Code, ChildId: c.Id})
	if e != nil {
		f.t.Fatal(e)
	}
	grant, e := f.client.PollPairing(context.Background(), &pb.PairingSecretRequest{PairingId: p.Id, RequestSecret: p.RequestSecret})
	if e != nil {
		f.t.Fatal(e)
	}
	repeat, e := f.client.PollPairing(context.Background(), &pb.PairingSecretRequest{PairingId: p.Id, RequestSecret: p.RequestSecret})
	if e != nil || repeat.Session.GetToken() != grant.Session.GetToken() {
		f.t.Fatal("pairing retry changed session")
	}
	_, e = f.client.VerifyChild(f.auth(f.adult), &pb.VerifyChildRequest{ChildId: c.Id, Outcome: ptr("verified")})
	if e != nil {
		f.t.Fatal(e)
	}
	_, e = f.client.OpenProduct(f.auth(f.adult), &pb.OpenProductRequest{ChildId: c.Id, AgreementVersion: ptr("synthetic-v1"), SignerConsent: ptr(true)})
	if e != nil {
		f.t.Fatal(e)
	}
	return c.GetId(), grant.Session.GetToken(), grant.Session.Actor.GetSessionId()
}
func expectDomain(t *testing.T, e error, code codes.Code, semantic int32, domain string) {
	t.Helper()
	if status.Code(e) != code {
		t.Fatalf("got%v want%v", e, code)
	}
	found := false
	for _, d := range status.Convert(e).Details() {
		if detail, ok := d.(*pb.DomainErrorDetail); ok {
			found = true
			if detail.SemanticStatus != semantic || detail.Code != domain {
				t.Fatalf("wrong domain detail %+v", detail)
			}
		}
	}
	if !found {
		t.Fatal("typed domain details missing")
	}
}
func recvSnapshot(t *testing.T, w grpc.ServerStreamingClient[pb.Snapshot], revision int64, child, hidden string) *pb.Snapshot {
	t.Helper()
	s, e := w.Recv()
	if e != nil {
		t.Fatal(e)
	}
	if s.Revision == nil || s.GetRevision() != revision {
		t.Fatalf("stream revision got%d want%d", s.GetRevision(), revision)
	}
	if child != "" {
		if len(s.Children) != 1 || s.Children[0].GetId() != child || s.FamilySpace.AdultWallet != nil || s.Preferences != nil {
			t.Fatal("child snapshot scope")
		}
		raw, _ := protojson.Marshal(s)
		if strings.Contains(string(raw), hidden) {
			t.Fatal("sibling leaked")
		}
	}
	return s
}

func TestNativeGRPCThreeClientsOwnershipStreamingAndRevocation(t *testing.T) {
	f := newRPCFixture(t, Options{}, nil)
	a, ta, sa := f.child("A")
	b, tb, _ := f.child("B")
	_, e := f.client.GetSnapshot(context.Background(), &pb.Empty{})
	expectDomain(t, e, codes.Unauthenticated, 401, "unauthorized")
	_, e = f.client.GetChild(f.auth(ta), &pb.ChildRef{ChildId: ptr(b)})
	expectDomain(t, e, codes.PermissionDenied, 403, "forbidden")
	initial, e := f.client.GetSnapshot(f.auth(f.adult), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	pa, e := f.client.WatchSnapshots(f.auth(f.adult), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	ca, e := f.client.WatchSnapshots(f.auth(ta), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	cb, e := f.client.WatchSnapshots(f.auth(tb), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	recvSnapshot(t, pa, initial.GetRevision(), "", "")
	recvSnapshot(t, ca, initial.GetRevision(), a, b)
	recvSnapshot(t, cb, initial.GetRevision(), b, a)
	result, e := f.client.ExecuteFamilySpaceCommand(f.auth(f.adult), &pb.SpaceCommand{Type: ptr("wallet.transfer"), ChildId: ptr(a), AmountMinor: ptr(int64(1000)), IdempotencyKey: ptr("native-transfer-a")})
	if e != nil {
		t.Fatal(e)
	}
	revision := result.GetRevision()
	adult := recvSnapshot(t, pa, revision, "", "")
	own := recvSnapshot(t, ca, revision, a, b)
	sibling := recvSnapshot(t, cb, revision, b, a)
	if adult.FamilySpace.AdultWallet.GetAvailableMinor() != 99000 || own.Children[0].GetBalanceMinor() != 1000 || sibling.Children[0].GetBalanceMinor() != 0 {
		t.Fatal("live money not shared correctly")
	}
	_, e = f.client.ExecuteFamilySpaceCommand(f.auth(tb), &pb.SpaceCommand{Type: ptr("wallet.transfer"), ChildId: ptr(b), AmountMinor: ptr(int64(10)), IdempotencyKey: ptr("child-cannot-mint")})
	expectDomain(t, e, codes.PermissionDenied, 403, "forbidden")
	_, e = f.client.RevokeSession(f.auth(f.adult), &pb.SessionRef{SessionId: ptr(sa)})
	if e != nil {
		t.Fatal(e)
	}
	_, e = ca.Recv()
	expectDomain(t, e, codes.Unauthenticated, 401, "unauthorized")
	_, e = f.client.GetSnapshot(f.auth(ta), &pb.Empty{})
	expectDomain(t, e, codes.Unauthenticated, 401, "unauthorized")
	_, e = f.client.Logout(f.auth(tb), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	for i := 0; i < 4; i++ {
		_, e = cb.Recv()
		if e != nil {
			break
		}
	}
	expectDomain(t, e, codes.Unauthenticated, 401, "unauthorized")
	sessions, e := f.client.ListSessions(f.auth(f.adult), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	raw, _ := protojson.Marshal(sessions)
	if strings.Contains(string(raw), "token") || strings.Contains(string(raw), ta) || strings.Contains(string(raw), tb) {
		t.Fatal("session summary exposed credentials")
	}
}

func TestNativeGRPCCompatibilityFingerprintsAndEmptyCategoryRestart(t *testing.T) {
	f := newRPCFixture(t, Options{}, nil)
	a, ta, _ := f.child("Compat")
	body := map[string]any{"amountMinor": 1000, "currency": "BYN", "idempotencyKey": "compat-topup-1"}
	code, _ := f.restCall("POST", "/v1/children/"+a+"/topups", f.adult, body)
	if code != 201 {
		t.Fatal("legacy topup")
	}
	money := &pb.ChildMoneyRequest{ChildId: ptr(a), Input: &pb.MoneyInput{AmountMinor: ptr(int64(1000)), Currency: ptr("BYN"), IdempotencyKey: ptr("compat-topup-1")}}
	operation, e := f.client.TopUp(f.auth(f.adult), money)
	if e != nil {
		t.Fatal(e)
	}
	if operation.ProtoReflect().Descriptor().Fields().ByName("request_hash") != nil {
		t.Fatal("private operation field on wire")
	}
	money.Input.AmountMinor = ptr(int64(1001))
	_, e = f.client.TopUp(f.auth(f.adult), money)
	expectDomain(t, e, codes.FailedPrecondition, 409, "idempotency_conflict")
	_, snap := f.restCall("GET", "/v1/snapshot", ta, nil)
	if snap["children"].([]any)[0].(map[string]any)["balanceMinor"].(float64) != 1000 {
		t.Fatal("transport retry double paid")
	}
	policy := &pb.Policy{Categories: &pb.CategoryRules{Values: map[string]bool{}}, Payments: ptr(true), Transfers: ptr(false), Internet: ptr(false), DailyLimit: ptr(int64(10000)), MonthlyLimit: ptr(int64(40000)), ApprovalThreshold: ptr(int64(5000))}
	_, e = f.client.UpdatePolicy(f.auth(f.adult), &pb.UpdatePolicyRequest{ChildId: ptr(a), Policy: policy})
	if e != nil {
		t.Fatal(e)
	}
	purchase := &pb.ChildMoneyRequest{ChildId: ptr(a), Input: &pb.MoneyInput{AmountMinor: ptr(int64(100)), Currency: ptr("BYN"), Channel: ptr("pos"), Category: ptr("food"), IdempotencyKey: ptr("empty-categories-purchase")}}
	_, e = f.client.Purchase(f.auth(ta), purchase)
	expectDomain(t, e, codes.FailedPrecondition, 409, "category_disabled")
	f.close()
	f.start(Options{}, nil)
	current, e := f.client.GetSnapshot(f.auth(ta), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	if current.Children[0].Policy.Categories == nil || len(current.Children[0].Policy.Categories.Values) != 0 || current.Children[0].Policy.GetTransfers() {
		t.Fatal("empty or false policy lost after restart")
	}
	_, e = f.client.Purchase(f.auth(ta), purchase)
	expectDomain(t, e, codes.FailedPrecondition, 409, "category_disabled")
	policy.Categories = nil
	_, e = f.client.UpdatePolicy(f.auth(f.adult), &pb.UpdatePolicyRequest{ChildId: ptr(a), Policy: policy})
	if e != nil {
		t.Fatal(e)
	}
	_, e = f.client.Purchase(f.auth(ta), purchase)
	expectDomain(t, e, codes.FailedPrecondition, 409, "category_disabled")
	_, e = f.client.DecideOperation(f.auth(f.adult), &pb.DecideOperationRequest{OperationId: operation.Id})
	expectDomain(t, e, codes.InvalidArgument, 400, "decision_required")
	_, e = f.client.ExecuteFamilySpaceCommand(f.auth(ta), &pb.SpaceCommand{Type: ptr("lesson.complete"), ChildId: ptr(a), EntityId: ptr("needs-wants"), IdempotencyKey: ptr("missing-answer-presence")})
	expectDomain(t, e, codes.InvalidArgument, 400, "invalid_answer")
}

func TestNativeGRPCLostAcknowledgementKeepsFrozenIntent(t *testing.T) {
	committed := make(chan struct{})
	var delayed atomic.Bool
	delay := func(ctx context.Context, req any, info *grpc.UnaryServerInfo, next grpc.UnaryHandler) (any, error) {
		v, e := next(ctx, req)
		if command, ok := req.(*pb.SpaceCommand); ok && command.GetIdempotencyKey() == "lost-native-response" && e == nil && delayed.CompareAndSwap(false, true) {
			close(committed)
			<-ctx.Done()
			return nil, status.FromContextError(ctx.Err()).Err()
		}
		return v, e
	}
	f := newRPCFixture(t, Options{}, delay)
	a, ta, _ := f.child("Lost")
	ctx, cancel := context.WithCancel(metadata.AppendToOutgoingContext(context.Background(), "authorization", "Bearer "+f.adult))
	command := &pb.SpaceCommand{Type: ptr("wallet.transfer"), ChildId: ptr(a), AmountMinor: ptr(int64(500)), IdempotencyKey: ptr("lost-native-response")}
	done := make(chan error, 1)
	go func() { _, e := f.client.ExecuteFamilySpaceCommand(ctx, command); done <- e }()
	select {
	case <-committed:
	case <-time.After(3 * time.Second):
		t.Fatal("mutation never committed")
	}
	cancel()
	if e := <-done; status.Code(e) != codes.Canceled {
		t.Fatal("lost response not canceled")
	}
	result, e := f.client.ExecuteFamilySpaceCommand(f.auth(f.adult), command)
	if e != nil {
		t.Fatal(e)
	}
	if result.FamilySpace.AdultWallet.GetAvailableMinor() != 99500 || result.Children[0].GetBalanceMinor() != 500 {
		t.Fatal("lost acknowledgement replay double paid")
	}
	revision := result.GetRevision()
	code, legacy := f.restCall("POST", "/v1/family-space/commands", f.adult, map[string]any{"type": "wallet.transfer", "childId": a, "amountMinor": 500, "idempotencyKey": "lost-native-response"})
	if code != 200 || int64(legacy["revision"].(float64)) != revision {
		t.Fatal("native-to-REST replay mismatch")
	}
	snapshot, e := f.client.GetSnapshot(f.auth(ta), &pb.Empty{})
	if e != nil || snapshot.Children[0].GetBalanceMinor() != 500 {
		t.Fatal("child lost committed funds")
	}
}
func TestNativeGRPCSharedRateLimitsSizesAndWatchReclamation(t *testing.T) {
	f := newRPCFixture(t, Options{MaxWatches: 2, MaxPeerWatches: 2, MaxSessionWatches: 1}, nil)
	a, ta, _ := f.child("Limits")
	ctx, cancel := context.WithCancel(f.auth(ta))
	watch, e := f.client.WatchSnapshots(ctx, &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	if _, e = watch.Recv(); e != nil {
		t.Fatal(e)
	}
	second, e := f.client.WatchSnapshots(f.auth(ta), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	_, e = second.Recv()
	expectDomain(t, e, codes.ResourceExhausted, 429, "watch_limit")
	cancel()
	_, _ = watch.Recv()
	deadline := time.Now().Add(time.Second)
	for {
		f.service.mu.Lock()
		n := f.service.total
		f.service.mu.Unlock()
		if n == 0 {
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("canceled watch leaked admission")
		}
		time.Sleep(time.Millisecond)
	}
	// One shared IP auth budget spans both retained REST and native gRPC.
	for i := 0; i < 10; i++ {
		if _, e = f.client.LoginAdult(context.Background(), &pb.LoginAdultRequest{BootstrapSecret: ptr(bootstrap)}); e != nil {
			t.Fatal(e)
		}
	}
	code, _ := f.restCall("POST", "/v1/auth/adult", "", map[string]any{"bootstrapSecret": bootstrap})
	if code != 200 {
		t.Fatal("twelfth combined login rejected")
	}
	_, e = f.client.LoginAdult(context.Background(), &pb.LoginAdultRequest{BootstrapSecret: ptr(bootstrap)})
	expectDomain(t, e, codes.ResourceExhausted, 429, "rate_limited")
	_, e = f.client.CreateChild(f.auth(f.adult), &pb.CreateChildRequest{DisplayName: ptr(strings.Repeat("x", MaxRequestBytes+100)), DateOfBirth: ptr("2015-01-02")})
	if status.Code(e) != codes.ResourceExhausted {
		t.Fatal("oversized native input accepted", e)
	}
	unknown := &pb.Empty{}
	unknown.ProtoReflect().SetUnknown([]byte{0x08, 0x01})
	_, e = f.client.GetSnapshot(f.auth(ta), unknown)
	expectDomain(t, e, codes.InvalidArgument, 400, "invalid_body")
	_, e = f.client.ExecuteFamilySpaceCommand(f.auth(ta), &pb.SpaceCommand{Type: ptr("goal.move"), ChildId: ptr(a), EntityId: ptr("unknown"), IdempotencyKey: ptr("missing-money-presence")})
	expectDomain(t, e, codes.InvalidArgument, 400, "invalid_body")
}
func TestNativeGRPCProjectionBudgetRejectsBeforeMutation(t *testing.T) {
	f := newRPCFixture(t, Options{}, nil)
	a, _, _ := f.child("Budget")
	before, e := f.client.GetSnapshot(f.auth(f.adult), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	// Fill the real shared admission gate to model stalled concurrent projections.
	// This is transport instrumentation, never a domain/store mutation.
	for i := 0; i < 8; i++ {
		f.service.projections <- struct{}{}
	}
	if len(f.service.projections)*MaxSnapshotBytes != ProjectionBudgetBytes {
		t.Fatal("unbounded projection budget")
	}
	_, e = f.client.ExecuteFamilySpaceCommand(f.auth(f.adult), &pb.SpaceCommand{Type: ptr("wallet.transfer"), ChildId: ptr(a), AmountMinor: ptr(int64(100)), IdempotencyKey: ptr("budget-denied-transfer")})
	expectDomain(t, e, codes.ResourceExhausted, 429, "snapshot_busy")
	for i := 0; i < 8; i++ {
		<-f.service.projections
	}
	after, e := f.client.GetSnapshot(f.auth(f.adult), &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	if before.GetRevision() != after.GetRevision() || after.Children[0].GetBalanceMinor() != 0 {
		t.Fatal("projection denial committed money")
	}
	// The allocation-free estimator rejects a huge field before protobuf mapping.
	large := api.Snapshot{Children: []*api.Child{{DisplayName: strings.Repeat("x", MaxSnapshotBytes+1)}}}
	if snapshotEstimate(large) <= MaxSnapshotBytes {
		t.Fatal("oversized source projection not bounded")
	}
}
func TestNativeGRPCSlowConsumerBoundedAndDoesNotLockMoney(t *testing.T) {
	f := newRPCFixture(t, Options{Heartbeat: 10 * time.Millisecond, SendTimeout: 80 * time.Millisecond, MaxWatches: 1, MaxSessionWatches: 1, MaxPeerWatches: 1}, nil)
	// A full but valid synthetic family produces more than the stream receive
	// window. The client intentionally never calls Recv on its first watch.
	for i := 0; i < 100; i++ {
		_, e := f.client.CreateChild(f.auth(f.adult), &pb.CreateChildRequest{DisplayName: ptr(fmt.Sprintf("%03d%s", i, strings.Repeat("n", 97))), LegalName: ptr(strings.Repeat("l", 200)), DateOfBirth: ptr("2015-01-02"), IdempotencyKey: ptr(fmt.Sprintf("slow-child-%03d", i))})
		if e != nil {
			t.Fatal(e)
		}
	}
	ctx, cancel := context.WithCancel(f.auth(f.adult))
	defer cancel()
	_, e := f.client.WatchSnapshots(ctx, &pb.Empty{})
	if e != nil {
		t.Fatal(e)
	}
	deadline := time.Now().Add(2 * time.Second)
	sawWatch := false
	for {
		f.service.mu.Lock()
		n := f.service.total
		f.service.mu.Unlock()
		if n > 0 {
			sawWatch = true
		}
		if sawWatch && n == 0 {
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("slow consumer retained watch or never started")
		}
		time.Sleep(time.Millisecond)
	}
	result, e := f.client.GetSnapshot(f.auth(f.adult), &pb.Empty{})
	if e != nil || len(result.Children) != 100 {
		t.Fatal("slow consumer blocked independent store read", e)
	}
	deadline = time.Now().Add(time.Second)
	for len(f.service.projections) != 0 {
		if time.Now().After(deadline) {
			t.Fatal("slow consumer leaked projection lease")
		}
		time.Sleep(time.Millisecond)
	}
}

func TestNativeGRPCCriticalFalseZeroAndPolicyFingerprint(t *testing.T) {
	f := newRPCFixture(t, Options{}, nil)
	a, ta, _ := f.child("Presence")
	_, e := f.client.TopUp(f.auth(f.adult), &pb.ChildMoneyRequest{ChildId: ptr(a), Input: &pb.MoneyInput{AmountMinor: ptr(int64(10000)), Currency: ptr("BYN"), IdempotencyKey: ptr("presence-funding")}})
	if e != nil {
		t.Fatal(e)
	}
	pending, e := f.client.Purchase(f.auth(ta), &pb.ChildMoneyRequest{ChildId: ptr(a), Input: &pb.MoneyInput{AmountMinor: ptr(int64(6000)), Currency: ptr("BYN"), Category: ptr("food"), Channel: ptr("pos"), IdempotencyKey: ptr("presence-purchase")}})
	if e != nil || pending.GetStatus() != "pending" {
		t.Fatal("pending setup", e)
	}
	declined, e := f.client.DecideOperation(f.auth(f.adult), &pb.DecideOperationRequest{OperationId: pending.Id, Approve: ptr(false)})
	if e != nil || declined.GetStatus() != "declined" || declined.Decision == nil || declined.GetDecision() {
		t.Fatal("explicit false lost", e)
	}
	completed, e := f.client.ExecuteFamilySpaceCommand(f.auth(ta), &pb.SpaceCommand{Type: ptr("lesson.complete"), ChildId: ptr(a), EntityId: ptr("needs-wants"), AnswerIndex: ptr(int32(0)), IdempotencyKey: ptr("presence-answer-zero")})
	if e != nil || len(completed.FamilySpace.Learning) != 1 {
		t.Fatal("explicit answer zero lost", e)
	}
	policy := &pb.Policy{Payments: ptr(true), Transfers: ptr(true), Internet: ptr(false), DailyLimit: ptr(int64(10000)), MonthlyLimit: ptr(int64(40000)), ApprovalThreshold: ptr(int64(5000))}
	command := &pb.SpaceCommand{Type: ptr("request.create"), ChildId: ptr(a), Kind: ptr("policy"), Title: ptr("Rules"), Policy: policy, IdempotencyKey: ptr("presence-policy-key")}
	_, e = f.client.ExecuteFamilySpaceCommand(f.auth(ta), command)
	if e != nil {
		t.Fatal(e)
	}
	command.Policy.Categories = &pb.CategoryRules{Values: map[string]bool{}}
	_, e = f.client.ExecuteFamilySpaceCommand(f.auth(ta), command)
	expectDomain(t, e, codes.FailedPrecondition, 409, "idempotency_conflict")
	duplicate := metadata.AppendToOutgoingContext(f.auth(ta), "authorization", "Bearer "+ta)
	_, e = f.client.GetSnapshot(duplicate, &pb.Empty{})
	expectDomain(t, e, codes.Unauthenticated, 401, "unauthorized")
}

func TestNativeGRPCOversizedCommittedAcknowledgementIsAmbiguous(t *testing.T) {
	f := newRPCFixture(t, Options{}, nil)
	ctx := f.auth(f.adult)
	mapped := false
	// A domain mutation may already have committed before projection is rejected.
	// Its transport error must remain retryable and must not look like a terminal
	// 400/404/409 acknowledgement to the durable client outbox.
	large := api.Snapshot{Children: []*api.Child{{DisplayName: strings.Repeat("x", MaxSnapshotBytes+1)}}}
	_, e := finish(ctx, api.Result[api.Snapshot]{Value: large, Status: 200}, nil, func(s api.Snapshot) *pb.Snapshot { mapped = true; return mapSnapshot(s) })
	expectDomain(t, e, codes.Unavailable, 503, "snapshot_limit")
	if mapped {
		t.Fatal("oversized source was mapped before its bound was checked")
	}
}
