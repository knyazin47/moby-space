import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:moby_demo/data/server/generated/moby/family/v1/family.pbgrpc.dart'
    as pb;
import 'grpc_test_support.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/money_intent.dart';

class MemoryIntentVault implements MoneyIntentVault {
  final values = <String, String>{};
  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class ScriptApi extends FamilyApi {
  ScriptApi(this.run) : super(Uri.parse('http://127.0.0.1:1'));
  final Future<JsonMap> Function(String method, String path, JsonMap? body) run;
  @override
  Future<JsonMap> request(String method, String path, [JsonMap? body]) =>
      run(method, path, body);
}

void main() {
  const payload = <String, dynamic>{
    'amountMinor': 123,
    'currency': 'BYN',
    'channel': 'pos',
    'category': 'other',
  };

  test(
    'uncertain outcome survives store restart and freezes original payload/key',
    () async {
      final vault = MemoryIntentVault();
      JsonMap? first;
      final api = ScriptApi((method, path, body) async {
        expect(vault.values, isNotEmpty); // durable before any POST
        first = Map.of(body!);
        throw const SocketException('response lost');
      });
      addTearDown(api.close);
      final original = MoneyIntentStore(
        api: api,
        actorId: 'server-actor',
        vault: vault,
      );
      await expectLater(
        original.submit(
          childId: 'a',
          kind: MoneyIntentKind.purchase,
          payload: payload,
        ),
        throwsA(isA<SocketException>()),
      );
      final retryApi = ScriptApi((method, path, body) async {
        expect(body, first);
        return {'id': 'only-operation', 'status': 'done'};
      });
      addTearDown(retryApi.close);
      final restored = MoneyIntentStore(
        api: retryApi,
        actorId: 'server-actor',
        vault: vault,
        onAcknowledged: () async {
          throw const SocketException('refresh lost');
        },
      );
      final pending = await restored.load(
        childId: 'a',
        kind: MoneyIntentKind.purchase,
      );
      expect(pending!.payload['amountMinor'], 123);
      expect(
        () => pending.payload['amountMinor'] = 999,
        throwsUnsupportedError,
      );
      await expectLater(
        restored.submit(
          childId: 'a',
          kind: MoneyIntentKind.purchase,
          payload: {...payload, 'amountMinor': 999},
        ),
        throwsA(isA<PendingMoneyIntentException>()),
      );
      expect(
        (await restored.retry(
          childId: 'a',
          kind: MoneyIntentKind.purchase,
        ))['id'],
        'only-operation',
      );
      expect(
        await restored.load(childId: 'a', kind: MoneyIntentKind.purchase),
        isNull,
      );
    },
  );

  for (final status in [401, 403, 408, 429, 500, 502, 503]) {
    test(
      'HTTP$status preserves original key and actor/child/kind scope',
      () async {
        final vault = MemoryIntentVault();
        final api = ScriptApi(
          (_, _, _) async => throw FamilyApiException(status, 'unavailable'),
        );
        addTearDown(api.close);
        final store = MoneyIntentStore(
          api: api,
          actorId: 'actor-a',
          vault: vault,
        );
        await expectLater(
          store.submit(
            childId: 'a',
            kind: MoneyIntentKind.topup,
            payload: payload,
          ),
          throwsA(isA<FamilyApiException>()),
        );
        expect(
          await store.load(childId: 'a', kind: MoneyIntentKind.topup),
          isNotNull,
        );
        expect(
          await store.load(childId: 'b', kind: MoneyIntentKind.topup),
          isNull,
        );
        expect(
          await store.load(childId: 'a', kind: MoneyIntentKind.purchase),
          isNull,
        );
        expect(
          await MoneyIntentStore(
            api: api,
            actorId: 'actor-b',
            vault: vault,
          ).load(childId: 'a', kind: MoneyIntentKind.topup),
          isNull,
        );
      },
    );
  }
  test(
    'definitive business rejection clears pending; ambiguous key conflict keeps it',
    () async {
      final vault = MemoryIntentVault();
      var code = 'insufficient_balance';
      final api = ScriptApi(
        (_, _, _) async => throw FamilyApiException(409, code),
      );
      addTearDown(api.close);
      final store = MoneyIntentStore(api: api, actorId: 'actor', vault: vault);
      await expectLater(
        store.submit(
          childId: 'a',
          kind: MoneyIntentKind.purchase,
          payload: payload,
        ),
        throwsA(isA<FamilyApiException>()),
      );
      expect(
        await store.load(childId: 'a', kind: MoneyIntentKind.purchase),
        isNull,
      );
      code = 'idempotency_conflict';
      await expectLater(
        store.submit(
          childId: 'a',
          kind: MoneyIntentKind.purchase,
          payload: payload,
        ),
        throwsA(isA<FamilyApiException>()),
      );
      expect(
        await store.load(childId: 'a', kind: MoneyIntentKind.purchase),
        isNotNull,
      );
    },
  );

  test(
    'actual lost gRPC response retries once with persisted command after restart',
    () async {
      final committed = <String, pb.Child>{};
      var requests = 0;
      final h = await GrpcHarness.start(
        ScriptFamilyService((_, _, request) async {
          requests++;
          final body = request as pb.CreateChildRequest;
          committed.putIfAbsent(
            body.idempotencyKey,
            () => grpcSnapshot().children.first.deepCopy()
              ..id = 'single-child'
              ..displayName = body.displayName,
          );
          if (requests == 1) {
            throw const grpc.GrpcError.unavailable('acknowledgement lost');
          }
          return committed[body.idempotencyKey]!;
        }),
      );
      addTearDown(h.close);
      final vault = MemoryIntentVault();
      final initial = MoneyIntentStore(
        api: h.api,
        actorId: 'adult',
        vault: vault,
      );
      await expectLater(
        initial.submit(
          childId: 'new',
          kind: MoneyIntentKind.createChild,
          payload: {
            'displayName': 'Аня',
            'legalName': 'Синтетическое имя',
            'dateOfBirth': '2014-01-01',
          },
        ),
        throwsA(isA<FamilyApiException>()),
      );
      final restored = MoneyIntentStore(
        api: h.api,
        actorId: 'adult',
        vault: vault,
      );
      expect(
        (await restored.retry(
          childId: 'new',
          kind: MoneyIntentKind.createChild,
        ))['id'],
        'single-child',
      );
      expect(requests, 2);
      expect(committed.length, 1);
    },
  );
}
