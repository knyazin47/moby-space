import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/data/server/family_api.dart';

import 'family_session_test.dart' show ControlledApi, MemoryVault;

JsonMap adultIntroSnapshot({bool seen = false, int revision = 1}) => {
  'revision': revision,
  'actor': {'id': 'adult-fixture', 'role': 'adult'},
  'preferences': {'familyIntroSeen': seen},
  'children': <dynamic>[],
};

FamilySession readySession(FamilyApi api) =>
    FamilySession(api: api, vault: MemoryVault())
      ..phase = FamilySessionPhase.signedIn
      ..snapshot = adultIntroSnapshot()
      ..connected = true;

void main() {
  test(
    'completion applies returned snapshot without a second request',
    () async {
      final requests = <String>[];
      final session = readySession(
        ControlledApi((method, path, body) async {
          requests.add('$method $path');
          expect(body, isEmpty);
          return adultIntroSnapshot(seen: true, revision: 2);
        }),
      );
      addTearDown(session.dispose);
      expect(session.familyPreferencesAvailable, isTrue);
      await session.completeFamilyIntro();
      expect(session.familyIntroSeen, isTrue);
      expect(session.revision, 2);
      expect(requests, ['POST /v1/preferences/family-intro/complete']);
    },
  );

  test(
    'lost response does not set local completion; same action can retry',
    () async {
      var attempts = 0;
      final session = readySession(
        ControlledApi((method, path, body) async {
          attempts++;
          if (attempts == 1) {
            throw const FamilyApiException(503, 'response_lost');
          }
          return adultIntroSnapshot(seen: true, revision: 2);
        }),
      );
      addTearDown(session.dispose);
      await expectLater(
        session.completeFamilyIntro(),
        throwsA(isA<FamilyApiException>()),
      );
      expect(session.familyIntroSeen, isFalse);
      await session.completeFamilyIntro();
      expect(session.familyIntroSeen, isTrue);
      expect(attempts, 2);
    },
  );

  test('logout wins over in-flight intro completion', () async {
    final response = Completer<JsonMap>();
    final session = readySession(
      ControlledApi((method, path, body) async {
        if (path.endsWith('/complete')) return response.future;
        expect(path, '/v1/auth/logout');
        return {};
      }),
    );
    addTearDown(session.dispose);
    final completion = session.completeFamilyIntro();
    final assertion = expectLater(
      completion,
      throwsA(isA<FamilyApiException>()),
    );
    await session.logout();
    response.complete(adultIntroSnapshot(seen: true, revision: 10));
    await assertion;
    expect(session.snapshot, isNull);
    expect(session.phase, FamilySessionPhase.signedOut);
    expect(session.connected, isFalse);
  });

  test(
    'absent preferences never inferred from children; wrong actor rejected',
    () async {
      var calls = 0;
      final session = readySession(
        ControlledApi((method, path, body) async {
          calls++;
          return {
            ...adultIntroSnapshot(seen: true, revision: 9),
            'actor': {'id': 'different-adult', 'role': 'adult'},
          };
        }),
      );
      addTearDown(session.dispose);
      session.snapshot = {
        'revision': 1,
        'actor': {'id': 'adult-fixture', 'role': 'adult'},
        'children': [],
      };
      expect(session.familyPreferencesAvailable, isFalse);
      await expectLater(
        session.completeFamilyIntro(),
        throwsA(isA<FamilyApiException>()),
      );
      expect(calls, 0);
      session.snapshot = adultIntroSnapshot();
      await expectLater(
        session.completeFamilyIntro(),
        throwsA(isA<FamilyApiException>()),
      );
      expect(session.familyIntroSeen, isFalse);
      expect(session.revision, 1);
    },
  );
}
