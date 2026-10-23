package grpcapi

import (
	"context"
	"google.golang.org/grpc/stats"
	"moby.local/family/internal/api"
	"reflect"
	"strings"
	"sync"
)

// Eight 2MiB leases bound retained wire projections to 16MiB. A lease is
// acquired before taking a scoped snapshot or mapping a mutation result, and
// released by gRPC End only after the RPC/send lifecycle ends. Watches hold
// their lease throughout their lifetime; six watches leave two unary slots.
const ProjectionBudgetBytes = 8 * MaxSnapshotBytes

type projectionKey struct{}
type projectionLease struct {
	once     sync.Once
	acquired bool
}

func (s *Service) TagRPC(ctx context.Context, info *stats.RPCTagInfo) context.Context {
	switch info.FullMethodName[strings.LastIndex(info.FullMethodName, "/")+1:] {
	case "GetSnapshot", "WatchSnapshots", "CompleteFamilyIntro", "ExecuteFamilySpaceCommand":
		return context.WithValue(ctx, projectionKey{}, &projectionLease{})
	}
	return ctx
}
func (s *Service) HandleRPC(ctx context.Context, event stats.RPCStats) {
	if _, ok := event.(*stats.End); !ok {
		return
	}
	if lease, ok := ctx.Value(projectionKey{}).(*projectionLease); ok {
		lease.once.Do(func() {
			if lease.acquired {
				<-s.projections
			}
		})
	}
}
func (s *Service) TagConn(ctx context.Context, _ *stats.ConnTagInfo) context.Context { return ctx }
func (s *Service) HandleConn(context.Context, stats.ConnStats)                       {}
func (s *Service) admitProjection(ctx context.Context) error {
	lease, ok := ctx.Value(projectionKey{}).(*projectionLease)
	if !ok {
		return nil
	}
	select {
	case s.projections <- struct{}{}:
		lease.acquired = true
		return nil
	default:
		return failure(ctx, &api.DomainError{Status: 429, Code: "snapshot_busy"})
	}
}

// A conservative allocation-free upper bound is checked BEFORE protobuf
// mapping/marshalling. Every scalar/field/map entry is charged more than its
// possible protobuf wire overhead; large source snapshots stop the walk early.
func snapshotEstimate(s api.Snapshot) int64 { return estimateValue(reflect.ValueOf(s)) }
func estimateValue(v reflect.Value) int64 {
	if !v.IsValid() {
		return 0
	}
	switch v.Kind() {
	case reflect.Pointer, reflect.Interface:
		if v.IsNil() {
			return 0
		}
		return estimateValue(v.Elem()) + 8
	case reflect.String:
		return int64(v.Len()) + 16
	case reflect.Struct:
		var n int64 = 32
		for i := 0; i < v.NumField(); i++ {
			if v.Type().Field(i).Tag.Get("json") == "-" {
				continue
			}
			n += estimateValue(v.Field(i)) + 8
			if n > MaxSnapshotBytes {
				return n
			}
		}
		return n
	case reflect.Slice, reflect.Array:
		var n int64 = 16
		for i := 0; i < v.Len(); i++ {
			n += estimateValue(v.Index(i)) + 8
			if n > MaxSnapshotBytes {
				return n
			}
		}
		return n
	case reflect.Map:
		var n int64 = 16
		iter := v.MapRange()
		for iter.Next() {
			n += estimateValue(iter.Key()) + estimateValue(iter.Value()) + 16
			if n > MaxSnapshotBytes {
				return n
			}
		}
		return n
	default:
		return 16
	}
}
