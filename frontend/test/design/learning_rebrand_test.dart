import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/core/config/space_control_content.dart';
import 'package:moby_demo/core/config/space_ui_content.dart';
import 'package:moby_demo/core/theme/mt_brand_theme.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/family_space.dart';
import 'package:moby_demo/features/space/space_components.dart';
import 'package:moby_demo/features/space/space_control_sections.dart';

import '../support/space_fixture.dart';

Future<List<JsonMap>> _pump(
  WidgetTester tester, {
  bool adult = false,
  bool busy = false,
  bool connected = true,
  double scale = 1,
  void Function(JsonMap)? configure,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final api = SpacePreviewApi(childId: adult ? null : spaceTeenId);
  configure?.call(api.data);
  final session = SpacePreviewSession(api)..connected = connected;
  addTearDown(session.dispose);
  final commands = <JsonMap>[];
  final actions = SpaceActions(
    busy: busy,
    error: null,
    pending: null,
    run: (command) async {
      commands.add(command);
      return true;
    },
    perform: (operation) async {
      await operation();
      return true;
    },
    retry: () async {},
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMtBrandTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SpaceLearningSection(
            session: session,
            space: FamilySpace.fromSnapshot(session.snapshot),
            actions: actions,
            childId: spaceTeenId,
            adult: adult,
            headerAction: const CircleAvatar(child: Text('А')),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return commands;
}

Future<void> _open(WidgetTester tester, String id) async {
  final finder = find.byKey(ValueKey('lesson-open-$id'));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'features the first incomplete lesson with real progress and body',
    (tester) async {
      await _pump(tester);
      expect(find.text(SpaceControlContent.childLearningTitle), findsOneWidget);
      expect(find.text('1 из 4 тем'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, SpaceControlContent.beginLesson),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('lesson-open-saving-goal')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Раздели стоимость цели на небольшие части. Деньги в цели хранятся отдельно от доступных для покупок.',
        ),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('child answers are submitted with the selected server lesson', (
    tester,
  ) async {
    final commands = await _pump(tester);
    await _open(tester, 'saving-goal');
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, SpaceUiCopy.lessonSubmit),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('lesson-answer-1')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, SpaceUiCopy.lessonSubmit),
    );
    await tester.pumpAndSettle();
    expect(commands, [
      {
        'type': 'lesson.complete',
        'childId': spaceTeenId,
        'entityId': 'saving-goal',
        'answerIndex': 1,
      },
    ]);
  });

  testWidgets('adult can read a lesson but cannot answer for the child', (
    tester,
  ) async {
    final commands = await _pump(tester, adult: true);
    expect(find.text(SpaceControlContent.adultLearningTitle), findsOneWidget);
    await _open(tester, 'saving-goal');
    expect(find.text(SpaceControlContent.lessonReadOnly), findsOneWidget);
    expect(find.byType(RadioListTile<int>), findsNothing);
    expect(find.text(SpaceUiCopy.lessonSubmit), findsNothing);
    expect(commands, isEmpty);
  });

  testWidgets(
    'completed catalogue remains reviewable without an invented next lesson',
    (tester) async {
      await _pump(
        tester,
        scale: 1.3,
        configure: (snapshot) {
          final space = snapshot['familySpace'] as JsonMap;
          space['learning'] = [
            for (final lesson in space['lessons'] as List)
              {
                'childId': spaceTeenId,
                'lessonId': (lesson as JsonMap)['id'],
                'completedAt': 1792454400,
              },
          ];
        },
      );
      expect(find.text('4 из 4 тем'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text(SpaceControlContent.beginLesson), findsNothing);
      expect(find.text(SpaceControlContent.allTopicsCompleted), findsOneWidget);
      await _open(tester, 'needs-wants');
      expect(find.text('Нужды и желания'), findsWidgets);
    },
  );

  testWidgets('empty catalogue has no fake progress or lesson action', (
    tester,
  ) async {
    await _pump(
      tester,
      configure: (snapshot) {
        (snapshot['familySpace'] as JsonMap)['lessons'] = [];
      },
    );
    expect(find.text(SpaceControlContent.lessonsUnavailable), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text(SpaceControlContent.beginLesson), findsNothing);
  });

  for (final offline in [false, true]) {
    testWidgets(
      '${offline ? 'offline' : 'busy'} state disables all lesson entries',
      (tester) async {
        await _pump(tester, busy: !offline, connected: !offline, scale: 1.3);
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('lesson-open-saving-goal')),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<SpaceLink>(
                find.byKey(const ValueKey('lesson-open-needs-wants')),
              )
              .onTap,
          isNull,
        );
      },
    );
  }
}
