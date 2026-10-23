import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/app/router.dart';
import 'package:moby_demo/core/config/space_content.dart';
import 'package:moby_demo/core/config/space_navigation_content.dart';
import 'package:moby_demo/core/config/space_control_content.dart';
import 'package:moby_demo/core/config/space_ui_content.dart';
import 'package:moby_demo/core/theme/app_theme.dart';
import 'package:moby_demo/data/server/family_space.dart';
import 'package:moby_demo/features/space/space_components.dart';
import 'package:moby_demo/features/space/space_pages.dart';

import '../support/space_fixture.dart';

class _Harness {
  _Harness(this.api, this.session, this.container, this.router, this.boundary);
  final SpacePreviewApi api;
  final SpacePreviewSession session;
  final ProviderContainer container;
  final GoRouter router;
  final GlobalKey boundary;
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    session.dispose();
  }
}

Future<_Harness> _pump(
  WidgetTester tester, {
  String? childId,
  String? location,
  double width = 390,
  double scale = 1,
  double height = 844,
  EdgeInsets safePadding = EdgeInsets.zero,
  void Function(Map<String, dynamic>)? configure,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final api = SpacePreviewApi(childId: childId);
  configure?.call(api.data);
  final session = SpacePreviewSession(api);
  expect(FamilySpace.fromSnapshot(session.snapshot).isAvailable, isTrue);
  final container = ProviderContainer(
    overrides: [familySessionProvider.overrideWithValue(session)],
  );
  final router = container.read(appRouterProvider)
    ..go(location ?? (childId == null ? '/family/space' : '/child/home'));
  final key = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: key,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: buildMobyTheme(),
          locale: const Locale('ru'),
          supportedLocales: const [Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: safePadding,
              textScaler: TextScaler.linear(scale),
              disableAnimations: true,
            ),
            child: child!,
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    for (final asset in [
      SpaceAssets.allowance,
      SpaceAssets.goal,
      SpaceAssets.reward,
      SpaceAssets.learning,
    ]) {
      await precacheImage(AssetImage(asset), key.currentContext!);
    }
    // Complete SourceIcon SVG reads outside the fake test clock.
    await Future<void>.delayed(const Duration(milliseconds: 80));
  });
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return _Harness(api, session, container, router, key);
}

Future<void> _capture(
  WidgetTester tester,
  _Harness harness,
  String name,
) async {
  final directory = Platform.environment['MOBY_CAPTURE_DIR'];
  if (directory == null) return;
  Directory(directory).createSync(recursive: true);
  final boundary =
      harness.boundary.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
  void repaint(RenderObject node) {
    node.visitChildren(repaint);
    node.markNeedsPaint();
  }

  repaint(boundary);
  await tester.pump();
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2));
  final bytes = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.png),
  );
  File('$directory/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  image!.dispose();
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  // ListView may not have built a distant row; Finder.first throws while absent.
  for (var attempt = 0; attempt < 40; attempt++) {
    var built = false;
    try {
      built = target.evaluate().isNotEmpty;
    } on StateError {
      built = false;
    }
    if (built) break;
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -280));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> _nav(WidgetTester tester, String label) async {
  if (label == SpaceContent.profile) {
    await _reveal(tester, find.byTooltip(SpaceContent.profile));
    await tester.tap(find.byTooltip(SpaceContent.profile).hitTestable().first);
    await tester.pumpAndSettle();
    return;
  }
  final nav = find.byWidgetPredicate(
    (widget) =>
        widget is Semantics &&
        widget.properties.label == label &&
        widget.properties.button == true,
  );
  expect(nav.hitTestable(), findsOneWidget);
  await tester.tap(nav);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void _expectChildNav(WidgetTester tester) {
  for (final label in SpaceContent.childNav) {
    final nav = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == label &&
          widget.properties.button == true,
    );
    expect(nav.hitTestable(), findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: nav, matching: find.text(label)),
    );
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: 'Navigation label must remain fully visible: $label',
    );
  }
}

void _expectAdultNav() {
  for (final label in ['Главная', 'Продукты', 'Детям', 'Чат', 'Ещё']) {
    expect(find.text(label).hitTestable(), findsOneWidget);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/reference/font/inter_regular.ttf'))
      ..addFont(rootBundle.load('assets/reference/font/inter_medium.ttf'))
      ..addFont(rootBundle.load('assets/reference/font/inter_semi_bold.ttf'))
      ..addFont(rootBundle.load('assets/reference/font/inter_bold.ttf'));
    final display = FontLoader('TikTokSans')
      ..addFont(rootBundle.load('assets/brand/fonts/TikTokSans.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    final legacy = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/reference/font/montserrat_regular.ttf'))
      ..addFont(rootBundle.load('assets/reference/font/montserrat_medium.ttf'))
      ..addFont(
        rootBundle.load('assets/reference/font/montserrat_semi_bold.ttf'),
      )
      ..addFont(rootBundle.load('assets/reference/font/montserrat_bold.ttf'));
    await Future.wait([
      inter.load(),
      display.load(),
      icons.load(),
      legacy.load(),
    ]);
  });

  // Production family routes are intentionally compile-time gated. Run this
  // suite with --dart-define=MOBY_API_URL=https://moby-preview.invalid.
  group('actual v2 router previews', skip: !familyApiEnabled, () {
    for (final scale in [1.0, 1.3]) {
      testWidgets('family hub v2 scroll and child taps at scale $scale', (
        tester,
      ) async {
        final h = await _pump(
          tester,
          location: '/family',
          width: 360,
          height: 800,
          scale: scale,
          safePadding: const EdgeInsets.only(top: 24, bottom: 24),
          configure: (data) {
            final children = data['children'] as List;
            for (var i = 3; i <= 5; i++) {
              children.add({
                ...children.first as Map<String, dynamic>,
                'id': 'scroll-child-$i',
                'displayName': 'Ребёнок $i',
              });
            }
          },
        );
        await _capture(tester, h, 'family-hub-top-360-scale$scale');
        expect(find.text('Михаил').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Михаил'));
        await tester.pumpAndSettle();
        expect(h.router.state.uri.path, '/family/child/$spaceJuniorId');
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(h.router.state.uri.path, '/family');
        final scroll = find.byType(Scrollable).first;
        final before = tester.state<ScrollableState>(scroll).position.pixels;
        await tester.drag(scroll, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(
          tester.state<ScrollableState>(scroll).position.pixels,
          greaterThan(before),
        );
        for (
          var gesture = 0;
          gesture < 8 &&
              find.text('Ребёнок 5').hitTestable().evaluate().isEmpty;
          gesture++
        ) {
          await tester.drag(scroll, const Offset(0, -250));
          await tester.pumpAndSettle();
        }
        expect(find.text('Ребёнок 5').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Ребёнок 5'));
        await tester.pumpAndSettle();
        expect(h.router.state.uri.path, '/family/child/scroll-child-5');
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        for (
          var gesture = 0;
          gesture < 8 &&
              find
                  .text(SpaceUiCopy.familyWallet)
                  .hitTestable()
                  .evaluate()
                  .isEmpty;
          gesture++
        ) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, 250),
          );
          await tester.pumpAndSettle();
        }
        expect(
          find.text(SpaceUiCopy.familyWallet).hitTestable(),
          findsOneWidget,
        );
        await _capture(tester, h, 'family-hub-scrolled-360-scale$scale');
        await tester.tap(find.text(SpaceUiCopy.familyWallet));
        await tester.pumpAndSettle();
        expect(find.byType(SpaceAdultPage), findsOneWidget);
        expect(find.text('Михаил'), findsNothing);
        expect(tester.takeException(), isNull);
        await h.close(tester);
      });
    }

    testWidgets(
      'family routes reserve footer viewport and last action is reachable',
      (tester) async {
        for (final scale in [1.0, 1.3]) {
          final h = await _pump(
            tester,
            location: '/family/child/$spaceJuniorId',
            width: 360,
            height: 800,
            scale: scale,
            safePadding: const EdgeInsets.only(top: 24, bottom: 34),
          );
          final footer = find
              .ancestor(of: find.text('Детям'), matching: find.byType(InkWell))
              .first;
          for (final path in [
            '/family',
            '/family/space',
            '/family/child/$spaceJuniorId',
            for (final section in SpaceNavigationContent.sections.keys)
              '/family/child/$spaceJuniorId/$section',
            '/family/apply',
            '/family/inbox',
          ]) {
            h.router.go(path);
            await tester.pumpAndSettle();
            final scroll = find.byType(Scrollable).first;
            expect(
              tester.getRect(scroll).bottom,
              lessThanOrEqualTo(tester.getRect(footer).top),
              reason: '$path must end above the navigation at scale $scale',
            );
          }
          h.router.go('/family/child/$spaceJuniorId');
          await tester.pumpAndSettle();
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -3000),
          );
          await tester.pumpAndSettle();
          final lastAction = find.text('Карта и правила');
          expect(lastAction.hitTestable(), findsOneWidget);
          expect(
            tester.getRect(lastAction).bottom,
            lessThan(tester.getRect(footer).top),
          );
          await tester.tap(lastAction);
          await tester.pumpAndSettle();
          expect(
            h.router.state.uri.path,
            '/family/child/$spaceJuniorId/settings',
          );
          expect(tester.takeException(), isNull);
          await h.close(tester);
        }
      },
    );

    testWidgets('goal amounts show source bounds and maximum never submits', (
      tester,
    ) async {
      final h = await _pump(tester, childId: spaceJuniorId);
      await _nav(tester, SpaceContent.goals);
      final deposit = find.widgetWithText(
        FilledButton,
        SpaceUiCopy.goalDeposit,
      );
      await _reveal(tester, deposit);
      await tester.tap(deposit);
      await tester.pumpAndSettle();
      expect(
        find.text(SpaceUiCopy.availableAmount('50,00 BYN')),
        findsOneWidget,
      );
      final amount = find.byKey(const ValueKey('space-field-amountMinor'));
      await tester.enterText(amount, '50,01');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Подтвердить перемещение'),
      );
      await tester.pumpAndSettle();
      expect(h.api.commands, isEmpty);
      expect(find.text(SpaceUiCopy.amountRange('50,00 BYN')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('space-max-amountMinor')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(amount).controller!.text, '50,00');
      expect(h.api.commands, isEmpty);
      await _capture(tester, h, 'goal-amount-maximum-390');
      await tester.tap(find.widgetWithText(TextButton, SpaceUiCopy.cancel));
      await tester.pumpAndSettle();
      final withdraw = find.widgetWithText(
        TextButton,
        SpaceUiCopy.goalWithdraw,
      );
      await _reveal(tester, withdraw);
      await tester.tap(withdraw);
      await tester.pumpAndSettle();
      expect(
        find.text(SpaceUiCopy.availableAmount('20,00 BYN')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('space-max-amountMinor')));
      expect(tester.widget<TextFormField>(amount).controller!.text, '20,00');
      expect(h.api.commands, isEmpty);
      await tester.tap(find.widgetWithText(TextButton, SpaceUiCopy.cancel));
      await h.close(tester);
    });

    testWidgets('approved rebrand family and teen captures', (tester) async {
      var h = await _pump(
        tester,
        location: '/family',
        configure: (data) {
          final requests = data['familySpace']['requests'] as List;
          final request = requests.first as Map<String, dynamic>;
          request['kind'] = 'money';
          request['amountMinor'] = 2000;
          request['title'] = 'На покупку';
        },
      );
      await _capture(tester, h, 'family-hub-390');
      await tester.tap(find.byTooltip(SpaceContent.notifications));
      await tester.pumpAndSettle();
      expect(find.byType(SpaceInboxPage), findsOneWidget);
      await _capture(tester, h, 'adult-inbox-390');
      await h.close(tester);
      h = await _pump(
        tester,
        childId: spaceTeenId,
        configure: (data) {
          data['familySpace']['learning'] = [];
        },
      );
      await _nav(tester, SpaceContent.childNav[4]);
      await _capture(tester, h, 'teen-learning-390');
      await h.close(tester);
    });

    testWidgets(
      'child top-up fixes recipient and rejects empty or zero amounts',
      (tester) async {
        final h = await _pump(tester, location: '/family/child/$spaceTeenId');
        await tester.tap(
          find.widgetWithText(FilledButton, SpaceUiCopy.topUpChild),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DropdownButtonFormField<String>), findsNothing);
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.textContaining('Александра ·'), findsOneWidget);
        await tester.tap(
          find.widgetWithText(FilledButton, SpaceUiCopy.moneyTransfer),
        );
        await tester.pumpAndSettle();
        expect(h.api.commands, isEmpty);
        await tester.enterText(find.byType(TextFormField), '0');
        await tester.tap(
          find.widgetWithText(FilledButton, SpaceUiCopy.moneyTransfer),
        );
        await tester.pumpAndSettle();
        expect(h.api.commands, isEmpty);
        await tester.enterText(find.byType(TextFormField), '12,34');
        await tester.tap(
          find.widgetWithText(FilledButton, SpaceUiCopy.moneyTransfer),
        );
        await tester.pumpAndSettle();
        expect(h.api.commands.single['type'], 'wallet.transfer');
        expect(h.api.commands.single['childId'], spaceTeenId);
        expect(h.api.commands.single['amountMinor'], 1234);
        expect(
          h.session.children.singleWhere(
            (c) => c['id'] == spaceJuniorId,
          )['balanceMinor'],
          5000,
        );
        expect(
          h.session.children.singleWhere(
            (c) => c['id'] == spaceTeenId,
          )['balanceMinor'],
          13234,
        );
        expect(tester.takeException(), isNull);
        await h.close(tester);
      },
    );

    testWidgets('family hub two children native preview', (tester) async {
      final h = await _pump(
        tester,
        location: '/family',
        width: 360,
        height: 800,
        safePadding: const EdgeInsets.only(top: 24, bottom: 24),
      );
      await _capture(tester, h, 'family-hub-two-children-360');
      await h.close(tester);
    });

    testWidgets(
      'v2 enrollment keeps phone access without duplicate financial controls',
      (tester) async {
        final h = await _pump(
          tester,
          location: '/family/child/$spaceJuniorId/setup',
        );
        expect(find.text('Подключить телефон'), findsOneWidget);
        expect(find.text(SpaceUiCopy.blockCard), findsNothing);
        expect(find.text(SpaceUiCopy.topUpChild), findsNothing);
        expect(find.text('Возможности'), findsNothing);
        expect(find.text('История'), findsNothing);
        await h.close(tester);
      },
    );

    testWidgets(
      'old pending purchase stays actionable beyond sixty newer completed operations',
      (tester) async {
        final h = await _pump(
          tester,
          location: '/family/child/$spaceJuniorId',
          configure: (data) {
            final operations = data['operations'] as List;
            final base = operations.first as Map<String, dynamic>;
            operations.add({
              ...base,
              'id': 'old-pending',
              'merchant': 'Старая покупка',
              'status': 'pending',
              'createdAt': 1,
            });
            for (var i = 0; i < 65; i++) {
              operations.add({
                ...base,
                'id': 'done-$i',
                'status': 'done',
                'createdAt': 1792454400 + i,
              });
            }
            operations.add({
              ...base,
              'id': 'sibling-pending',
              'childId': spaceTeenId,
              'status': 'pending',
            });
          },
        );
        expect(find.textContaining('Ждут решения: 2'), findsOneWidget);
        await _reveal(tester, find.text('Деньги').last);
        await tester.tap(find.text('Деньги').last);
        await tester.pumpAndSettle();
        expect(find.text('Старая покупка').hitTestable(), findsOneWidget);
        expect(find.text('Старая покупка'), findsOneWidget);
        expect(
          find
              .descendant(
                of: find
                    .ancestor(
                      of: find.text('Старая покупка'),
                      matching: find.byType(SpacePanel),
                    )
                    .first,
                matching: find.text(SpaceContent.actionLabel('approve')),
              )
              .hitTestable(),
          findsOneWidget,
        );
        await _capture(tester, h, 'adult-pending-before-schedules-390');
        await h.close(tester);
      },
    );

    testWidgets('protective block is first and uses durable block command', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        location: '/family/child/$spaceJuniorId/settings',
        width: 360,
        scale: 1.3,
      );
      final block = find.text(SpaceUiCopy.blockCard);
      expect(block.hitTestable(), findsOneWidget);
      await tester.tap(block);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, SpaceUiCopy.continueLabel),
      );
      await tester.pumpAndSettle();
      expect(h.api.commands.single['type'], 'card.block');
      expect(h.api.commands.single['childId'], spaceJuniorId);
      expect(find.text(SpaceUiCopy.unblockCard).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await h.close(tester);
    });

    testWidgets(
      'protective lane finishes while a real money command response is held',
      (tester) async {
        final h = await _pump(
          tester,
          location: '/family/child/$spaceJuniorId/settings',
        );
        late SpaceActions current;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: h.container,
            child: MaterialApp(
              home: SpaceSessionView(
                builder: (context, session, space, actions) {
                  current = actions;
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final held = Completer<void>();
        final entered = Completer<void>();
        h.api.beforeCommand = (command) async {
          if (command['type'] == 'wallet.transfer') {
            entered.complete();
            await held.future;
          }
        };
        final ongoing = current.run({
          'type': 'wallet.transfer',
          'childId': spaceJuniorId,
          'amountMinor': 100,
        });
        await tester.pumpAndSettle();
        expect(entered.isCompleted, isTrue);
        var blocked = false;
        final blocking = current
            .run({'type': 'card.block', 'childId': spaceJuniorId})
            .then((result) => blocked = result);
        try {
          await tester.pumpAndSettle();
          expect(held.isCompleted, isFalse);
          expect(h.api.commands.single['type'], 'card.block');
          expect(
            blocked,
            isTrue,
            reason: 'Protection must not wait for the locked money-intent lane',
          );
          expect(current.protectiveBusy, isFalse);
          expect(current.busy, isTrue);
        } finally {
          held.complete();
          await ongoing;
          await blocking;
        }
        await tester.pumpAndSettle();
        expect(current.busy, isFalse);
        expect(
          h.session.children.singleWhere(
            (c) => c['id'] == spaceJuniorId,
          )['cardStatus'],
          'blocked',
        );
        await h.close(tester);
      },
    );

    final scenarios = <(String, String?, String, String?, String)>[
      (
        'adult-family-wallet',
        null,
        '/family/space',
        null,
        SpaceUiCopy.distribute,
      ),
      (
        'adult-child-overview',
        null,
        '/family/child/$spaceJuniorId',
        null,
        SpaceUiCopy.topUpChild,
      ),
      (
        'child10-home',
        spaceJuniorId,
        '/child/home',
        null,
        SpaceUiCopy.askMoney,
      ),
      ('teen16-home', spaceTeenId, '/child/home', null, SpaceUiCopy.toGoal),
      (
        'child-goals',
        spaceJuniorId,
        '/child/home',
        SpaceContent.goals,
        SpaceContent.create,
      ),
      (
        'adult-work',
        null,
        '/family/child/$spaceJuniorId?section=work',
        null,
        SpaceUiCopy.newTask,
      ),
      (
        'adult-controls',
        null,
        '/family/child/$spaceJuniorId?section=settings',
        null,
        SpaceControlContent.editPolicy,
      ),
      (
        'child-lessons',
        spaceJuniorId,
        '/child/home',
        SpaceContent.childNav[4],
        SpaceControlContent.beginLesson,
      ),
      (
        'adult-setup',
        null,
        '/family/child/$spaceJuniorId/setup',
        null,
        'Подключить телефон',
      ),
      (
        'adult-money',
        null,
        '/family/child/$spaceJuniorId?section=money',
        null,
        SpaceUiCopy.createSchedule,
      ),
      (
        'adult-goals',
        null,
        '/family/child/$spaceJuniorId?section=goals',
        null,
        SpaceUiCopy.matching,
      ),
      (
        'adult-learning',
        null,
        '/family/child/$spaceJuniorId?section=growth',
        null,
        SpaceControlContent.childProgress,
      ),
      ('adult-inbox', null, '/family/inbox', null, SpaceContent.notifications),
      (
        'child-money',
        spaceJuniorId,
        '/child/home',
        SpaceContent.money,
        SpaceUiCopy.purchase,
      ),
      (
        'child-more',
        spaceJuniorId,
        '/child/home',
        SpaceContent.profile,
        SpaceUiCopy.familyRules,
      ),
    ];
    for (final (width, scale) in [(390.0, 1.0), (360.0, 1.3)]) {
      for (final (name, childId, location, tab, cta) in scenarios) {
        testWidgets('$name ${width.toInt()}px scale $scale real fonts/assets', (
          tester,
        ) async {
          final harness = await _pump(
            tester,
            childId: childId,
            location: location,
            width: width,
            scale: scale,
          );
          if (tab != null) await _nav(tester, tab);
          if (childId == null) {
            _expectAdultNav();
          } else {
            _expectChildNav(tester);
          }
          final prefix = '$name-${width.toInt()}-scale$scale';
          await _capture(tester, harness, '$prefix-top');
          final action = find.text(cta).first;
          await _reveal(tester, action);
          await _capture(tester, harness, '$prefix-action');
          expect(harness.api.commands, isEmpty);
          expect(tester.takeException(), isNull);
          await harness.close(tester);
        });
      }
    }

    for (final (width, scale) in [(390.0, 1.0), (360.0, 1.3)]) {
      testWidgets(
        'all child navigation, goal save, rules request and logout reachable ${width.toInt()}',
        (tester) async {
          final harness = await _pump(
            tester,
            childId: spaceJuniorId,
            width: width,
            scale: scale,
          );
          final beforePolicy = jsonEncode(harness.session.child!['policy']);
          expect(harness.session.children.single['id'], spaceJuniorId);
          expect(
            harness.session.snapshot!['familySpace']['adultWallet'],
            isNull,
          );
          expect(harness.session.snapshot!['preferences'], isNull);
          expect(find.text('Александра'), findsNothing);
          await _nav(tester, SpaceContent.money);
          expect(find.text(SpaceUiCopy.purchase), findsOneWidget);
          await _nav(tester, SpaceContent.goals);
          await tester.tap(
            find.widgetWithText(TextButton, SpaceContent.create),
          );
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('space-field-title')),
            'Новая поездка',
          );
          await tester.enterText(
            find.byKey(const ValueKey('space-field-targetMinor')),
            '80,50',
          );
          await tester.tap(
            find.widgetWithText(FilledButton, SpaceContent.create),
          );
          await tester.pumpAndSettle();
          expect(harness.api.commands.single['type'], 'goal.create');
          expect(harness.api.commands.single['targetMinor'], 8050);
          expect(
            (harness.api.commands.single['idempotencyKey'] as String).length,
            greaterThanOrEqualTo(8),
          );
          expect(
            FamilySpace.fromSnapshot(
              harness.session.snapshot,
            ).goal('created-goal')!.title,
            'Новая поездка',
          );
          await _reveal(tester, find.text('Новая поездка'));
          await _capture(tester, harness, 'goal-created-${width.toInt()}');
          await _nav(tester, SpaceContent.childNav[4]);
          final lessonButton = find
              .byKey(const ValueKey('lesson-open-needs-wants'))
              .first;
          await _reveal(tester, lessonButton);
          await tester.tap(lessonButton);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilledButton>(
                  find.widgetWithText(FilledButton, SpaceUiCopy.lessonSubmit),
                )
                .onPressed,
            isNull,
          );
          await tester.tap(find.byKey(const ValueKey('lesson-answer-0')));
          await tester.pumpAndSettle();
          await _capture(tester, harness, 'lesson-question-${width.toInt()}');
          await tester.tap(
            find.widgetWithText(FilledButton, SpaceUiCopy.lessonSubmit),
          );
          await tester.pumpAndSettle();
          expect(
            FamilySpace.fromSnapshot(
              harness.session.snapshot,
            ).lessonCompleted(spaceJuniorId, 'needs-wants'),
            isTrue,
          );
          expect(jsonEncode(harness.session.child!['policy']), beforePolicy);
          await _nav(tester, SpaceContent.profile);
          await tester.tap(find.text(SpaceUiCopy.familyRules));
          await tester.pumpAndSettle();
          final requestPolicy = find.widgetWithText(
            FilledButton,
            SpaceUiCopy.requestPolicy,
          );
          await _reveal(tester, requestPolicy);
          await tester.tap(requestPolicy);
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('space-field-title')),
            'Лимит на поездку',
          );
          final daily = find.byKey(const ValueKey('space-field-dailyLimit'));
          await _reveal(tester, daily);
          await tester.enterText(daily, '60');
          await tester.tap(find.widgetWithText(FilledButton, SpaceUiCopy.save));
          await tester.pumpAndSettle();
          expect(harness.api.commands.last['type'], 'request.create');
          expect(harness.api.commands.last['kind'], 'policy');
          expect(harness.api.commands.last['policy']['dailyLimit'], 6000);
          expect(jsonEncode(harness.session.child!['policy']), beforePolicy);
          await _nav(tester, SpaceContent.home);
          expect(find.text(SpaceUiCopy.askMoney), findsOneWidget);
          await _nav(tester, SpaceContent.profile);
          final logout = find.widgetWithText(
            OutlinedButton,
            SpaceUiCopy.logout,
          );
          await _reveal(tester, logout);
          await tester.tap(logout);
          await tester.pumpAndSettle();
          expect(find.text(SpaceUiCopy.logoutBody), findsOneWidget);
          expect(
            find.widgetWithText(FilledButton, SpaceUiCopy.logout).hitTestable(),
            findsOneWidget,
          );
          await _capture(tester, harness, 'logout-confirm-${width.toInt()}');
          await tester.tap(find.widgetWithText(TextButton, SpaceUiCopy.cancel));
          await tester.pumpAndSettle();
          expect(harness.session.phase, FamilySessionPhase.signedIn);
          expect(tester.takeException(), isNull);
          await harness.close(tester);
        },
      );
    }

    for (final (width, scale) in [(390.0, 1.0), (360.0, 1.3)]) {
      for (final (name, label) in [
        ('rules', SpaceUiCopy.familyRules),
        ('history', SpaceContent.history),
        ('inbox', SpaceContent.notifications),
        ('products', SpaceUiCopy.products),
        ('help', SpaceUiCopy.support),
      ]) {
        testWidgets('child detail $name ${width.toInt()}', (tester) async {
          final harness = await _pump(
            tester,
            childId: spaceJuniorId,
            width: width,
            scale: scale,
          );
          await _nav(tester, SpaceContent.profile);
          final link = find.text(label).first;
          await _reveal(tester, link);
          await tester.tap(link);
          await tester.pumpAndSettle();
          await _capture(
            tester,
            harness,
            'child-$name-${width.toInt()}-scale$scale-top',
          );
          expect(tester.takeException(), isNull);
          _expectChildNav(tester);
          expect(harness.api.commands, isEmpty);
          await harness.close(tester);
        });
      }
    }

    for (final (name, childId, status, location, tab) in [
      (
        'child-work-submitted',
        spaceJuniorId,
        'submitted',
        '/child/home',
        SpaceContent.tasks,
      ),
      (
        'adult-work-approved',
        null,
        'approved',
        '/family/child/$spaceJuniorId?section=work',
        null,
      ),
    ]) {
      testWidgets('presentation state $name', (tester) async {
        final harness = await _pump(
          tester,
          childId: childId,
          location: location,
          configure: (data) {
            final space = data['familySpace'] as Map<String, dynamic>;
            for (final task in space['tasks'] as List) {
              task['status'] = status;
            }
          },
        );
        if (tab != null) await _nav(tester, tab);
        await _reveal(tester, find.text('Помочь с покупками').first);
        await _capture(tester, harness, '$name-390-scale1.0-action');
        expect(tester.takeException(), isNull);
        expect(harness.api.commands, isEmpty);
        await harness.close(tester);
      });
    }

    testWidgets(
      'family child sections preserve router and Android back history',
      (tester) async {
        final h = await _pump(tester, location: '/family', width: 360);
        await tester.tap(find.text('Михаил'));
        await tester.pumpAndSettle();
        expect(find.byType(ChoiceChip), findsNothing);
        for (final entry in SpaceNavigationContent.sections.entries) {
          final row = find.text(entry.value.title).last;
          await _reveal(tester, row);
          await tester.tap(row);
          await tester.pumpAndSettle();
          expect(
            h.router.state.uri.path,
            '/family/child/$spaceJuniorId/${entry.key}',
          );
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(h.router.state.uri.path, '/family/child/$spaceJuniorId');
          expect(tester.takeException(), isNull);
        }
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(h.router.state.uri.path, '/family');
        expect(h.api.commands, isEmpty);
        await h.close(tester);
      },
    );
  });
}
