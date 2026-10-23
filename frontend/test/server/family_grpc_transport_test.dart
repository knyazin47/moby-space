import 'dart:async';
import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as any;

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/family_grpc_codec.dart';
import 'package:moby_demo/data/server/generated/moby/family/v1/family.pbgrpc.dart'
    as pb;
import 'package:moby_demo/data/server/money_intent.dart';

import '../support/space_fixture.dart';
import 'family_session_test.dart' show MemoryVault;
import 'grpc_test_support.dart';
import 'money_intent_test.dart' show MemoryIntentVault;

Matcher apiError(int status, String code) => isA<FamilyApiException>()
    .having((e) => e.status, 'status', status)
    .having((e) => e.code, 'code', code);

void main() {
  test(
    'typed protobuf roundtrip preserves int64, false and category presence',
    () {
      final source = grpcSnapshot();
      source.revision = Int64.parseInt('9007199254740993');
      final map = familySnapshotMap(source);
      expect(map['revision'], 9007199254740993);
      expect(
        (map['familySpace'] as JsonMap)['adultWallet']['reservedMinor'],
        12000,
      );
      expect(
        (map['familySpace']
            as JsonMap)['capabilities']['lessonsGrantPermissions'],
        false,
      );
      final omitted = familyMessage(pb.Policy(), {'payments': false});
      expect(omitted.hasCategories(), false);
      expect(omitted.hasPayments(), true);
      final explicit = familyMessage(pb.Policy(), {
        'categories': <String, dynamic>{},
      });
      expect(explicit.hasCategories(), true);
      expect(familyMessageMap(explicit)['categories'], isEmpty);
      final command = familyMessage(pb.SpaceCommand(), {
        'approve': false,
        'answerIndex': 0,
      });
      expect(command.hasApprove(), true);
      expect(command.hasAnswerIndex(), true);
      expect(command.approve, false);
      expect(command.answerIndex, 0);
      for (final invalid in [1.5, '100', true]) {
        expect(
          () => familyMessage(pb.MoneyInput(), {'amountMinor': invalid}),
          throwsA(apiError(400, 'invalid_request')),
        );
      }
      expect(
        () => familyMessage(pb.ChildPatch(), {'unknown': 'field'}),
        throwsA(apiError(400, 'invalid_request')),
      );
    },
  );

  test(
    'absent critical protobuf scalars are rejected rather than zero-filled',
    () {
      final variants = [
        grpcSnapshot()..clearRevision(),
        grpcSnapshot()..clearActor(),
        grpcSnapshot()..actor.clearId(),
        grpcSnapshot()..children.first.clearBalanceMinor(),
        grpcSnapshot()..familySpace.adultWallet.clearAvailableMinor(),
        grpcSnapshot()..familySpace.clearCapabilities(),
        grpcSnapshot()..familySpace.capabilities.clearSynthetic(),
        grpcSnapshot()..familySpace.capabilities.clearLessonsGrantPermissions(),
        grpcSnapshot()..familySpace.adultWallet.availableMinor = Int64(-1),
        grpcSnapshot()..familySpace.capabilities.maxAmountMinor = Int64.ZERO,
      ];
      for (final snapshot in variants) {
        expect(
          () => familySnapshotMap(snapshot),
          throwsA(apiError(502, 'invalid_snapshot')),
        );
      }
    },
  );

  test(
    'all facade routes invoke dedicated typed RPCs without an HTTP envelope',
    () async {
      final seen = <String>[];
      final inputs = <String, JsonMap>{};
      final snapshot = grpcSnapshot();
      final h = await GrpcHarness.start(
        ScriptFamilyService((method, call, request) async {
          seen.add(method);
          inputs[method] = familyMessageMap(request);
          switch (method) {
            case 'LoginAdult':
              return pb.SessionGrant(
                token: 'fixture-issued-token',
                actor: snapshot.actor,
              );
            case 'GetSnapshot' ||
                'CompleteFamilyIntro' ||
                'ExecuteFamilySpaceCommand':
              return snapshot;
            case 'ListChildren':
              return pb.ChildrenList(children: snapshot.children);
            case 'GetChild' ||
                'CreateChild' ||
                'UpdateChild' ||
                'UpdatePolicy' ||
                'ArchiveChild' ||
                'VerifyChild' ||
                'OpenProduct':
              return snapshot.children.first;
            case 'Purchase' || 'TopUp' || 'DecideOperation':
              return snapshot.operations.first;
            case 'CreatePairing':
              return pb.PairingCreated(
                id: 'pair',
                code: 'fixture-code',
                requestSecret: 'fixture-request-secret',
                expiresAt: Int64(123),
                status: 'waiting',
              );
            case 'PollPairing':
              return pb.PairingPoll(status: 'waiting');
            case 'ConsumePairing' || 'CancelPairing':
              return pb.PairingResult(id: 'pair', status: 'cancelled');
            case 'ListSessions':
              return pb.SessionsList(
                sessions: [
                  pb.SessionSummary(
                    id: 'session',
                    role: 'adult',
                    revoked: false,
                  ),
                ],
              );
            default:
              return pb.Empty();
          }
        }),
      );
      addTearDown(h.close);
      for (final (method, path, body) in <(String, String, JsonMap?)>[
        (
          'POST',
          '/v1/auth/adult',
          {'bootstrapSecret': 'fixture-bootstrap', 'deviceName': 'Fixture'},
        ),
        ('POST', '/v1/auth/logout', null),
        ('GET', '/v1/snapshot', null),
        ('POST', '/v1/preferences/family-intro/complete', {}),
        (
          'POST',
          '/v1/family-space/commands',
          {
            'type': 'request.decide',
            'childId': spaceJuniorId,
            'approve': false,
            'idempotencyKey': 'fixture-key',
          },
        ),
        ('GET', '/v1/children', null),
        (
          'POST',
          '/v1/children',
          {'displayName': 'Аня', 'idempotencyKey': 'fixture-key'},
        ),
        ('GET', '/v1/children/child-one', null),
        ('PATCH', '/v1/children/child-one', {'cardStatus': 'blocked'}),
        (
          'PATCH',
          '/v1/children/child-one/policy',
          {'payments': false, 'categories': <String, dynamic>{}},
        ),
        ('POST', '/v1/children/child-one/archive', null),
        (
          'POST',
          '/v1/children/child-one/verification',
          {'outcome': 'verified'},
        ),
        (
          'POST',
          '/v1/children/child-one/product',
          {'agreementVersion': 'fixture', 'signerConsent': false},
        ),
        (
          'POST',
          '/v1/children/child-one/operations',
          {'amountMinor': 100, 'currency': 'BYN'},
        ),
        (
          'POST',
          '/v1/children/child-one/topups',
          {'amountMinor': 200, 'currency': 'BYN'},
        ),
        ('POST', '/v1/operations/op-one/decision', {'approve': false}),
        ('POST', '/v1/pairings', {'deviceName': 'Fixture'}),
        (
          'POST',
          '/v1/pairings/consume',
          {'childId': 'child-one', 'code': 'fixture'},
        ),
        ('POST', '/v1/pairings/pair-one/poll', {'requestSecret': 'fixture'}),
        ('POST', '/v1/pairings/pair-one/cancel', {'requestSecret': 'fixture'}),
        ('GET', '/v1/sessions', null),
        ('POST', '/v1/sessions/session-one/revoke', null),
      ]) {
        await h.api.request(method, path, body);
      }
      expect(seen.toSet(), hasLength(22));
      expect(inputs['UpdateChild'], {
        'childId': 'child-one',
        'patch': {'cardStatus': 'blocked'},
      });
      expect(inputs['UpdatePolicy'], {
        'childId': 'child-one',
        'policy': {'payments': false, 'categories': {}},
      });
      expect(inputs['DecideOperation'], {
        'operationId': 'op-one',
        'approve': false,
      });
      expect(inputs['ExecuteFamilySpaceCommand']!['approve'], false);
      expect(inputs['Purchase']!['input']['amountMinor'], 100);
      expect(seen, isNot(contains('Request')));
    },
  );

  test(
    'unary and deferred stream retain the token captured at invocation',
    () async {
      final tokens = <String?>[];
      final h = await GrpcHarness.start(
        ScriptFamilyService(
          (_, call, _) async {
            tokens.add(call.clientMetadata?['authorization']);
            return grpcSnapshot();
          },
          watch: (call, _) async* {
            tokens.add(call.clientMetadata?['authorization']);
            yield grpcSnapshot();
          },
        ),
      );
      addTearDown(h.close);
      h.api.token = 'fixture-actor-a';
      final unary = h.api.request('GET', '/v1/snapshot');
      final watch = h.api.events();
      h.api.token = 'fixture-actor-b';
      await unary;
      await watch.first;
      expect(tokens, ['Bearer fixture-actor-a', 'Bearer fixture-actor-a']);
    },
  );

  test(
    'cancel before subscription prevents an old-identity stream RPC',
    () async {
      var calls = 0;
      final h = await GrpcHarness.start(
        ScriptFamilyService(
          (_, _, _) async => pb.Empty(),
          watch: (_, _) async* {
            calls++;
            yield grpcSnapshot();
          },
        ),
      );
      addTearDown(h.close);
      h.api.token = 'fixture-old-actor';
      final old = h.api.events();
      h.api.cancelEvents();
      h.api.token = null;
      expect(await old.toList(), isEmpty);
      expect(calls, 0);
    },
  );

  test(
    'watch cancellation never cancels an unrelated in-flight unary RPC',
    () async {
      final started = Completer<void>();
      final held = Completer<void>();
      final controller = StreamController<pb.Snapshot>();
      final h = await GrpcHarness.start(
        ScriptFamilyService((_, _, _) async {
          started.complete();
          await held.future;
          return grpcSnapshot();
        }, watch: (_, _) => controller.stream),
      );
      addTearDown(() async {
        if (!held.isCompleted) held.complete();
        await controller.close();
        await h.close();
      });
      final unary = h.api.request('GET', '/v1/snapshot');
      await started.future;
      final first = Completer<void>();
      final done = Completer<void>();
      final sub = h.api.events().listen((_) {
        if (!first.isCompleted) first.complete();
      }, onDone: done.complete);
      controller.add(grpcSnapshot());
      await first.future.timeout(const Duration(seconds: 2));
      h.api.cancelEvents();
      await done.future.timeout(const Duration(seconds: 2));
      expect(held.isCompleted, false);
      held.complete();
      expect((await unary)['revision'], 1);
      await sub.cancel();
    },
  );

  test('unary deadline is finite and never retries a mutating RPC', () async {
    var calls = 0;
    final held = Completer<void>();
    final h = await GrpcHarness.start(
      ScriptFamilyService((_, _, _) async {
        calls++;
        await held.future;
        return grpcSnapshot();
      }),
      requestTimeout: const Duration(milliseconds: 80),
    );
    addTearDown(() async {
      held.complete();
      await h.close();
    });
    await expectLater(
      h.api.request('POST', '/v1/family-space/commands', {
        'type': 'wallet.transfer',
      }),
      throwsA(apiError(408, 'deadline_exceeded')),
    );
    expect(calls, 1);
  });

  test(
    'server revocation ends scoped watch and clears persisted identity',
    () async {
      final updates = StreamController<pb.Snapshot>();
      final h = await GrpcHarness.start(
        ScriptFamilyService(
          (_, _, _) async => grpcSnapshot(),
          watch: (_, _) => updates.stream,
        ),
      );
      final vault = MemoryVault()..token = 'fixture-session';
      final session = FamilySession(api: h.api, vault: vault);
      addTearDown(() async {
        session.dispose();
        await updates.close();
        await h.server.shutdown();
      });
      await session.restore();
      final cleared = session.changes.firstWhere(
        (s) => s.phase == FamilySessionPhase.signedOut,
      );
      updates.addError(const grpc.GrpcError.unauthenticated('revoked'));
      await cleared.timeout(const Duration(seconds: 2));
      expect(session.snapshot, isNull);
      expect(session.api!.token, isNull);
      // Clearing the secure vault is sequenced after notifying the route guard.
      await Future<void>.delayed(Duration.zero);
      expect(vault.token, isNull);
    },
  );

  test(
    'lost reply reuses original key while protective lane stays independent',
    () async {
      final payloads = <JsonMap>[];
      var lost = true;
      final h = await GrpcHarness.start(
        ScriptFamilyService((method, call, request) async {
          final payload = familyMessageMap(request);
          payloads.add(payload);
          if (payload['type'] != 'card.block' && lost) {
            lost = false;
            throw const grpc.GrpcError.unavailable('committed response lost');
          }
          return grpcSnapshot(revision: payloads.length + 1);
        }),
      );
      final vault = MemoryIntentVault();
      final session =
          FamilySession(api: h.api, vault: MemoryVault(), intentVault: vault)
            ..snapshot = spacePreviewSnapshot()
            ..phase = FamilySessionPhase.signedIn;
      addTearDown(() async {
        session.dispose();
        await h.server.shutdown();
      });
      await expectLater(
        session.submitSpaceCommand({
          'type': 'wallet.transfer',
          'childId': spaceJuniorId,
          'amountMinor': 125,
        }),
        throwsA(apiError(503, 'unavailable')),
      );
      final pending = (await session.pendingSpaceCommand())!.payload;
      await session.blockCard(spaceJuniorId);
      expect((await session.pendingSpaceCommand())!.payload, pending);
      await session.retrySpaceCommand();
      expect(payloads[2], payloads[0]);
      expect(payloads[1]['type'], 'card.block');
      expect(
        payloads[1]['idempotencyKey'],
        isNot(payloads[0]['idempotencyKey']),
      );
      expect(await session.pendingSpaceCommand(), isNull);
      expect(payloads, hasLength(3));
    },
  );

  test(
    'typed error details work without trailers; malformed details stay ambiguous',
    () async {
      var malformed = false;
      var conflicting = false;
      final h = await GrpcHarness.start(
        ScriptFamilyService((_, call, _) async {
          final detail = pb.DomainErrorDetail(
            semanticStatus: malformed ? 200 : 409,
            code: 'idempotency_conflict',
          );
          final writer = CodedBufferWriter()
            ..writeField(1, PbFieldType.O3, grpc.StatusCode.failedPrecondition)
            ..writeField(
              3,
              PbFieldType.OM,
              any.Any(
                typeUrl: 'type.googleapis.com/moby.family.v1.DomainErrorDetail',
                value: detail.writeToBuffer(),
              ),
            );
          call.trailers!['grpc-status-details-bin'] = base64Encode(
            writer.toBuffer(),
          );
          if (conflicting) {
            call.trailers!['moby-semantic-status'] = '409';
            call.trailers!['moby-error-code'] = 'insufficient_funds';
          }
          throw const grpc.GrpcError.failedPrecondition(
            'must never appear in public exception',
          );
        }),
      );
      addTearDown(h.close);
      await expectLater(
        h.api.request('POST', '/v1/family-space/commands', {
          'type': 'goal.move',
        }),
        throwsA(apiError(409, 'idempotency_conflict')),
      );
      malformed = true;
      await expectLater(
        h.api.request('POST', '/v1/family-space/commands', {
          'type': 'goal.move',
        }),
        throwsA(apiError(502, 'invalid_error_details')),
      );
      malformed = false;
      conflicting = true;
      await expectLater(
        h.api.request('POST', '/v1/family-space/commands', {
          'type': 'goal.move',
        }),
        throwsA(apiError(502, 'invalid_error_details')),
      );
    },
  );

  for (final (outer, semantic, withDetail, malformedDetail) in [
    (grpc.StatusCode.unavailable, 400, false, false),
    (grpc.StatusCode.unavailable, 400, true, false),
    (grpc.StatusCode.deadlineExceeded, 409, false, false),
    (grpc.StatusCode.invalidArgument, 400, true, true),
  ]) {
    test(
      'inconsistent domain/transport status $outer/$semantic retains frozen intent ($withDetail/$malformedDetail)',
      () async {
        final h = await GrpcHarness.start(
          ScriptFamilyService((_, call, _) async {
            call.trailers!['moby-semantic-status'] = '$semantic';
            call.trailers!['moby-error-code'] = 'wrong_answer';
            if (withDetail) {
              final domain = pb.DomainErrorDetail(
                semanticStatus: semantic,
                code: 'wrong_answer',
              );
              final writer = CodedBufferWriter()
                ..writeField(1, PbFieldType.O3, outer)
                ..writeField(
                  3,
                  PbFieldType.OM,
                  any.Any(
                    typeUrl:
                        'type.googleapis.com/moby.family.v1.DomainErrorDetail',
                    value: malformedDetail ? [255] : domain.writeToBuffer(),
                  ),
                );
              call.trailers!['grpc-status-details-bin'] = base64Encode(
                writer.toBuffer(),
              );
            }
            throw grpc.GrpcError.custom(outer, 'private diagnostic');
          }),
        );
        addTearDown(h.close);
        final store = MoneyIntentStore(
          api: h.api,
          actorId: 'fixture-adult',
          vault: MemoryIntentVault(),
        );
        await expectLater(
          store.submit(
            childId: 'family-space',
            kind: MoneyIntentKind.familySpace,
            payload: {'type': 'goal.move'},
          ),
          throwsA(apiError(502, 'invalid_error_details')),
        );
        expect(
          await store.load(
            childId: 'family-space',
            kind: MoneyIntentKind.familySpace,
          ),
          isNotNull,
        );
      },
    );
  }

  for (final typedDetails in [false, true]) {
    test(
      'legitimate snapshot_limit 503 retains original intent (details=$typedDetails)',
      () async {
        JsonMap? sent;
        var calls = 0;
        final h = await GrpcHarness.start(
          ScriptFamilyService((_, call, request) async {
            calls++;
            sent = familyMessageMap(request);
            call.trailers!['moby-semantic-status'] = '503';
            call.trailers!['moby-error-code'] = 'snapshot_limit';
            if (typedDetails) {
              final detail = pb.DomainErrorDetail(
                semanticStatus: 503,
                code: 'snapshot_limit',
              );
              final writer = CodedBufferWriter()
                ..writeField(1, PbFieldType.O3, grpc.StatusCode.unavailable)
                ..writeField(
                  3,
                  PbFieldType.OM,
                  any.Any(
                    typeUrl:
                        'type.googleapis.com/moby.family.v1.DomainErrorDetail',
                    value: detail.writeToBuffer(),
                  ),
                );
              call.trailers!['grpc-status-details-bin'] = base64Encode(
                writer.toBuffer(),
              );
            }
            throw const grpc.GrpcError.unavailable('private diagnostic');
          }),
        );
        addTearDown(h.close);
        final store = MoneyIntentStore(
          api: h.api,
          actorId: 'fixture-adult',
          vault: MemoryIntentVault(),
        );
        await expectLater(
          store.submit(
            childId: 'family-space',
            kind: MoneyIntentKind.familySpace,
            payload: {
              'type': 'wallet.transfer',
              'childId': spaceJuniorId,
              'amountMinor': 125,
            },
          ),
          throwsA(apiError(503, 'snapshot_limit')),
        );
        final pending = await store.load(
          childId: 'family-space',
          kind: MoneyIntentKind.familySpace,
        );
        expect(pending, isNotNull);
        expect(pending!.payload, {
          'type': 'wallet.transfer',
          'childId': spaceJuniorId,
          'amountMinor': 125,
          'idempotencyKey': sent!['idempotencyKey'],
        });
        expect(calls, 1);
      },
    );
  }

  for (final (error, status, code) in [
    (const grpc.GrpcError.resourceExhausted('private'), 429, 'rate_limited'),
    (
      const grpc.GrpcError.deadlineExceeded('private'),
      408,
      'deadline_exceeded',
    ),
    (const grpc.GrpcError.unavailable('private'), 503, 'unavailable'),
    (const grpc.GrpcError.cancelled('private'), 499, 'request_cancelled'),
    (const grpc.GrpcError.failedPrecondition('private'), 502, 'request_failed'),
  ]) {
    test(
      'ambiguous gRPC status ${error.code} retains original outbox key',
      () async {
        var calls = 0;
        final h = await GrpcHarness.start(
          ScriptFamilyService((_, _, _) async {
            calls++;
            throw error;
          }),
        );
        addTearDown(h.close);
        final store = MoneyIntentStore(
          api: h.api,
          actorId: 'fixture-adult',
          vault: MemoryIntentVault(),
        );
        await expectLater(
          store.submit(
            childId: 'family-space',
            kind: MoneyIntentKind.familySpace,
            payload: {'type': 'goal.move'},
          ),
          throwsA(apiError(status, code)),
        );
        expect(
          await store.load(
            childId: 'family-space',
            kind: MoneyIntentKind.familySpace,
          ),
          isNotNull,
        );
        expect(calls, 1);
      },
    );
  }

  test(
    'watch idle timeout cancels the RPC and remains reconnectable',
    () async {
      final updates = StreamController<pb.Snapshot>();
      var watches = 0;
      final h = await GrpcHarness.start(
        ScriptFamilyService(
          (_, _, _) async => pb.Empty(),
          watch: (_, _) {
            watches++;
            return updates.stream;
          },
        ),
        streamIdleTimeout: const Duration(milliseconds: 80),
      );
      addTearDown(() async {
        await updates.close();
        await h.close();
      });
      await expectLater(h.api.events().first, throwsA(isA<TimeoutException>()));
      expect(watches, 1);
    },
  );

  test(
    'session reconnect obtains a fresh full snapshot without replaying commands',
    () async {
      final secondUpdates = StreamController<pb.Snapshot>();
      var watches = 0;
      var mutations = 0;
      final h = await GrpcHarness.start(
        ScriptFamilyService(
          (method, _, _) async {
            if (method != 'GetSnapshot') mutations++;
            return grpcSnapshot();
          },
          watch: (_, _) {
            watches++;
            if (watches == 1) return Stream.value(grpcSnapshot());
            return secondUpdates.stream;
          },
        ),
      );
      final session = FamilySession(
        api: h.api,
        vault: MemoryVault()..token = 'fixture-session',
      );
      addTearDown(() async {
        session.dispose();
        await secondUpdates.close();
        await h.server.shutdown();
      });
      final updated = session.changes.firstWhere((s) => s.revision == 2);
      await session.restore();
      // Buffer until the second subscription is established after the existing
      // session backoff. The transport itself does not reconnect or replay.
      secondUpdates.add(grpcSnapshot(revision: 2));
      await updated.timeout(const Duration(seconds: 4));
      expect(watches, 2);
      expect(mutations, 0);
      expect(session.connected, true);
    },
  );

  for (final (status, code, retained) in [
    (400, 'wrong_answer', false),
    (404, 'not_found', false),
    (409, 'insufficient_funds', false),
    (409, 'idempotency_conflict', true),
    (410, 'expired', false),
    (422, 'invalid_amount', false),
    (401, 'unauthorized', true),
    (403, 'forbidden', true),
    (429, 'rate_limited', true),
    (503, 'unavailable', true),
  ]) {
    test('domain error $status/$code preserves outbox semantics', () async {
      final h = await GrpcHarness.start(
        ScriptFamilyService(
          (_, call, _) async => domainFailure(call, status, code),
        ),
      );
      addTearDown(h.close);
      final store = MoneyIntentStore(
        api: h.api,
        actorId: 'fixture-adult',
        vault: MemoryIntentVault(),
      );
      await expectLater(
        store.submit(
          childId: 'family-space',
          kind: MoneyIntentKind.familySpace,
          payload: {'type': 'goal.move'},
        ),
        throwsA(apiError(status, code)),
      );
      expect(
        await store.load(
          childId: 'family-space',
          kind: MoneyIntentKind.familySpace,
        ),
        retained ? isNotNull : isNull,
      );
    });
  }
}
