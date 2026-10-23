import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/app/router.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/session_vault.dart';
import '../support/space_fixture.dart';
import 'money_intent_test.dart' show MemoryIntentVault;

class _Vault implements SessionVault {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async {}
}

void main() {
  for (final role in <String?>[null, 'child', 'adult']) {
    testWidgets(
      'actual API router isolates $role and renders allowed surface',
      (tester) async {
        final session = FamilySession(
          api: FamilyApi(Uri.parse('http://127.0.0.1:1')),
          vault: _Vault(),
          intentVault: MemoryIntentVault(),
        );
        session.phase = role == null
            ? FamilySessionPhase.signedOut
            : FamilySessionPhase.signedIn;
        session.connected = true;
        if (role != null) {
          session.snapshot = {
            'revision': 1,
            if (role == 'adult') 'preferences': {'familyIntroSeen': true},
            'actor': {
              'id': 'server-issued-actor',
              'role': role,
              if (role == 'child') 'childId': 'a',
            },
            'children': role == 'child'
                ? [
                    {
                      'id': 'a',
                      'displayName': 'Аня',
                      'policy': <String, dynamic>{},
                    },
                  ]
                : [],
            'operations': [],
          };
        }
        if (role == 'child') {
          session.snapshot = spacePreviewSnapshot(childId: spaceJuniorId);
          (session.snapshot!['children'] as List).single['displayName'] = 'Аня';
        }
        final container = ProviderContainer(
          overrides: [familySessionProvider.overrideWithValue(session)],
        );
        final router = container.read(appRouterProvider);
        addTearDown(() {
          container.dispose();
          session.dispose();
        });
        router.go(role == 'adult' ? '/family' : '/family/child/not-yours');
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          role == null
              ? '/welcome'
              : role == 'child'
              ? '/child/home'
              : '/family',
        );
        expect(
          find.text(
            role == null
                ? 'Я взрослый'
                : role == 'child'
                ? 'Привет, Аня!'
                : 'Моя семья',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      skip: !familyApiEnabled,
    );
  }
}
