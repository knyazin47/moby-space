import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/core/config/space_content.dart';
import 'package:moby_demo/core/config/space_control_content.dart';
import 'package:moby_demo/core/config/space_policy_presets.dart';
import 'package:moby_demo/core/config/space_ui_content.dart';
import 'package:moby_demo/core/theme/mt_brand_theme.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/family_space.dart';
import 'package:moby_demo/data/server/session_vault.dart';
import 'package:moby_demo/features/space/space_components.dart';
import 'package:moby_demo/features/space/space_control_sections.dart';

class _Vault implements SessionVault {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async {}
}

class _RecordingSession extends FamilySession {
  _RecordingSession() : super(api: null, vault: _Vault()) {
    connected = true;
    snapshot = {
      'children': [
        {
          'id': 'child',
          'policy': {
            'payments': false,
            'transfers': true,
            'internet': false,
            'dailyLimit': 800,
            'monthlyLimit': 9000,
            'approvalThreshold': 200,
            'categories': {
              'food': true,
              'transport': false,
              'entertainment': false,
              'other': true,
            },
          },
        },
      ],
    };
  }
  final calls = <({String method, String path, JsonMap? body})>[];
  @override
  Future<JsonMap> command(String method, String path, [JsonMap? body]) async {
    calls.add((method: method, path: path, body: body));
    return {};
  }
}

FamilySpace _space() => FamilySpace.fromSnapshot({
  'familySpace': {
    'goals': <JsonMap>[],
    'tasks': <JsonMap>[],
    'errands': <JsonMap>[],
    'allowances': [
      {
        'id': 'schedule',
        'childId': 'child',
        'title': 'На неделю',
        'amountMinor': 1000,
        'frequency': 'weekly',
        'weekdays': [1],
        'monthDay': 1,
        'nextDate': DateTime.now()
            .toUtc()
            .add(const Duration(days: 7, hours: 3))
            .toIso8601String()
            .substring(0, 10),
        'retryLimit': 0,
        'active': true,
      },
    ],
    'installments': <JsonMap>[],
    'requests': [
      {
        'id': 'request',
        'childId': 'child',
        'title': 'Помоги разобраться',
        'kind': 'help',
        'status': 'pending',
      },
    ],
    'settings': <String, dynamic>{},
    'learning': <JsonMap>[],
    'lessons': [
      {
        'id': 'saving-goal',
        'title': 'Своими шагами',
        'body': 'Отложенная сумма помогает двигаться к цели.',
        'skill': 'saving',
        'question': 'Как начать?',
        'options': ['Потратить всё', 'Отложить посильную сумму'],
      },
    ],
    'weekly': <JsonMap>[],
  },
});

SpaceActions _actions(List<JsonMap> commands) => SpaceActions(
  busy: false,
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

Widget _host(Widget child) => MaterialApp(
  theme: buildMtBrandTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: const TextScaler.linear(1.3)),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: child,
    ),
  ),
);

void main() {
  testWidgets(
    'lesson starts unchecked and reopening never inherits an answer',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      int? answer;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                answer = await spaceLessonAnswer(
                  context,
                  _space().lessons.single,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      FilledButton submit() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, SpaceUiCopy.lessonSubmit),
      );
      expect(submit().onPressed, isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('lesson-answer-1')));
      await tester.tap(find.byKey(const ValueKey('lesson-answer-1')));
      await tester.pumpAndSettle();
      expect(submit().onPressed, isNotNull);
      await tester.tap(
        find.widgetWithText(FilledButton, SpaceUiCopy.lessonSubmit),
      );
      await tester.pumpAndSettle();
      expect(answer, 1);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(submit().onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('money request rejects zero and sends exact minor units', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = FamilySession(api: null, vault: _Vault())..connected = true;
    addTearDown(session.dispose);
    final commands = <JsonMap>[];
    await tester.pumpWidget(
      _host(
        SpaceRequestsSection(
          session: session,
          space: _space(),
          actions: _actions(commands),
          childId: 'child',
          adult: false,
        ),
      ),
    );
    await tester.tap(find.widgetWithText(FilledButton, SpaceUiCopy.askMoney));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('space-field-title')),
      'На тетрадь',
    );
    await tester.enterText(
      find.byKey(const ValueKey('space-field-amountMinor')),
      '0',
    );
    await tester.tap(find.widgetWithText(FilledButton, SpaceContent.create));
    await tester.pumpAndSettle();
    expect(commands, isEmpty);
    expect(find.text(SpaceUiCopy.invalidAmount), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('space-field-amountMinor')),
      '1,25',
    );
    await tester.tap(find.widgetWithText(FilledButton, SpaceContent.create));
    await tester.pumpAndSettle();
    expect(commands.single, {
      'type': 'request.create',
      'childId': 'child',
      'kind': 'money',
      'title': 'На тетрадь',
      'amountMinor': 125,
    });
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'schedule bounds retries, requires weekdays and previews multiple days',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final session = FamilySession(api: null, vault: _Vault())
        ..connected = true;
      addTearDown(session.dispose);
      final commands = <JsonMap>[];
      await tester.pumpWidget(
        _host(
          SpaceSchedulesSection(
            session: session,
            space: _space(),
            actions: _actions(commands),
            childId: 'child',
            adult: true,
          ),
        ),
      );
      await tester.tap(
        find.widgetWithText(FilledButton, SpaceUiCopy.createSchedule),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('space-field-title')),
        'Карманные',
      );
      await tester.enterText(
        find.byKey(const ValueKey('space-field-amountMinor')),
        '10',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('space-field-retryLimit')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('space-field-retryLimit')),
        '4',
      );
      await tester.tap(find.widgetWithText(FilledButton, SpaceUiCopy.save));
      await tester.pumpAndSettle();
      expect(commands, isEmpty);
      expect(find.text(SpaceUiCopy.invalidNumber), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('space-field-retryLimit')),
        '0',
      );
      await tester.tap(find.widgetWithText(FilledButton, SpaceUiCopy.save));
      await tester.pumpAndSettle();
      expect(commands, isEmpty);
      final saveDays = find.byKey(const ValueKey('schedule-weekdays-save'));
      expect(tester.widget<FilledButton>(saveDays).onPressed, isNull);
      await tester.tap(find.byKey(const ValueKey('schedule-weekday-1')));
      await tester.ensureVisible(
        find.byKey(const ValueKey('schedule-weekday-5')),
      );
      await tester.tap(find.byKey(const ValueKey('schedule-weekday-5')));
      await tester.pumpAndSettle();
      await tester.tap(saveDays);
      await tester.pumpAndSettle();
      expect(commands, isEmpty);
      expect(find.byKey(const ValueKey('schedule-preview')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('schedule-preview-confirm')));
      await tester.pumpAndSettle();
      expect(commands.single['type'], 'allowance.create');
      expect(commands.single['weekdays'], [1, 5]);
      expect(commands.single['amountMinor'], 1000);
      expect(commands.single['retryLimit'], 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'edit sends a full update with original entity ID only after preview',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final session = FamilySession(api: null, vault: _Vault())
        ..connected = true;
      addTearDown(session.dispose);
      final commands = <JsonMap>[];
      await tester.pumpWidget(
        _host(
          SpaceSchedulesSection(
            session: session,
            space: _space(),
            actions: _actions(commands),
            childId: 'child',
            adult: true,
          ),
        ),
      );
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, SpaceControlContent.editSchedule),
      );
      await tester.tap(
        find.widgetWithText(FilledButton, SpaceControlContent.editSchedule),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('space-field-amountMinor')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('space-field-amountMinor')),
        '12,50',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('space-field-retryLimit')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('space-field-retryLimit')),
        '2',
      );
      await tester.tap(find.widgetWithText(FilledButton, SpaceUiCopy.save));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CheckboxListTile>(
              find.byKey(const ValueKey('schedule-weekday-1')),
            )
            .value,
        isTrue,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('schedule-weekday-5')),
      );
      await tester.tap(find.byKey(const ValueKey('schedule-weekday-5')));
      await tester.tap(find.byKey(const ValueKey('schedule-weekdays-save')));
      await tester.pumpAndSettle();
      expect(commands, isEmpty);
      expect(
        find.text(SpaceControlContent.schedulePreviewBody),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('schedule-preview-confirm')));
      await tester.pumpAndSettle();
      expect(commands.single, {
        'type': 'allowance.update',
        'childId': 'child',
        'entityId': 'schedule',
        'title': 'На неделю',
        'amountMinor': 1250,
        'frequency': 'weekly',
        'weekdays': [1, 5],
        'monthDay': 0,
        'nextDate': _space().allowances.single.nextDate,
        'retryLimit': 2,
      });
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'starter profile is optional and preserves other rules after confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final session = _RecordingSession();
      addTearDown(session.dispose);
      await tester.pumpWidget(
        _host(
          SpaceSettingsSection(
            session: session,
            space: _space(),
            actions: _actions([]),
            childId: 'child',
            adult: true,
          ),
        ),
      );
      final choose = find.byKey(const ValueKey('choose-policy-preset'));
      await tester.ensureVisible(choose);
      expect(session.calls, isEmpty);
      await tester.tap(choose);
      await tester.pumpAndSettle();
      final preset = SpacePolicyPresets.values.last;
      final option = find.byKey(ValueKey('policy-preset-${preset.id.name}'));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('policy-preview')), findsOneWidget);
      expect(find.text(preset.title), findsOneWidget);
      expect(session.calls, isEmpty);
      await tester.tap(find.widgetWithText(TextButton, SpaceUiCopy.cancel));
      await tester.pumpAndSettle();
      expect(session.calls, isEmpty);
      await tester.ensureVisible(choose);
      await tester.tap(choose);
      await tester.pumpAndSettle();
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('policy-preview-confirm')));
      await tester.pumpAndSettle();
      expect(session.calls.single.method, 'PATCH');
      expect(session.calls.single.path, '/v1/children/child/policy');
      expect(session.calls.single.body, {
        'payments': false,
        'transfers': true,
        'internet': true,
        'dailyLimit': preset.dailyMinor,
        'monthlyLimit': preset.monthlyMinor,
        'approvalThreshold': preset.approvalMinor,
        'categories': {
          'food': true,
          'transport': false,
          'entertainment': false,
          'other': true,
        },
      });
      expect(tester.takeException(), isNull);
    },
  );
}
