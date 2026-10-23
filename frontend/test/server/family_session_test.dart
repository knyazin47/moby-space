import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:moby_demo/data/server/generated/moby/family/v1/family.pbgrpc.dart'
    as pb;
import '../support/space_fixture.dart';
import 'grpc_test_support.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/session_vault.dart';

class MemoryVault implements SessionVault {
  String? token;
  @override
  Future<void> clear() async => token = null;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String value) async => token = value;
}

class ControlledApi extends FamilyApi {
  ControlledApi(this.run, {this.updates})
    : super(Uri.parse('http://127.0.0.1:1'));
  final Future<JsonMap> Function(String, String, JsonMap?) run;
  final Stream<JsonMap>? updates;
  @override
  Future<JsonMap> request(String method, String path, [JsonMap? body]) =>
      run(method, path, body);
  @override
  Stream<JsonMap> events() => updates ?? const Stream.empty();
}

class DelayedWriteVault extends MemoryVault {
  final started = Completer<void>();
  final release = Completer<void>();
  @override
  Future<void> write(String value) async {
    started.complete();
    await release.future;
    await super.write(value);
  }
}

void main() {
  final snapshot = <String, dynamic>{
    'revision': 1,
    'actor': {'id': 'actor-child-a', 'role': 'child', 'childId': 'child-a'},
    'children': [
      {'id': 'child-a', 'displayName': 'Аня'},
    ],
  };

  test('guard rejects signed-out deep links and confines child scope', () {
    final session = FamilySession(
      api: FamilyApi(Uri.parse('http://127.0.0.1:1')),
      vault: MemoryVault(),
    );
    addTearDown(session.dispose);
    expect(familyRouteRedirect(session, '/family/child/other'), '/welcome');
    session.phase = FamilySessionPhase.signedOut;
    expect(familyRouteRedirect(session, '/home'), '/welcome');
    expect(familyRouteRedirect(session, '/family'), '/welcome');
    expect(familyRouteRedirect(session, '/child/home'), '/welcome');
    expect(familyRouteRedirect(session, '/adult/code'), isNull);
    session.phase = FamilySessionPhase.signedIn;
    session.snapshot = snapshot;
    for (final path in [
      '/home',
      '/family',
      '/family/child/other',
      '/settings',
      '/welcome',
    ]) {
      expect(familyRouteRedirect(session, path), '/child/home');
    }
    expect(familyRouteRedirect(session, '/child/home'), isNull);
    session.snapshot = {
      ...snapshot,
      'actor': {'id': 'adult', 'role': 'adult'},
    };
    expect(familyRouteRedirect(session, '/child/home'), '/home');
    expect(familyRouteRedirect(session, '/family'), isNull);
  });

  test('unset transport preserves legacy route control', () async {
    final vault = MemoryVault()..token = 'not-read';
    final session = FamilySession(api: null, vault: vault);
    addTearDown(session.dispose);
    await session.restore();
    expect(familyRouteRedirect(session, '/home'), isNull);
    expect(familyRouteRedirect(session, '/child/home'), isNull);
    expect(vault.token, 'not-read');
  });

  test('transport forbids public cleartext and URL credentials', () {
    expect(
      () => FamilyApi(Uri.parse('http://example.com')),
      throwsArgumentError,
    );
    expect(
      () => FamilyApi(Uri.parse('https://secret@example.com')),
      throwsArgumentError,
    );
    expect(
      () => FamilyApi(Uri.parse('https://example.com?token=secret')),
      throwsArgumentError,
    );
  });

  test(
    'restore trusts scoped server actor, persists issued token and revokes on logout',
    () async {
      final methods = <String>[];
      final updates = StreamController<pb.Snapshot>();
      final h = await GrpcHarness.start(
        ScriptFamilyService(
          (method, call, _) async {
            methods.add(method);
            expect(
              call.clientMetadata?['authorization'],
              'Bearer existing-token',
            );
            if (method == 'Logout') return pb.Empty();
            return grpcSnapshot(childId: spaceJuniorId);
          },
          watch: (call, _) {
            expect(
              call.clientMetadata?['authorization'],
              'Bearer existing-token',
            );
            return updates.stream;
          },
        ),
      );
      final vault = MemoryVault()..token = 'existing-token';
      final session = FamilySession(api: h.api, vault: vault);
      addTearDown(() async {
        session.dispose();
        await updates.close();
        await h.server.shutdown();
      });
      await session.restore();
      expect(session.phase, FamilySessionPhase.signedIn);
      expect(session.role, 'child');
      expect(session.child?['id'], spaceJuniorId);
      final changed = session.changes.firstWhere(
        (event) => event.revision == 2,
      );
      updates.add(grpcSnapshot(childId: spaceJuniorId, revision: 2));
      await changed.timeout(const Duration(seconds: 3));
      await session.logout();
      expect(methods, contains('Logout'));
      expect(vault.token, isNull);
      expect(session.snapshot, isNull);
      expect(session.api!.token, isNull);
      expect(familyRouteRedirect(session, '/family'), '/welcome');
    },
  );

  test('expired persisted session is removed with scoped cache', () async {
    final h = await GrpcHarness.start(
      ScriptFamilyService((_, _, _) async {
        throw const grpc.GrpcError.unauthenticated('expired');
      }),
    );
    final vault = MemoryVault()..token = 'expired';
    final session = FamilySession(api: h.api, vault: vault);
    addTearDown(() async {
      session.dispose();
      await h.server.shutdown();
    });
    await session.restore();
    expect(session.phase, FamilySessionPhase.signedOut);
    expect(vault.token, isNull);
    expect(session.snapshot, isNull);
  });
  test(
    'in-flight refresh and restore cannot repopulate cache after logout',
    () async {
      for (final restoring in [false, true]) {
        final delayed = Completer<JsonMap>();
        final started = Completer<void>();
        final api = ControlledApi((method, path, body) async {
          if (path == '/v1/snapshot') {
            started.complete();
            return delayed.future;
          }
          return {};
        });
        final vault = MemoryVault()..token = 'old';
        final session = FamilySession(api: api, vault: vault);
        session.snapshot = snapshot;
        session.phase = FamilySessionPhase.signedIn;
        final inFlight = restoring ? session.restore() : session.refresh();
        await started.future;
        await session.logout();
        delayed.complete({...snapshot, 'revision': 99});
        await inFlight;
        expect(session.phase, FamilySessionPhase.signedOut);
        expect(session.snapshot, isNull);
        expect(session.connected, isFalse);
        expect(vault.token, isNull);
        session.dispose();
      }
    },
  );

  test('delayed secure write cannot restore token after logout', () async {
    final vault = DelayedWriteVault();
    final api = ControlledApi((_, path, _) async {
      expect(path, '/v1/auth/logout');
      return {};
    });
    final session = FamilySession(api: api, vault: vault);
    addTearDown(session.dispose);
    final login = session.acceptPairSession({'token': 'new'});
    await vault.started.future;
    final logout = session.logout();
    await Future<void>.delayed(Duration.zero);
    vault.release.complete();
    await Future.wait([login, logout]);
    expect(vault.token, isNull);
    expect(session.phase, FamilySessionPhase.signedOut);
    expect(session.snapshot, isNull);
  });

  test('acknowledged command succeeds when subsequent refresh fails', () async {
    final api = ControlledApi((method, path, _) async {
      if (path == '/v1/snapshot') {
        throw const FamilyApiException(503, 'unavailable');
      }
      return {'id': 'acknowledged', 'status': 'done'};
    });
    final session = FamilySession(api: api, vault: MemoryVault());
    addTearDown(session.dispose);
    session.phase = FamilySessionPhase.signedIn;
    session.snapshot = snapshot;
    session.connected = true;
    final result = await session.command('POST', '/v1/example', {});
    expect(result['id'], 'acknowledged');
    expect(session.connected, isFalse);
    expect(session.phase, FamilySessionPhase.signedIn);
  });

  test('older SSE snapshot never rolls back a newer revision', () async {
    final updates = StreamController<JsonMap>.broadcast();
    final api = ControlledApi(
      (_, _, _) async => {...snapshot, 'revision': 20},
      updates: updates.stream,
    );
    final session = FamilySession(
      api: api,
      vault: MemoryVault()..token = 'existing',
    );
    addTearDown(() async {
      session.dispose();
      await updates.close();
    });
    await session.restore();
    final applied = session.changes.first;
    updates.add({...snapshot, 'revision': 3});
    await applied;
    expect(session.revision, 20);
  });
}
