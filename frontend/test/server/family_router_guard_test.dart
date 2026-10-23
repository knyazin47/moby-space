import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/session_vault.dart';

class _Vault implements SessionVault {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async {}
}

void main() {
  for (final role in <String?>[null, 'child']) {
    testWidgets('deep link never builds adult private page for $role', (
      tester,
    ) async {
      final session = FamilySession(
        api: FamilyApi(Uri.parse('http://127.0.0.1:1')),
        vault: _Vault(),
      );
      session.phase = role == null
          ? FamilySessionPhase.signedOut
          : FamilySessionPhase.signedIn;
      if (role != null) {
        session.snapshot = {
          'revision': 1,
          'actor': {'id': 'server-child', 'role': role, 'childId': 'a'},
          'children': [
            {'id': 'a'},
          ],
        };
      }
      var privateBuilds = 0;
      final router = GoRouter(
        initialLocation: '/family/child/other',
        refreshListenable: session,
        redirect: (context, state) =>
            familyRouteRedirect(session, state.uri.path),
        routes: [
          GoRoute(
            path: '/welcome',
            builder: (context, state) => const Scaffold(body: Text('welcome')),
          ),
          GoRoute(
            path: '/child/home',
            builder: (context, state) =>
                const Scaffold(body: Text('own child')),
          ),
          GoRoute(
            path: '/family/child/:id',
            builder: (context, state) {
              privateBuilds++;
              return const Scaffold(body: Text('private adult'));
            },
          ),
        ],
      );
      addTearDown(() {
        router.dispose();
        session.dispose();
      });
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(privateBuilds, 0);
      expect(find.text('private adult'), findsNothing);
      expect(find.text(role == null ? 'welcome' : 'own child'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
