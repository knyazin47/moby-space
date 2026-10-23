import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/money_intent.dart';

import '../support/space_fixture.dart';
import 'family_session_test.dart' show ControlledApi, MemoryVault;
import 'money_intent_test.dart' show MemoryIntentVault, ScriptApi;
import 'grpc_test_support.dart';

void main() {
  test(
    'new protective intent blocks after lost reply and later adult unblock',
    () async {
      final payloads = <JsonMap>[];
      final api = ControlledApi((method, path, body) async {
        payloads.add(Map.of(body!));
        if (payloads.length == 1) {
          throw const SocketException('first block committed but reply lost');
        }
        final result = spacePreviewSnapshot(childId: spaceJuniorId)
          ..['revision'] = payloads.length + 1;
        (result['children'] as List).single['cardStatus'] = payloads.length == 2
            ? 'active'
            : 'blocked';
        return result;
      });
      final session =
          FamilySession(
              api: api,
              vault: MemoryVault(),
              intentVault: MemoryIntentVault(),
            )
            ..snapshot = spacePreviewSnapshot(childId: spaceJuniorId)
            ..phase = FamilySessionPhase.signedIn;
      addTearDown(session.dispose);
      await expectLater(
        session.blockCard(spaceJuniorId),
        throwsA(isA<SocketException>()),
      );
      await session.blockCard(spaceJuniorId);
      expect(payloads, hasLength(3));
      expect(payloads[1], payloads[0]);
      expect(
        payloads[2]['idempotencyKey'],
        isNot(payloads[0]['idempotencyKey']),
      );
      expect(session.child!['cardStatus'], 'blocked');
    },
  );

  test(
    'malformed 2xx keeps original key until valid acknowledgement',
    () async {
      final payloads = <JsonMap>[];
      final api = ControlledApi((method, path, body) async {
        payloads.add(Map.of(body!));
        if (payloads.length == 1) {
          return {
            'actor': {'id': 'preview-adult', 'role': 'adult'},
            'revision': 2,
            'children': [],
          };
        }
        if (payloads.length == 2 || payloads.length == 3) {
          final invalid = spacePreviewSnapshot()..['revision'] = 2;
          (invalid['actor'] as JsonMap)['role'] = payloads.length == 2
              ? 'invalid'
              : 'child';
          return invalid;
        }
        return spacePreviewSnapshot()..['revision'] = 2;
      });
      final session =
          FamilySession(
              api: api,
              vault: MemoryVault(),
              intentVault: MemoryIntentVault(),
            )
            ..snapshot = spacePreviewSnapshot()
            ..phase = FamilySessionPhase.signedIn;
      addTearDown(session.dispose);
      await expectLater(
        session.submitSpaceCommand({
          'type': 'wallet.transfer',
          'childId': spaceJuniorId,
          'amountMinor': 100,
        }),
        throwsA(isA<FamilyApiException>()),
      );
      expect(await session.pendingSpaceCommand(), isNotNull);
      for (var i = 0; i < 2; i++) {
        await expectLater(
          session.retrySpaceCommand(),
          throwsA(isA<FamilyApiException>()),
        );
        expect(await session.pendingSpaceCommand(), isNotNull);
      }
      await session.retrySpaceCommand();
      for (final replay in payloads.skip(1)) {
        expect(replay, payloads[0]);
      }
      expect(await session.pendingSpaceCommand(), isNull);
      expect(session.revision, 2);
    },
  );

  test(
    'protective block bypasses frozen money lane without changing it',
    () async {
      final calls = <String>[];
      final api = ControlledApi((method, path, body) async {
        calls.add(body!['type'] as String);
        if (body['type'] != 'card.block') {
          throw const SocketException('lost money response');
        }
        final result = spacePreviewSnapshot(childId: spaceJuniorId)
          ..['revision'] = 2;
        (result['children'] as List).single['cardStatus'] = 'blocked';
        return result;
      });
      final session =
          FamilySession(
              api: api,
              vault: MemoryVault(),
              intentVault: MemoryIntentVault(),
            )
            ..snapshot = spacePreviewSnapshot(childId: spaceJuniorId)
            ..phase = FamilySessionPhase.signedIn;
      addTearDown(session.dispose);
      await expectLater(
        session.submitSpaceCommand({
          'type': 'goal.move',
          'childId': spaceJuniorId,
          'entityId': 'goal',
          'action': 'deposit',
          'amountMinor': 100,
        }),
        throwsA(isA<SocketException>()),
      );
      final frozen = (await session.pendingSpaceCommand())!.payload;
      await session.blockCard(spaceJuniorId);
      expect(session.child!['cardStatus'], 'blocked');
      expect((await session.pendingSpaceCommand())!.payload, frozen);
      expect(calls, ['goal.move', 'card.block']);
    },
  );

  test('delayed transport keeps the original actor authorization', () async {
    final received = Completer<String?>();
    final release = Completer<void>();
    final h = await GrpcHarness.start(
      ScriptFamilyService((_, call, _) async {
        received.complete(call.clientMetadata?['authorization']);
        await release.future;
        return grpcSnapshot();
      }),
    );
    addTearDown(h.close);
    h.api.token = 'actor-a-fixture';
    final request = h.api.request('GET', '/v1/snapshot');
    h.api.token = 'actor-b-fixture';
    expect(await received.future, 'Bearer actor-a-fixture');
    release.complete();
    await request;
  });

  test(
    'v2 acknowledgement applies returned snapshot without refresh request',
    () async {
      final paths = <String>[];
      final api = ControlledApi((method, path, body) async {
        paths.add('$method $path');
        expect(body!['type'], 'wallet.transfer');
        expect(body['idempotencyKey'], isA<String>());
        return spacePreviewSnapshot()..['revision'] = 2;
      });
      final session =
          FamilySession(
              api: api,
              vault: MemoryVault(),
              intentVault: MemoryIntentVault(),
            )
            ..snapshot = spacePreviewSnapshot()
            ..phase = FamilySessionPhase.signedIn;
      addTearDown(session.dispose);
      await session.submitSpaceCommand({
        'type': 'wallet.transfer',
        'childId': spaceJuniorId,
        'amountMinor': 100,
      });
      expect(paths, ['POST /v1/family-space/commands']);
      expect(session.revision, 2);
      expect(session.connected, isTrue);
      expect(await session.pendingSpaceCommand(), isNull);
    },
  );

  test(
    'v2 lost response freezes all actor commands, retry uses original payload',
    () async {
      final vault = MemoryIntentVault();
      JsonMap? sent;
      final api = ScriptApi((method, path, body) async {
        expect(path, '/v1/family-space/commands');
        sent = Map.of(body!);
        throw const SocketException('lost acknowledgement');
      });
      addTearDown(api.close);
      final store = MoneyIntentStore(api: api, actorId: 'adult', vault: vault);
      await expectLater(
        store.submit(
          childId: 'family-space',
          kind: MoneyIntentKind.familySpace,
          payload: {
            'type': 'task.accept',
            'childId': 'one',
            'entityId': 'task-one',
          },
        ),
        throwsA(isA<SocketException>()),
      );
      await expectLater(
        store.submit(
          childId: 'family-space',
          kind: MoneyIntentKind.familySpace,
          payload: {
            'type': 'wallet.transfer',
            'childId': 'two',
            'amountMinor': 200,
          },
        ),
        throwsA(isA<PendingMoneyIntentException>()),
      );
      final replay = ScriptApi((_, _, body) async {
        expect(body, sent);
        return spacePreviewSnapshot();
      });
      addTearDown(replay.close);
      final restored = MoneyIntentStore(
        api: replay,
        actorId: 'adult',
        vault: vault,
      );
      await restored.retry(
        childId: 'family-space',
        kind: MoneyIntentKind.familySpace,
      );
      expect(
        await restored.load(
          childId: 'family-space',
          kind: MoneyIntentKind.familySpace,
        ),
        isNull,
      );
    },
  );

  test(
    'logout wins over in-flight v2 reply and old store cannot use new login',
    () async {
      final response = Completer<JsonMap>();
      final started = Completer<void>();
      var calls = 0;
      final api = ControlledApi((method, path, body) async {
        if (path == '/v1/auth/logout') return {};
        calls++;
        started.complete();
        return response.future;
      });
      final session =
          FamilySession(
              api: api,
              vault: MemoryVault(),
              intentVault: MemoryIntentVault(),
            )
            ..snapshot = spacePreviewSnapshot()
            ..phase = FamilySessionPhase.signedIn;
      addTearDown(session.dispose);
      final oldStore = session.moneyIntents;
      final future = session.submitSpaceCommand({
        'type': 'wallet.transfer',
        'childId': spaceJuniorId,
        'amountMinor': 100,
      });
      final assertion = expectLater(future, throwsA(isA<FamilyApiException>()));
      await started.future;
      await session.logout();
      response.complete(spacePreviewSnapshot()..['revision'] = 5);
      await assertion;
      expect(session.phase, FamilySessionPhase.signedOut);
      expect(session.snapshot, isNull);
      await expectLater(
        oldStore.submit(
          childId: 'other',
          kind: MoneyIntentKind.familySpace,
          payload: {'type': 'wallet.transfer'},
        ),
        throwsA(isA<FamilyApiException>()),
      );
      expect(calls, 1);
    },
  );
}
