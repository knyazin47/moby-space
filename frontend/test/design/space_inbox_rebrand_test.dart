import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/core/config/space_inbox_content.dart';
import 'package:moby_demo/core/theme/mt_brand_theme.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/family_space.dart';
import 'package:moby_demo/features/space/space_components.dart';
import 'package:moby_demo/features/space/space_inbox_section.dart';
import '../support/space_fixture.dart';

void main() {
  test('inbox time uses Minsk regardless of device timezone', () {
    expect(SpaceInboxContent.eventTime(0), '01.01.1970 · 03:00');
    expect(SpaceInboxContent.eventTime(86400 - 3600), '02.01.1970 · 02:00');
  });

  test(
    'notice acknowledgement preserves an unresolved monetary intent',
    () async {
      final api = SpacePreviewApi();
      final session = SpacePreviewSession(api);
      addTearDown(session.dispose);
      api.beforeCommand = (command) async {
        if (command['type'] == 'wallet.transfer') {
          throw const FamilyApiException(503, 'unavailable');
        }
      };
      await expectLater(
        session.submitSpaceCommand({
          'type': 'wallet.transfer',
          'childId': spaceJuniorId,
          'amountMinor': 100,
        }),
        throwsA(isA<FamilyApiException>()),
      );
      final before = await session.pendingSpaceCommand();
      expect(before, isNotNull);
      await session.markNoticeRead(
        childId: spaceJuniorId,
        noticeId: 'notice-$spaceJuniorId',
      );
      final after = await session.pendingSpaceCommand();
      expect(after!.payload, before!.payload);
      expect(api.commands.single['type'], 'notice.read');
      expect(api.commands.single['idempotencyKey'], startsWith('notice-read-'));
      expect(
        FamilySpace.fromSnapshot(
          session.snapshot,
        ).notices.singleWhere((n) => n.id == 'notice-$spaceJuniorId').read,
        isTrue,
      );
    },
  );

  test(
    'child cannot acknowledge a sibling notice even with forged metadata',
    () async {
      final api = SpacePreviewApi(childId: spaceJuniorId);
      final notices = (api.data['familySpace'] as JsonMap)['notices'] as List;
      notices.add({
        ...notices.first as JsonMap,
        'id': 'sibling',
        'childId': spaceTeenId,
      });
      final session = SpacePreviewSession(api);
      addTearDown(session.dispose);
      await expectLater(
        session.markNoticeRead(childId: spaceTeenId, noticeId: 'sibling'),
        throwsA(isA<FamilyApiException>()),
      );
      expect(api.commands, isEmpty);
    },
  );

  testWidgets('inbox has actor context, stable order and independent read', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = SpacePreviewApi();
    final notices = (api.data['familySpace'] as JsonMap)['notices'] as List;
    notices.clear();
    notices.addAll([
      _notice('a', spaceJuniorId, 'wallet.transfer'),
      _notice('z', spaceJuniorId, 'not.allowed'),
      _notice('inactive', spaceTeenId, 'goal.create'),
    ]);
    (api.data['children'] as List).singleWhere(
      (child) => child['id'] == spaceTeenId,
    )['membershipStatus'] = 'archived';
    final session = SpacePreviewSession(api);
    final actions = SpaceActions(
      busy: true,
      error: null,
      pending: null,
      run: (_) async => throw StateError('read must not use monetary action'),
      perform: (_) async => false,
      retry: () async {},
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMtBrandTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(
          body: ListenableBuilder(
            listenable: session,
            builder: (context, _) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SpaceInboxSection(
                  session: session,
                  space: FamilySpace.fromSnapshot(session.snapshot),
                  actions: actions,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Михаил'), findsNWidgets(2));
    expect(find.text('01.01.1970 · 03:00'), findsNWidgets(3));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('inbox-notice-z'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey('inbox-notice-a'))).dy,
      ),
    );
    expect(find.byKey(const ValueKey('inbox-open-a')), findsOneWidget);
    expect(find.byKey(const ValueKey('inbox-open-z')), findsNothing);
    expect(find.byKey(const ValueKey('inbox-open-inactive')), findsNothing);
    final read = find.byKey(const ValueKey('inbox-read-z'));
    expect(tester.widget<TextButton>(read).onPressed, isNotNull);
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(api.commands.single['type'], 'notice.read');
    expect(find.byKey(const ValueKey('inbox-read-z')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    session.dispose();
  });

  testWidgets('child inbox opens only allowlisted own section via callback', (
    tester,
  ) async {
    final api = SpacePreviewApi(childId: spaceJuniorId);
    final notices = (api.data['familySpace'] as JsonMap)['notices'] as List;
    notices.clear();
    notices.addAll([
      _notice('own', spaceJuniorId, 'goal.move'),
      _notice('sibling', spaceTeenId, 'wallet.transfer'),
    ]);
    final session = SpacePreviewSession(api);
    final opened = <String>[];
    final actions = SpaceActions(
      busy: false,
      error: null,
      pending: null,
      run: (_) async => false,
      perform: (_) async => false,
      retry: () async {},
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMtBrandTheme(),
        home: Scaffold(
          body: SpaceInboxSection(
            session: session,
            space: FamilySpace.fromSnapshot(session.snapshot),
            actions: actions,
            onChildSection: opened.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('inbox-notice-sibling')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('inbox-open-own')));
    expect(opened, ['goals']);
    expect(api.commands, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    session.dispose();
  });
}

JsonMap _notice(String id, String childId, String kind) => {
  'id': id,
  'childId': childId,
  'kind': kind,
  'title': 'Событие $id',
  'body': 'Откройте раздел',
  'createdAt': 0,
  'read': false,
  'mandatory': true,
};
