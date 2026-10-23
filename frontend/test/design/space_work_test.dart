import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/core/config/space_content.dart';
import 'package:moby_demo/core/config/space_ui_content.dart';
import 'package:moby_demo/core/config/space_work_content.dart';
import 'package:moby_demo/core/theme/mt_brand_theme.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/family_space.dart';
import 'package:moby_demo/data/server/session_vault.dart';
import 'package:moby_demo/features/space/space_components.dart';
import 'package:moby_demo/features/space/space_work_sections.dart';

class _Vault implements SessionVault {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String value) async {}
}

JsonMap _snapshot() => {
  'familySpace': <String, dynamic>{
    'goals': <JsonMap>[],
    'tasks': <JsonMap>[],
    'errands': <JsonMap>[],
    'allowances': [],
    'installments': [],
    'requests': [],
    'settings': <String, dynamic>{},
    'learning': [],
    'lessons': [],
    'weekly': [],
  },
};

Widget _app(Widget child) => MaterialApp(
  theme: buildMtBrandTheme(),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: child,
    ),
  ),
);
SpaceActions _actions(List<JsonMap> commands, {bool busy = false}) =>
    SpaceActions(
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

void main() {
  testWidgets('own-money acceptance needs fresh unchecked explicit consent', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showSpaceOwnMoneyConsent(context);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const ValueKey('space-own-money-consent')),
          )
          .value,
      isFalse,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('space-own-money-confirm')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('space-own-money-consent')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('space-own-money-confirm')),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const ValueKey('space-own-money-confirm')));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const ValueKey('space-own-money-consent')),
          )
          .value,
      isFalse,
    );
    await tester.tap(find.text(SpaceContent.cancel));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('adult can cancel accepted task only after providing reason', (
    tester,
  ) async {
    final session = FamilySession(api: null, vault: _Vault())..connected = true;
    addTearDown(session.dispose);
    final snapshot = _snapshot();
    snapshot['familySpace']['tasks'] = <JsonMap>[
      {
        'id': 'task-a',
        'childId': 'a',
        'title': 'Разобрать книги',
        'rewardMinor': 500,
        'status': 'accepted',
        'cancelRequested': false,
      },
    ];
    session.snapshot = snapshot;
    final commands = <JsonMap>[];
    await tester.pumpWidget(
      _app(
        SpaceTasksSection(
          session: session,
          space: FamilySpace.fromSnapshot(snapshot),
          actions: _actions(commands),
          childId: 'a',
          adult: true,
        ),
      ),
    );
    await tester.tap(find.text(SpaceWorkContent.taskCancel));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, SpaceContent.actionLabel('cancel')),
    );
    await tester.pumpAndSettle();
    expect(find.text(SpaceUiCopy.fieldRequired), findsOneWidget);
    expect(commands, isEmpty);
    await tester.enterText(
      find.byKey(const ValueKey('space-field-reason')),
      'Планы семьи изменились',
    );
    await tester.tap(
      find.widgetWithText(FilledButton, SpaceContent.actionLabel('cancel')),
    );
    await tester.pumpAndSettle();
    expect(commands.single, {
      'type': 'task.action',
      'childId': 'a',
      'entityId': 'task-a',
      'action': 'cancel',
      'reason': 'Планы семьи изменились',
    });
  });

  testWidgets('goal creation rejects zero and fractional kopecks', (
    tester,
  ) async {
    final session = FamilySession(api: null, vault: _Vault())..connected = true;
    addTearDown(session.dispose);
    final commands = <JsonMap>[];
    await tester.pumpWidget(
      _app(
        SpaceGoalsSection(
          session: session,
          space: FamilySpace.fromSnapshot(_snapshot()),
          actions: _actions(commands),
          childId: 'a',
          adult: false,
        ),
      ),
    );
    await tester.tap(find.widgetWithText(TextButton, SpaceContent.create));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('space-field-title')),
      'Наушники',
    );
    for (final invalid in ['0', '1.001']) {
      await tester.enterText(
        find.byKey(const ValueKey('space-field-targetMinor')),
        invalid,
      );
      await tester.tap(find.widgetWithText(FilledButton, SpaceContent.create));
      await tester.pumpAndSettle();
      expect(find.text(SpaceUiCopy.invalidAmount), findsOneWidget);
      expect(commands, isEmpty);
    }
    await tester.enterText(
      find.byKey(const ValueKey('space-field-targetMinor')),
      '50,25',
    );
    await tester.tap(find.widgetWithText(FilledButton, SpaceContent.create));
    await tester.pumpAndSettle();
    expect(commands.single['targetMinor'], 5025);
    expect(commands.single['type'], 'goal.create');
  });

  testWidgets('recorded expenses prevent cancel and over-budget submission', (
    tester,
  ) async {
    final session = FamilySession(api: null, vault: _Vault())..connected = true;
    addTearDown(session.dispose);
    final snapshot = _snapshot();
    snapshot['familySpace']['errands'] = <JsonMap>[
      {
        'id': 'errand-a',
        'childId': 'a',
        'title': 'Продукты',
        'budgetMinor': 2000,
        'rewardMinor': 100,
        'actualMinor': 1500,
        'returnedMinor': 0,
        'funding': 'reimburse',
        'status': 'clarification',
        'ownMoneyConsent': true,
        'cancelRequested': false,
        'returnConfirmed': false,
      },
    ];
    session.snapshot = snapshot;
    final commands = <JsonMap>[];
    final space = FamilySpace.fromSnapshot(snapshot);
    await tester.pumpWidget(
      _app(
        SpaceErrandsSection(
          session: session,
          space: space,
          actions: _actions(commands),
          childId: 'a',
          adult: true,
        ),
      ),
    );
    expect(find.text(SpaceWorkContent.errandCancel), findsNothing);
    expect(find.text(SpaceWorkContent.expenseProtected), findsOneWidget);
    await tester.pumpWidget(
      _app(
        SpaceErrandsSection(
          session: session,
          space: space,
          actions: _actions(commands),
          childId: 'a',
          adult: false,
        ),
      ),
    );
    await tester.tap(find.text(SpaceUiCopy.submitExpense));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('space-field-amountMinor')),
      '25',
    );
    await tester.tap(
      find.widgetWithText(FilledButton, SpaceContent.actionLabel('submit')),
    );
    await tester.pumpAndSettle();
    expect(find.text(SpaceUiCopy.invalidAmount), findsOneWidget);
    expect(commands, isEmpty);
  });

  testWidgets('offline work actions remain disabled', (tester) async {
    final session = FamilySession(api: null, vault: _Vault());
    addTearDown(session.dispose);
    await tester.pumpWidget(
      _app(
        SpaceTasksSection(
          session: session,
          space: FamilySpace.fromSnapshot(_snapshot()),
          actions: _actions([]),
          childId: 'a',
          adult: true,
        ),
      ),
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, SpaceUiCopy.newTask),
          )
          .onPressed,
      isNull,
    );
  });
}
