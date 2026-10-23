import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moby_demo/app/app.dart';
import 'package:moby_demo/app/providers.dart';
import 'package:moby_demo/app/router.dart';
import 'package:moby_demo/core/config/app_copy.dart';
import 'package:moby_demo/core/config/payment_content.dart';
import 'package:moby_demo/core/config/source_credit_repayment_content.dart';
import 'package:moby_demo/core/config/source_catalog_content.dart';
import 'package:moby_demo/core/config/source_exchange_content.dart';
import 'package:moby_demo/core/ui/recorded_cards.dart';
import 'package:moby_demo/core/ui/native_progress.dart';
import 'package:moby_demo/core/ui/source_asset_paths.dart';
import 'package:moby_demo/core/config/recorded_content.dart';
import 'package:moby_demo/core/config/recorded_forms_content.dart';
import 'package:moby_demo/core/config/transfer_content.dart';
import 'package:moby_demo/core/config/chat_content.dart';
import 'package:moby_demo/core/config/source_public_content.dart';
import 'package:moby_demo/core/config/demo_motion.dart';
import 'package:moby_demo/core/config/observed_web_content.dart';
import 'package:moby_demo/features/recorded/recorded_pages.dart';
import 'package:moby_demo/core/config/source_emoji_catalog.dart';
import 'package:moby_demo/core/formatting/formatters.dart';

Future<ProviderContainer> startApp(
  WidgetTester tester, {
  Size size = const Size(360, 800),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  final container = ProviderContainer(
    overrides: [nativeProgressEnabledProvider.overrideWithValue(false)],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const RepaintBoundary(
        key: ValueKey('app-capture'),
        child: MobyApp(),
      ),
    ),
  );
  await settleReplay(tester);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPadding();
    tester.view.resetViewInsets();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  return container;
}

Future<void> settleReplay(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> confirmSwipe(WidgetTester tester) async {
  final finder = find.byKey(const ValueKey('confirm-transfer'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  final bounds = tester.getRect(finder);
  await tester.dragFrom(
    bounds.topLeft + const Offset(22, 22),
    Offset(bounds.width * .85, 0),
  );
  await settleReplay(tester);
}

Future<void> capture(
  WidgetTester tester,
  String name, {
  bool settle = true,
}) async {
  final output = Platform.environment['MOBY_PREVIEW_DIR'];
  if (output == null) return;
  final captureContext = tester.element(
    find.byKey(const ValueKey('app-capture')),
  );
  final imageErrors = <String>[];
  await tester.runAsync(() async {
    final assets = <String>{
      for (final widget in tester.widgetList<Image>(find.byType(Image)))
        if (widget.image is AssetImage) (widget.image as AssetImage).assetName,
      SourceEmojiCatalog.recentAssetPath,
      SourceEmojiCatalog.backspaceAssetPath,
      for (final category in SourceEmojiCatalog.categories)
        category.tabAssetPath,
      for (final emoji in SourceEmojiCatalog.smileysAndPeople.take(60))
        emoji.assetPath,
      ...sourceAssetPaths.values,
    };
    for (final path in assets) {
      if (!captureContext.mounted) return;
      await precacheImage(
        AssetImage(path),
        captureContext,
        onError: (error, stack) => imageErrors.add('$path: $error'),
      );
    }
  });
  expect(imageErrors, isEmpty);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('app-capture')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory(output);
    await directory.create(recursive: true);
    await File('$output/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

// Unlike pixel golden tests, these previews should use Flutter's soft shadows.
class _MobyPreviewBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

void main() {
  _MobyPreviewBinding();
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('ru');
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final family in ['Inter', 'Montserrat']) {
      final loader = FontLoader(family);
      for (final weight in [
        if (family == 'Inter') 'extra_light',
        'regular',
        'medium',
        'semi_bold',
        'bold',
      ]) {
        loader.addFont(
          rootBundle.load(
            'assets/reference/font/${family.toLowerCase()}_$weight.ttf',
          ),
        );
      }
      await loader.load();
    }
  });

  for (final narrow in [false, true]) {
    testWidgets(
      'banner offers keep visible copy and routes${narrow ? " at narrow large text" : ""}',
      (tester) async {
        final container = await startApp(
          tester,
          size: narrow ? const Size(320, 740) : const Size(360, 800),
          textScale: narrow ? 1.3 : 1,
        );
        final scenario = container.read(bankRepositoryProvider).scenario;
        final router = container.read(appRouterProvider);
        final semantics = tester.ensureSemantics();
        try {
          Finder bannerWithTitle(String title) => find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                (widget.properties.label?.startsWith('$title.') ?? false),
          );
          for (var index = 0; index < scenario.homeBanners.length; index++) {
            final banner = scenario.homeBanners[index];
            final card = bannerWithTitle(banner.title);
            expect(card, findsOneWidget);
            for (final copy in [
              banner.title,
              banner.description,
              banner.actionLabel,
            ]) {
              expect(
                find.descendant(of: card, matching: find.text(copy)),
                findsOneWidget,
                reason: 'Home banner must paint its offer, beyond semantics',
              );
            }
            expect(tester.getSize(card).height, index == 0 ? 72 : 120);
            expect(
              find.bySemanticsLabel(
                '${banner.title}. ${banner.description}. ${banner.actionLabel}',
              ),
              findsOneWidget,
            );
            await tester.ensureVisible(card);
            if (index == 0) {
              await tester.tap(card);
              await settleReplay(tester);
              expect(router.state.uri.path, banner.route);
              router.go('/home');
              await settleReplay(tester);
            }
          }
          router.go('/products');
          await settleReplay(tester);
          await tester.pump(DemoMotion.bannerLoad);
          await tester.pumpAndSettle();
          final product = scenario.productBanners.first;
          final card = bannerWithTitle(product.title);
          expect(card, findsOneWidget);
          for (final copy in [
            product.title,
            product.description,
            product.actionLabel,
          ]) {
            expect(
              find.descendant(of: card, matching: find.text(copy)),
              findsOneWidget,
              reason: 'Product banner must paint its offer, beyond semantics',
            );
          }
          expect(tester.getSize(card).height, 120);
          expect(
            find.bySemanticsLabel(
              '${product.title}. ${product.description}. ${product.actionLabel}',
            ),
            findsOneWidget,
          );
          await tester.tap(card);
          await settleReplay(tester);
          expect(router.state.uri.path, product.route);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }

  testWidgets(
    'light home, history detail, search and back share fixture operation',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final container = await startApp(tester);
      final operation = container
          .read(bankRepositoryProvider)
          .snapshot
          .operations
          .first;
      expect(find.text('Иван'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.light,
      );
      await capture(tester, 'home');
      await tester.tap(find.byTooltip(AppCopy.history));
      await settleReplay(tester);
      expect(find.text(AppCopy.history), findsOneWidget);
      await capture(tester, 'history');
      await tester.tap(find.text(operation.title));
      await settleReplay(tester);
      expect(find.text(AppCopy.details), findsOneWidget);
      expect(find.text(operation.title), findsOneWidget);
      await capture(tester, 'operation');
      await tester.tap(find.byTooltip(AppCopy.back));
      await settleReplay(tester);
      await tester.enterText(
        find.byKey(const ValueKey('history-search')),
        'несуществующая операция',
      );
      await settleReplay(tester);
      expect(find.text(AppCopy.noOperations), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'transfer updates history and reset restores complete local scenario',
    (tester) async {
      final container = await startApp(tester);
      final repository = container.read(bankRepositoryProvider);
      final initial = repository.snapshot.primaryAccount.balance.minorUnits;
      await tester.tap(find.text(AppCopy.transfer).first);
      await settleReplay(tester);
      await capture(tester, 'transfer-sheet');
      await tester.tap(
        find.text(RecordedFormsContent.transferItems.first.title),
      );
      await settleReplay(tester);
      await capture(tester, 'transfer-card');
      await tester.ensureVisible(
        find.byKey(const ValueKey('confirm-transfer')),
      );
      await tester.pumpAndSettle();
      await capture(tester, 'transfer-card-scrolled');
      await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('transfer-recipient')),
        'Демо-получатель',
      );
      await tester.enterText(
        find.byKey(const ValueKey('transfer-amount')),
        '12,34',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('confirm-transfer')),
      );
      await confirmSwipe(tester);
      await settleReplay(tester);
      expect(find.text(AppCopy.details), findsOneWidget);
      expect(
        repository.snapshot.primaryAccount.balance.minorUnits,
        initial - 1234,
      );
      expect(
        repository.snapshot.operations.first.title,
        contains('Демо-получатель'),
      );
      container.read(appRouterProvider).go('/demo');
      await settleReplay(tester);
      await tester.tap(find.byKey(const ValueKey('reset-demo')));
      await settleReplay(tester);
      expect(repository.snapshot.primaryAccount.balance.minorUnits, initial);
      expect(repository.snapshot.operations.length, 4);
      expect(find.text('Иван'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tabs, 5-item product sheet and More routes are usable', (
    tester,
  ) async {
    final container = await startApp(tester);
    await tester.tap(find.text(AppCopy.products).last);
    await settleReplay(tester);
    await capture(tester, 'products');
    await tester.tap(find.text(AppCopy.apply));
    await settleReplay(tester);
    for (final product
        in container.read(bankRepositoryProvider).scenario.applyProducts) {
      expect(find.text(product.title), findsOneWidget);
    }
    await tester.tap(find.text('Вклад').last);
    await settleReplay(tester);
    expect(find.text('У вас нет действующих вкладов'), findsOneWidget);
    container.read(appRouterProvider).go('/more');
    await settleReplay(tester);
    await capture(tester, 'more');
    await tester.tap(find.text('Настройки'));
    await settleReplay(tester);
    expect(find.text(AppCopy.settings), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow display and large legacy text render without overflow', (
    tester,
  ) async {
    final container = await startApp(
      tester,
      size: const Size(320, 720),
      textScale: 1.6,
    );
    expect(tester.takeException(), isNull);
    for (final path in [
      '/products',
      '/more',
      '/history',
      '/operation/fixture-operation-1',
    ]) {
      container.read(appRouterProvider).go(path);
      await settleReplay(tester);
      expect(tester.takeException(), isNull, reason: path);
    }
  });
  testWidgets('hardware back returns each tab home and reset clears chat', (
    tester,
  ) async {
    final container = await startApp(tester);
    final router = container.read(appRouterProvider);
    for (final route in ['/products', '/more', '/chat']) {
      router.go(route);
      await settleReplay(tester);
      await tester.binding.handlePopRoute();
      await settleReplay(tester);
      expect(router.routeInformationProvider.value.uri.path, '/home');
    }
    router.go('/chat');
    await settleReplay(tester);
    await tester.enterText(find.byType(TextField), 'Проверка локального чата');
    await tester.tap(find.byTooltip(AppCopy.send));
    await settleReplay(tester);
    expect(find.text('Проверка локального чата'), findsOneWidget);
    router.go('/demo');
    await settleReplay(tester);
    await tester.tap(find.byKey(const ValueKey('reset-demo')));
    await settleReplay(tester);
    router.go('/chat');
    await settleReplay(tester);
    expect(find.text('Проверка локального чата'), findsNothing);
    expect(find.text(AppCopy.emptyChat), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('USD transfer preserves BYN and uses USD commission', (
    tester,
  ) async {
    final container = await startApp(tester);
    final repository = container.read(bankRepositoryProvider);
    final initialByn = repository.snapshot.primaryAccount.balance.minorUnits;
    final initialUsd = repository.snapshot
        .accountById('account-usd')!
        .balance
        .minorUnits;
    container.read(appRouterProvider).go('/transfer?account=account-usd');
    await settleReplay(tester);
    expect(find.textContaining('0,00 USD'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('transfer-recipient')),
      'Демо USD',
    );
    await tester.enterText(
      find.byKey(const ValueKey('transfer-amount')),
      '5.25',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('confirm-transfer')));
    await confirmSwipe(tester);
    await settleReplay(tester);
    expect(repository.snapshot.primaryAccount.balance.minorUnits, initialByn);
    expect(
      repository.snapshot.accountById('account-usd')!.balance.minorUnits,
      initialUsd - 525,
    );
    expect(repository.snapshot.operations.first.amount.currency, 'USD');
    expect(tester.takeException(), isNull);
  });

  testWidgets('home collapses and balance hiding is shared with card', (
    tester,
  ) async {
    final container = await startApp(tester);
    await tester.tap(find.byTooltip(AppCopy.hideBalance));
    await settleReplay(tester);
    expect(
      container.read(bankRepositoryProvider).snapshot.balanceVisible,
      isFalse,
    );
    await capture(tester, 'home-hidden');
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -320),
    );
    await settleReplay(tester);
    expect(
      tester
          .renderObject<RenderSliverPersistentHeader>(
            find.byKey(const ValueKey('home-header')),
          )
          .geometry!
          .paintExtent,
      96,
    );
    final opacity = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('home-balance')),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, 0);
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: find.text(AppCopy.addCard),
                  matching: find.byType(InkWell),
                )
                .first,
          )
          .width,
      328,
    );
    await capture(tester, 'home-collapsed');
    container.read(appRouterProvider).go('/card/card-main');
    await settleReplay(tester);
    expect(find.textContaining(AppCopy.hiddenBalance), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets('recorded routes render at narrow font-scaled viewport', (
    tester,
  ) async {
    final container = await startApp(
      tester,
      size: const Size(320, 720),
      textScale: 1.6,
    );
    for (final route in [
      '/cards',
      '/refill',
      '/transfer',
      '/settings',
      '/profile',
      '/documents',
      '/notifications',
      '/currency',
      '/about',
      '/forms/salary',
      '/forms/credit',
      '/transfer/choose',
      '/transfer/phone',
      '/payments/erip',
      '/settings/transfers',
      '/settings/transfer/moby',
      '/settings/transfer/ips',
      '/settings/transfer/visa',
      '/settings/transfer/erip',
      '/settings/transfer/erip-card',
      '/settings/transfer/erip-account',
    ]) {
      container.read(appRouterProvider).go(route);
      await settleReplay(tester);
      expect(tester.takeException(), isNull, reason: route);
    }
  });

  testWidgets('capture recorded surfaces and local currency tab loading', (
    tester,
  ) async {
    final container = await startApp(tester);
    for (final route in [
      '/settings',
      '/profile',
      '/documents',
      '/notifications',
      '/currency',
      '/about',
      '/forms/salary',
      '/forms/credit',
      '/transfer/choose',
      '/transfer/phone',
      '/payments/erip',
      '/products/credits',
      '/products/deposits',
      '/products/requests',
      '/safety',
      '/settings/transfer/moby',
      '/settings/transfer/ips',
      '/settings/transfer/visa',
      '/settings/transfer/erip',
      '/settings/transfer/erip-card',
      '/settings/transfer/erip-account',
    ]) {
      container.read(appRouterProvider).go(route);
      await settleReplay(tester);
      await capture(tester, route.substring(1).replaceAll('/', '-'));
      expect(tester.takeException(), isNull, reason: route);
    }
    container.read(appRouterProvider).go('/currency');
    await settleReplay(tester);
    await tester.tap(find.text('НБРБ'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('native-progress-headless')),
      findsOneWidget,
    );
    await settleReplay(tester);
    expect(find.text(RecordedContent.chooseCurrencies), findsOneWidget);
    expect(find.text(RecordedContent.demoRates), findsNothing);
    await capture(tester, 'currency-nbrb');
    await tester.tap(find.text('МТБанк'));
    await settleReplay(tester);
    await capture(tester, 'currency-bank');
  });

  testWidgets(
    'card application replays loading and error then restores collapsed home',
    (tester) async {
      final container = await startApp(tester);
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -320),
      );
      await settleReplay(tester);
      container.read(appRouterProvider).push('/apply-card');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey('native-progress-headless')),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      expect(find.text(AppCopy.applicationUnavailable), findsOneWidget);
      await capture(tester, 'card-apply-error');
      await tester.tap(find.text(AppCopy.close));
      await settleReplay(tester);
      expect(
        tester
            .renderObject<RenderSliverPersistentHeader>(
              find.byKey(const ValueKey('home-header')),
            )
            .geometry!
            .paintExtent,
        96,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('narrow card application error sheet scrolls to Close', (
    tester,
  ) async {
    final container = await startApp(
      tester,
      size: const Size(320, 740),
      textScale: 1.3,
    );
    final offer = container
        .read(bankRepositoryProvider)
        .scenario
        .homeBanners[1];
    final banner = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.button == true &&
          (widget.properties.label?.startsWith('${offer.title}.') ?? false),
    );
    await tester.ensureVisible(banner);
    await tester.tap(banner);
    await tester.pump();
    await tester.pump(DemoMotion.routeTransition);
    expect(
      find.byKey(const ValueKey('native-progress-headless')),
      findsOneWidget,
    );
    await tester.pump(DemoMotion.cardApplicationLoad);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final unavailable = find.text(AppCopy.applicationUnavailable);
    expect(unavailable, findsOneWidget);
    final sheet = find.ancestor(
      of: unavailable,
      matching: find.byType(BottomSheet),
    );
    expect(tester.getSize(sheet).height, lessThan(740 * .6));
    final close = find.widgetWithText(FilledButton, AppCopy.close);
    await tester.ensureVisible(close);
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.ancestor(of: close, matching: find.byType(Scrollable)).first,
    );
    expect(scrollable.position.pixels, greaterThan(0));
    await tester.tap(close);
    await settleReplay(tester);
    expect(container.read(appRouterProvider).state.uri.path, '/home');
    expect(unavailable, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings email and synthetic contacts reset with demo session', (
    tester,
  ) async {
    final container = await startApp(tester);
    final router = container.read(appRouterProvider);
    router.go('/settings');
    await settleReplay(tester);
    await tester.ensureVisible(find.text(RecordedContent.changeEmail));
    await tester.tap(find.text(RecordedContent.changeEmail));
    await settleReplay(tester);
    await capture(tester, 'settings-email-empty');
    await tester.enterText(
      find.byKey(const ValueKey('recorded-email')),
      'new@example.test',
    );
    await tester.ensureVisible(find.text(RecordedContent.save));
    await tester.tap(find.text(RecordedContent.save));
    await settleReplay(tester);
    expect(find.text('new@example.test'), findsOneWidget);
    router.go('/transfer/phone');
    await settleReplay(tester);
    expect(find.text(RecordedFormsContent.contacts.first.name), findsNothing);
    await tester.tap(find.byTooltip(RecordedFormsContent.contactsEmpty));
    await settleReplay(tester);
    await capture(tester, 'contacts-rationale');
    await tester.tap(find.byKey(const ValueKey('recorded-contacts-continue')));
    await settleReplay(tester);
    expect(find.text(RecordedFormsContent.contacts.first.name), findsOneWidget);
    await capture(tester, 'contacts-loaded');
    await tester.tap(find.text(RecordedFormsContent.contacts.first.name));
    await settleReplay(tester);
    expect(find.text(RecordedFormsContent.contacts.first.name), findsOneWidget);
    router.go('/demo');
    await settleReplay(tester);
    await tester.tap(find.byKey(const ValueKey('reset-demo')));
    await settleReplay(tester);
    router.go('/settings');
    await settleReplay(tester);
    expect(find.text('new@example.test'), findsNothing);
    expect(find.text(RecordedContent.initialEmail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'operation details distinguish pending conversion from completed incoming',
    (tester) async {
      final container = await startApp(tester);
      final router = container.read(appRouterProvider);
      router.go('/operation/fixture-operation-1');
      await settleReplay(tester);
      expect(find.text(AppCopy.pending), findsOneWidget);
      expect(find.text('5411'), findsOneWidget);
      expect(find.textContaining('12,49 EUR'), findsOneWidget);
      router.go('/operation/fixture-operation-3');
      await settleReplay(tester);
      expect(find.text(AppCopy.completed), findsOneWidget);
      expect(find.text('5411'), findsNothing);
      await capture(tester, 'operation-incoming');
    },
  );
  testWidgets(
    'refill needs local card data and credits only selected account',
    (tester) async {
      final container = await startApp(tester);
      final repository = container.read(bankRepositoryProvider);
      final initial = repository.snapshot.primaryAccount.balance.minorUnits;
      container.read(appRouterProvider).go('/refill');
      await settleReplay(tester);
      for (final key in [
        'refill-source-number',
        'refill-source-expiry',
        'refill-source-cvv',
        'transfer-amount',
      ]) {
        final field = find.byKey(ValueKey(key));
        expect(field, findsOneWidget);
        expect(
          tester.getSize(field).height,
          greaterThanOrEqualTo(44),
          reason: key,
        );
      }
      await capture(tester, 'refill');
      await tester.ensureVisible(
        find.byKey(const ValueKey('confirm-transfer')),
      );
      await tester.pumpAndSettle();
      await capture(tester, 'refill-scrolled');
      await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('transfer-amount')),
        '25.01',
      );
      await confirmSwipe(tester);
      expect(repository.snapshot.primaryAccount.balance.minorUnits, initial);
      await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip(TransferContent.camera));
      await tester.tap(find.byTooltip(TransferContent.camera));
      await tester.pump();
      expect(find.text(TransferContent.externalCard.number), findsOneWidget);
      await confirmSwipe(tester);
      expect(
        repository.snapshot.primaryAccount.balance.minorUnits,
        initial + 2501,
      );
      expect(repository.snapshot.operations.length, 5);
      expect(find.text(AppCopy.details), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cards preserve local order and per-card eye toggling', (
    tester,
  ) async {
    final container = await startApp(tester);
    final cards = container.read(bankRepositoryProvider).snapshot.cards;
    container.read(appRouterProvider).go('/cards');
    await settleReplay(tester);
    await capture(tester, 'cards');
    final first = find.byKey(ValueKey(cards.first.id));
    final second = find.byKey(ValueKey(cards[1].id));
    expect(tester.getTopLeft(first).dy, lessThan(tester.getTopLeft(second).dy));
    await tester.tap(
      find.descendant(of: first, matching: find.byTooltip(AppCopy.hideBalance)),
    );
    await tester.pump();
    expect(
      find.descendant(of: first, matching: find.text(AppCopy.hiddenBalance)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: second, matching: find.text(AppCopy.hiddenBalance)),
      findsNothing,
    );
    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderItem!(0, 1);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(first).dy,
      greaterThan(tester.getTopLeft(second).dy),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('chat source composer preserves draft and attachment cancel', (
    tester,
  ) async {
    final container = await startApp(tester);
    await tester.tap(find.text(AppCopy.chat).last);
    await settleReplay(tester);
    expect(find.text(ChatContent.empty), findsOneWidget);
    await capture(tester, 'chat-empty');
    final input = find.byKey(const ValueKey('chat-input'));
    await tester.enterText(input, '  \n ');
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('chat-send')))
          .onPressed,
      isNull,
    );
    await tester.enterText(input, 'Первая строка\nВторая строка');
    await tester.testTextInput.receiveAction(TextInputAction.newline);
    await tester.pump();
    expect(
      tester.widget<TextField>(input).controller!.text,
      'Первая строка\nВторая строка',
    );
    await tester.tap(find.byKey(const ValueKey('chat-attach')));
    await settleReplay(tester);
    await capture(tester, 'chat-attachment');
    for (final action in ChatContent.attachments) {
      expect(
        find.byKey(ValueKey('chat-attachment-${action.id}')),
        findsOneWidget,
      );
    }
    await tester.tap(find.byKey(const ValueKey('chat-attachment-cancel')));
    await settleReplay(tester);
    expect(
      tester.widget<TextField>(input).controller!.text,
      contains('Первая строка'),
    );
    await tester.tap(find.byTooltip(AppCopy.back));
    await settleReplay(tester);
    await tester.tap(find.text(AppCopy.chat).last);
    await settleReplay(tester);
    expect(
      tester.widget<TextField>(input).controller!.text,
      contains('Первая строка'),
    );
    expect(tester.takeException(), isNull);
    expect(
      container.read(bankRepositoryProvider).snapshot.operations.length,
      4,
    );
  });

  testWidgets('chat emoji selection, grapheme deletion and Back stay local', (
    tester,
  ) async {
    final container = await startApp(tester);
    container.read(appRouterProvider).go('/chat');
    await settleReplay(tester);
    final input = find.byKey(const ValueKey('chat-input'));
    await tester.enterText(input, 'абв');
    final controller = tester.widget<TextField>(input).controller!;
    controller.selection = const TextSelection(baseOffset: 1, extentOffset: 2);
    await tester.tap(find.byKey(const ValueKey('chat-emoji-toggle')));
    await settleReplay(tester);
    await capture(tester, 'chat-emoji');
    final emojiInput = tester.widget<TextField>(input);
    expect(emojiInput.readOnly, isTrue);
    expect(emojiInput.focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.hasAnyClients, isFalse);
    final emoji = SourceEmojiCatalog.smileysAndPeople.first;
    await tester.tap(find.byKey(const ValueKey('chat-emoji-0-0')));
    await tester.pump();
    expect(controller.text, 'а${emoji.text}в');
    await tester.tap(find.byKey(const ValueKey('chat-emoji-backspace')));
    await tester.pump();
    expect(controller.text, 'ав');
    controller.value = const TextEditingValue(
      text: 'А👨‍👩‍👧‍👦',
      selection: TextSelection.collapsed(offset: 12),
    );
    await tester.tap(find.byKey(const ValueKey('chat-emoji-backspace')));
    await tester.pump();
    expect(controller.text, 'А');
    controller.clear();
    await tester.pump();
    await capture(tester, 'chat-emoji-empty');
    await tester.binding.handlePopRoute();
    await settleReplay(tester);
    expect(find.byKey(const ValueKey('chat-emoji-panel')), findsNothing);
    expect(find.byKey(const ValueKey('chat-input')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settleReplay(tester);
    expect(find.text('Иван'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat local search, session messages and IME avoid overflow', (
    tester,
  ) async {
    final container = await startApp(
      tester,
      size: const Size(320, 720),
      textScale: 1.6,
    );
    final router = container.read(appRouterProvider);
    router.go('/chat');
    await settleReplay(tester);
    final input = find.byKey(const ValueKey('chat-input'));
    for (final message in [
      'Локальная проверка один',
      'Ещё локальная проверка',
    ]) {
      await tester.enterText(input, message);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await tester.pump();
    }
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip(ChatContent.search));
    await settleReplay(tester);
    await tester.enterText(
      find.byKey(const ValueKey('chat-search-input')),
      'проверка',
    );
    await settleReplay(tester);
    expect(find.text('1 из 2'), findsOneWidget);
    await tester.tap(find.byTooltip(ChatContent.nextMatch));
    await tester.pump();
    expect(find.text('2 из 2'), findsOneWidget);
    await capture(tester, 'chat-search-large');
    await tester.binding.handlePopRoute();
    await settleReplay(tester);
    expect(find.byKey(const ValueKey('chat-search-panel')), findsNothing);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(AppCopy.back));
    await settleReplay(tester);
    await tester.tap(find.text(AppCopy.chat).last);
    await settleReplay(tester);
    expect(find.text('Локальная проверка один'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Products keeps rows available during rounded local banner load',
    (tester) async {
      final container = await startApp(tester);
      container.read(appRouterProvider).go('/products');
      await settleReplay(tester);
      final carousel = find.byKey(const ValueKey('products-carousel'));
      final pager = tester.widget<PageView>(carousel);
      pager.controller!.jumpToPage(1);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('product-banner-loading-1')),
        findsOneWidget,
      );
      expect(find.text('Карты и счета'), findsOneWidget);
      expect(find.text(AppCopy.apply), findsOneWidget);
      await capture(tester, 'products-banner-loading', settle: false);
      await settleReplay(tester);
      expect(
        find.byKey(const ValueKey('product-banner-loading-1')),
        findsNothing,
      );
      await capture(tester, 'products-middle');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'history searches product label, filters direction and keeps detail year',
    (tester) async {
      final container = await startApp(tester);
      final repository = container.read(bankRepositoryProvider);
      container.read(appRouterProvider).go('/history');
      await settleReplay(tester);
      final operation = repository.snapshot.operations.first;
      final scenarioYear = repository.scenario.actionTime.year;
      expect(
        find.text(
          formatHistoryDay(operation.occurredAt, scenarioYear: scenarioYear),
        ),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('history-search')),
        repository.snapshot.cards.first.title,
      );
      await tester.pump();
      expect(find.text(operation.title), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('history-search')), '');
      await tester.pump();
      await tester.tap(find.byTooltip(AppCopy.filter));
      await settleReplay(tester);
      await tester.tap(find.text(AppCopy.onlyIncoming));
      await settleReplay(tester);
      expect(find.text(operation.title), findsNothing);
      final incoming = repository.snapshot.operations.firstWhere(
        (item) => item.direction.name == 'incoming',
      );
      expect(find.text(incoming.title), findsOneWidget);
      await capture(tester, 'history-incoming-filter');
      await tester.tap(find.text(incoming.title));
      await settleReplay(tester);
      expect(find.text(formatDateTime(incoming.occurredAt)), findsOneWidget);
      expect(
        formatHistoryDay(DateTime(2025, 1, 2), scenarioYear: 2026),
        contains('2025'),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'transfer can recover from insufficient funds and writes one operation',
    (tester) async {
      final container = await startApp(tester);
      final repository = container.read(bankRepositoryProvider);
      final initial = repository.snapshot.primaryAccount.balance.minorUnits;
      container.read(appRouterProvider).go('/transfer');
      await settleReplay(tester);
      await tester.enterText(
        find.byKey(const ValueKey('transfer-recipient')),
        'Демо retry',
      );
      await tester.enterText(
        find.byKey(const ValueKey('transfer-amount')),
        '999999.00',
      );
      await confirmSwipe(tester);
      expect(find.text(AppCopy.insufficientFunds), findsOneWidget);
      expect(repository.snapshot.primaryAccount.balance.minorUnits, initial);
      expect(repository.snapshot.operations.length, 4);
      await tester.enterText(
        find.byKey(const ValueKey('transfer-amount')),
        '1.23',
      );
      await tester.pump();
      expect(find.text(AppCopy.insufficientFunds), findsNothing);
      await confirmSwipe(tester);
      expect(find.text(AppCopy.details), findsOneWidget);
      expect(
        repository.snapshot.primaryAccount.balance.minorUnits,
        initial - 123,
      );
      expect(repository.snapshot.operations.length, 5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'card pager selects currency, survives resize and submits selected account',
    (tester) async {
      final container = await startApp(tester);
      final repository = container.read(bankRepositoryProvider);
      final byn = repository.snapshot.primaryAccount.balance.minorUnits;
      final usd = repository.snapshot
          .accountById('account-usd')!
          .balance
          .minorUnits;
      container.read(appRouterProvider).go('/transfer');
      await settleReplay(tester);
      final pager = find.byKey(const ValueKey('transfer-own-card-pager'));
      await capture(tester, 'transfer-pager-first');
      await tester.drag(pager, const Offset(-300, 0));
      await settleReplay(tester);
      expect(find.textContaining('0,00 USD'), findsOneWidget);
      expect(repository.snapshot.primaryAccount.balance.minorUnits, byn);
      expect(
        repository.snapshot.accountById('account-usd')!.balance.minorUnits,
        usd,
      );
      expect(repository.snapshot.operations.length, 4);
      await capture(tester, 'transfer-pager-usd');
      tester.view.physicalSize = const Size(320, 720);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      await settleReplay(tester);
      expect(find.textContaining('0,00 USD'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('transfer-recipient')),
        'Демо USD pager',
      );
      await tester.enterText(
        find.byKey(const ValueKey('transfer-amount')),
        '2.10',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('confirm-transfer')),
      );
      await tester.pumpAndSettle();
      final label = tester.renderObject<RenderParagraph>(
        find.text(TransferContent.swipeTransfer),
      );
      expect(label.didExceedMaxLines, isFalse);
      await capture(tester, 'transfer-pager-narrow-scrolled');
      await confirmSwipe(tester);
      expect(repository.snapshot.primaryAccount.balance.minorUnits, byn);
      expect(
        repository.snapshot.accountById('account-usd')!.balance.minorUnits,
        usd - 210,
      );
      expect(repository.snapshot.operations.length, 5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('chat attachment choices only show local demo information', (
    tester,
  ) async {
    final container = await startApp(tester);
    container.read(appRouterProvider).go('/chat');
    await settleReplay(tester);
    for (final action in ChatContent.attachments) {
      await tester.tap(find.byKey(const ValueKey('chat-attach')));
      await settleReplay(tester);
      await tester.tap(find.byKey(ValueKey('chat-attachment-${action.id}')));
      await settleReplay(tester);
      expect(find.text(ChatContent.attachmentDemo), findsOneWidget);
      await tester.tap(find.text(ChatContent.close));
      await settleReplay(tester);
    }
    expect(
      container.read(bankRepositoryProvider).snapshot.operations.length,
      4,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'source empty product actions and full safety article are reachable',
    (tester) async {
      final container = await startApp(tester);
      final router = container.read(appRouterProvider);
      router.go('/products/credits');
      await settleReplay(tester);
      expect(find.text('У вас нет действующих кредитов'), findsOneWidget);
      expect(find.text('Оформить кредит'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('empty-product-action')));
      await settleReplay(tester);
      expect(
        find.byKey(const ValueKey('recorded-credit-amount')),
        findsOneWidget,
      );
      router.go('/products/deposits');
      await settleReplay(tester);
      expect(find.text('У вас нет действующих вкладов'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('empty-product-action')));
      await settleReplay(tester);
      expect(find.byKey(const ValueKey('deposit-amount')), findsOneWidget);
      expect(find.text(SourceCatalogContent.currency), findsOneWidget);
      router.go('/products/requests');
      await settleReplay(tester);
      expect(find.text('Заявки на продукты'), findsOneWidget);
      expect(find.byKey(const ValueKey('empty-product-action')), findsNothing);
      router.go('/safety');
      await settleReplay(tester);
      expect(find.text(SourceSafetyContent.heading), findsOneWidget);
      await capture(tester, 'safety-top');
      await tester.drag(
        find.byKey(const ValueKey('safety-article')),
        const Offset(0, -900),
      );
      await settleReplay(tester);
      await capture(tester, 'safety-bottom');
      expect(
        find.textContaining('Политикой', findRichText: true),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'full emoji catalog variants insert exact sequence and persist preferred choice',
    (tester) async {
      final container = await startApp(tester);
      final router = container.read(appRouterProvider);
      router.go('/chat');
      await settleReplay(tester);
      await tester.tap(find.byKey(const ValueKey('chat-emoji-toggle')));
      await settleReplay(tester);
      final baseIndex = SourceEmojiCatalog.smileysAndPeople.indexWhere(
        (e) => e.variants.isNotEmpty,
      );
      final base = SourceEmojiCatalog.smileysAndPeople[baseIndex];
      final cell = find.byKey(ValueKey('chat-emoji-0-$baseIndex'));
      final grid = find.byKey(const ValueKey('chat-emoji-grid-0'));
      await tester.scrollUntilVisible(
        cell,
        120,
        scrollable: find.descendant(
          of: grid,
          matching: find.byType(Scrollable),
        ),
      );
      await tester.longPress(cell);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('chat-emoji-variants')), findsOneWidget);
      await capture(tester, 'chat-emoji-variants');
      await tester.tap(find.byKey(const ValueKey('chat-emoji-variant-1')));
      await settleReplay(tester);
      final input = find.byKey(const ValueKey('chat-input'));
      expect(
        tester.widget<TextField>(input).controller!.text,
        base.variants.first.text,
      );
      await tester.tap(cell);
      await tester.pump();
      expect(
        tester.widget<TextField>(input).controller!.text,
        base.variants.first.text * 2,
      );
      await tester.binding.handlePopRoute();
      await settleReplay(tester);
      await tester.binding.handlePopRoute();
      await settleReplay(tester);
      expect(find.byKey(const ValueKey('chat-input')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'apply sheet contains recorded heading and five descriptive choices',
    (tester) async {
      final container = await startApp(tester);
      container.read(appRouterProvider).go('/products');
      await settleReplay(tester);
      await tester.tap(find.text(AppCopy.apply));
      await settleReplay(tester);
      expect(find.text(AppCopy.apply), findsNWidgets(2));
      expect(find.text('Карта рассрочки № 1'), findsOneWidget);
      expect(find.text('Мгновенное оформление'), findsOneWidget);
      await capture(tester, 'products-apply-sheet');
      await tester.tap(find.text('Зарплатную карту'));
      await settleReplay(tester);
      expect(
        find.byKey(const ValueKey('recorded-employer-select')),
        findsOneWidget,
      );
      final title = tester.widget<Text>(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(RecordedFormsContent.salaryTitle),
        ),
      );
      expect(title.maxLines, 2);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'IPS first entry keeps parent menu under loader before transient body',
    (tester) async {
      final container = await startApp(tester);
      final router = container.read(appRouterProvider);
      router.go('/settings/transfers');
      await settleReplay(tester);
      final ips = RecordedContent.transferMethods.firstWhere(
        (m) => m.id == 'ips',
      );
      await tester.tap(find.text(ips.title));
      await tester.pump();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/settings/transfers',
      );
      expect(
        find.byKey(const ValueKey('recorded-ips-parent-loading')),
        findsOneWidget,
      );
      expect(find.text(ips.title), findsOneWidget);
      await capture(tester, 'settings-ips-parent-loading', settle: false);
      await tester.pump(RecordedContent.ipsParentLoadingDuration);
      await tester.pump();
      expect(find.byType(RecordedTransferMethodPage), findsOneWidget);
      expect(
        find.byKey(const ValueKey('recorded-ips-parent-loading')),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 200));
      await capture(tester, 'settings-ips-transient', settle: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      await capture(tester, 'settings-ips-off');
      expect(find.text(RecordedContent.transferProduct), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'contacts rationale cancel, local grant and reentry reset are deterministic',
    (tester) async {
      final container = await startApp(tester);
      final router = container.read(appRouterProvider);
      router.go('/transfer/phone');
      await settleReplay(tester);
      await tester.tap(find.byTooltip(RecordedFormsContent.contactsEmpty));
      await settleReplay(tester);
      await tester.tap(find.byKey(const ValueKey('recorded-contacts-cancel')));
      await settleReplay(tester);
      expect(find.text(RecordedFormsContent.contacts.first.name), findsNothing);
      await tester.tap(find.byTooltip(RecordedFormsContent.contactsEmpty));
      await settleReplay(tester);
      await tester.tap(
        find.byKey(const ValueKey('recorded-contacts-continue')),
      );
      await settleReplay(tester);
      router.go('/home');
      await settleReplay(tester);
      router.go('/transfer/phone');
      await tester.pump();
      await capture(tester, 'contacts-reentry-loading', settle: false);
      await settleReplay(tester);
      expect(
        find.byKey(const ValueKey('recorded-contacts-rationale')),
        findsNothing,
      );
      expect(
        find.text(RecordedFormsContent.contacts.first.name),
        findsOneWidget,
      );
      container.read(demoSessionProvider.notifier).restart();
      await settleReplay(tester);
      expect(find.text(RecordedFormsContent.contacts.first.name), findsNothing);
      expect(
        find.byTooltip(RecordedFormsContent.contactsEmpty),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'public Safety first line uses source Inter spacing without shrinking text',
    (tester) async {
      final container = await startApp(tester);
      container.read(appRouterProvider).go('/safety');
      await settleReplay(tester);
      final rich = find.textContaining('Уважаемый клиент!', findRichText: true);
      final paragraph = tester.renderObject<RenderParagraph>(rich);
      final boxes = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 38),
      );
      expect(
        boxes.length,
        1,
        reason: 'The full observed first line fits at Inter15 and328dp width',
      );
      expect(boxes.single.right - boxes.single.left, lessThanOrEqualTo(328));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'observed web reference replays four states without inventing a More entry',
    (tester) async {
      final container = await startApp(tester);
      container.read(appRouterProvider).go('/reference/web');
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('reference-web-blank')), findsOneWidget);
      await tester.pump(DemoMotion.bodyLoad);
      expect(
        find.byKey(const ValueKey('reference-web-loading')),
        findsOneWidget,
      );
      await tester.pump(DemoMotion.bodyLoad);
      expect(find.byKey(const ValueKey('reference-web-frame')), findsOneWidget);
      await tester.pump(DemoMotion.bodyLoad);
      expect(
        find.byKey(const ValueKey('reference-web-headless')),
        findsOneWidget,
      );
      expect(ObservedWebContent.html, contains("default-src 'none'"));
      expect(ObservedWebContent.html, isNot(contains('type="password"')));
      expect(ObservedWebContent.html, isNot(contains('<form')));
      await capture(tester, 'reference-web-headless');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Visa loading covers toolbar before showing its settings', (
    tester,
  ) async {
    final container = await startApp(tester);
    container.read(appRouterProvider).go('/settings/transfer/visa');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byTooltip(AppCopy.back), findsNothing);
    final visa = RecordedContent.transferMethods.firstWhere(
      (m) => m.id == 'visa',
    );
    expect(find.text(visa.title), findsNothing);
    await capture(tester, 'settings-visa-initial-loading', settle: false);
    await settleReplay(tester);
    expect(find.text(visa.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Space payments reject incomplete input and debit once after a swipe',
    (tester) async {
      final container = await startApp(tester);
      final router = container.read(appRouterProvider);
      final repo = container.read(bankRepositoryProvider);
      final before = repo.snapshot;
      router.go('/payments/mobile');
      await settleReplay(tester);
      expect(
        tester
            .widget<RecordedSwipeConfirm>(
              find.byKey(const ValueKey('mobile-confirm')),
            )
            .enabled,
        isFalse,
      );
      await capture(tester, 'space-mobile-empty');
      await tester.enterText(
        find.byKey(const ValueKey('mobile-phone')),
        PaymentContent.contactNumbers.first,
      );
      await tester.enterText(
        find.byKey(const ValueKey('mobile-amount')),
        '999999999',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      final confirm = find.byKey(const ValueKey('mobile-confirm'));
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      var bounds = tester.getRect(confirm);
      await tester.dragFrom(
        bounds.topLeft + const Offset(22, 22),
        Offset(bounds.width * .85, 0),
      );
      await settleReplay(tester);
      expect(find.text(AppCopy.insufficientFunds), findsOneWidget);
      expect(repo.snapshot, same(before));
      await tester.enterText(
        find.byKey(const ValueKey('mobile-amount')),
        '10,25',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      await capture(tester, 'space-mobile-ready');
      bounds = tester.getRect(confirm);
      await tester.dragFrom(
        bounds.topLeft + const Offset(22, 22),
        Offset(bounds.width * .85, 0),
      );
      await settleReplay(tester);
      expect(
        repo.snapshot.primaryAccount.balance.minorUnits,
        before.primaryAccount.balance.minorUnits - 1025,
      );
      expect(repo.snapshot.operations.length, before.operations.length + 1);
      expect(repo.snapshot.operations.first.subtitle, PaymentContent.mobile);
      await capture(tester, 'space-mobile-result');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Space deposit filters show source empty and clear stale results',
    (tester) async {
      final container = await startApp(tester);
      container.read(appRouterProvider).go('/deposits/open');
      await settleReplay(tester);
      await tester.tap(find.byKey(const ValueKey('deposit-search')));
      await settleReplay(tester);
      expect(find.byKey(const ValueKey('deposit-no-results')), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('deposit-amount')),
        '1500,00',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.tap(find.byKey(const ValueKey('deposit-search')));
      await settleReplay(tester);
      expect(find.byKey(const ValueKey('deposit-no-results')), findsOneWidget);
      await capture(tester, 'space-deposit-empty');
      await tester.tap(find.byKey(const ValueKey('deposit-currency-USD')));
      await settleReplay(tester);
      expect(find.byKey(const ValueKey('deposit-no-results')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Space exchange confirmation never changes the local ledger', (
    tester,
  ) async {
    final container = await startApp(tester);
    final repo = container.read(bankRepositoryProvider);
    final before = repo.snapshot;
    container.read(appRouterProvider).go('/currency/exchange');
    await settleReplay(tester);
    await capture(tester, 'space-exchange-empty');
    await tester.enterText(find.byKey(const ValueKey('exchange-input')), '10');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('exchange-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('exchange-continue')));
    await settleReplay(tester);
    await capture(tester, 'space-exchange-accounts');
    await tester.tap(find.byKey(const ValueKey('exchange-accounts-continue')));
    await settleReplay(tester);
    expect(find.byKey(const ValueKey('exchange-confirmation')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('exchange-confirm')));
    await settleReplay(tester);
    expect(find.text(SourceExchangeContent.unavailableTitle), findsOneWidget);
    expect(repo.snapshot, same(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Space remaining routes and narrow large text avoid overflow', (
    tester,
  ) async {
    final container = await startApp(
      tester,
      size: const Size(320, 740),
      textScale: 1.3,
    );
    final router = container.read(appRouterProvider);
    for (final route in [
      '/payments/arbitrary',
      '/payments/templates',
      '/payments/credit',
      '/payments/qr',
      '/forms/salary/cards',
      '/forms/credit/next',
      '/loyalty',
      '/loyalty/package',
      '/offers/product-promo-4',
    ]) {
      router.go(route);
      await settleReplay(tester);
      await capture(tester, 'space-route-${route.replaceAll('/', '-')}');
      expect(tester.takeException(), isNull, reason: route);
    }
  });

  testWidgets('Space product dots navigate only available pages', (
    tester,
  ) async {
    final container = await startApp(tester);
    final repo = container.read(bankRepositoryProvider);
    container.read(appRouterProvider).go('/products');
    await settleReplay(tester);
    expect(repo.scenario.sourceProductBannerIndicatorCount, 14);
    expect(find.byKey(const ValueKey('product-banner-dot-6')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('product-banner-dot-5')));
    await settleReplay(tester);
    await capture(tester, 'space-products-last-banner');
    await tester.tap(find.byKey(const ValueKey('products-carousel')));
    await settleReplay(tester);
    expect(find.text('Халва зарплатным клиентам'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Space arbitrary payment keeps source BIC readonly and writes entered details once',
    (tester) async {
      final container = await startApp(tester);
      final repo = container.read(bankRepositoryProvider);
      final before = repo.snapshot;
      container.read(appRouterProvider).go('/payments/arbitrary');
      await settleReplay(tester);
      final bic = find.byKey(const ValueKey('arbitrary-bic'));
      expect(tester.widget<TextField>(bic).readOnly, isTrue);
      for (final field in <(String, String)>[
        ('arbitrary-unp', '000000000'),
        ('arbitrary-iban', 'BY00MTBK00000000000000000000'),
        ('arbitrary-recipient', 'ООО «Липовый сад»'),
        ('arbitrary-purpose', 'Оплата услуг'),
        ('arbitrary-code', '00000'),
        ('arbitrary-amount', '12.34'),
      ]) {
        final input = find.byKey(ValueKey(field.$1));
        await tester.ensureVisible(input);
        await tester.enterText(input, field.$2);
        await tester.pumpAndSettle();
      }
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      final confirm = find.byKey(const ValueKey('arbitrary-confirm'));
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      expect(tester.widget<RecordedSwipeConfirm>(confirm).enabled, isTrue);
      expect(find.text('Счёт в долларах'), findsNothing);
      await capture(tester, 'space-arbitrary-ready');
      final bounds = tester.getRect(confirm);
      await tester.dragFrom(
        bounds.topLeft + const Offset(22, 22),
        Offset(bounds.width * .85, 0),
      );
      await settleReplay(tester);
      expect(repo.snapshot.operations.length, before.operations.length + 1);
      expect(
        repo.snapshot.primaryAccount.balance.minorUnits,
        before.primaryAccount.balance.minorUnits - 1234,
      );
      expect(repo.snapshot.operations.first.note, contains('Оплата услуг'));
      expect(repo.snapshot.operations.first.note, contains('00000'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Space repayment contract retries preserve draft and do not create debt or payment',
    (tester) async {
      final container = await startApp(tester);
      final repo = container.read(bankRepositoryProvider);
      final before = repo.snapshot;
      container.read(appRouterProvider).go('/payments/credit');
      await settleReplay(tester);
      final next = find.byKey(const ValueKey('credit-repayment-continue'));
      await tester.ensureVisible(next);
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      expect(
        DefaultTextStyle.of(
          tester.element(
            find.text(SourceCreditRepaymentContent.continueAction),
          ),
        ).style.fontFamily,
        'Inter',
      );
      await tester.enterText(
        find.byKey(const ValueKey('credit-repayment-contract')),
        '00000001',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(next);
      await settleReplay(tester);
      expect(
        find.byKey(const ValueKey('credit-repayment-unavailable')),
        findsOneWidget,
      );
      await capture(tester, 'space-credit-lookup-unavailable');
      await tester.tap(find.byKey(const ValueKey('credit-repayment-retry')));
      await settleReplay(tester);
      expect(
        find.byKey(const ValueKey('credit-repayment-unavailable')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('credit-repayment-close')));
      await settleReplay(tester);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('credit-repayment-contract')),
            )
            .controller!
            .text,
        '00000001',
      );
      expect(repo.snapshot, same(before));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Space branch filter apply cancel and reset work without fabricated locations',
    (tester) async {
      final container = await startApp(tester);
      container.read(appRouterProvider).go('/branches');
      await settleReplay(tester);
      await capture(tester, 'space-branches-map');
      await tester.tap(find.byKey(const ValueKey('branches-filter')));
      await settleReplay(tester);
      final working = find.byKey(const ValueKey('branches-working-now'));
      await tester.tap(working);
      final apply = find.byKey(const ValueKey('branches-filter-apply'));
      await tester.ensureVisible(apply);
      await tester.tap(apply);
      await settleReplay(tester);
      await tester.tap(find.byKey(const ValueKey('branches-filter')));
      await settleReplay(tester);
      expect(tester.widget<SwitchListTile>(working).value, isTrue);
      await capture(tester, 'space-branches-filter');
      await tester.tap(find.byKey(const ValueKey('branches-filter-reset')));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(working).value, isFalse);
      await tester.tap(find.byTooltip(AppCopy.back));
      await settleReplay(tester);
      await tester.tap(find.byKey(const ValueKey('branches-filter')));
      await settleReplay(tester);
      expect(tester.widget<SwitchListTile>(working).value, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Space external card masks reject invalid number expiry and short CVC',
    (tester) async {
      final container = await startApp(
        tester,
        size: const Size(320, 740),
        textScale: 1.3,
      );
      final repo = container.read(bankRepositoryProvider);
      final before = repo.snapshot;
      container.read(appRouterProvider).go('/refill');
      await settleReplay(tester);
      final pan = find.byKey(const ValueKey('refill-source-number'));
      final expiry = find.byKey(const ValueKey('refill-source-expiry'));
      final cvc = find.byKey(const ValueKey('refill-source-cvv'));
      await tester.enterText(pan, '4111111111111112');
      await tester.enterText(expiry, '1330');
      await tester.enterText(cvc, '1a2');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('4111 1111 1111 1112'), findsOneWidget);
      expect(find.text('13/30'), findsOneWidget);
      expect(find.text('Проверьте номер карты'), findsOneWidget);
      expect(find.text('Месяц 01–12'), findsOneWidget);
      expect(find.text('3 цифры'), findsOneWidget);
      await capture(tester, 'space-card-validation-errors');
      final amount = find.byKey(const ValueKey('transfer-amount'));
      await tester.ensureVisible(amount);
      await tester.enterText(amount, '10.00');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<RecordedSwipeConfirm>(find.byType(RecordedSwipeConfirm))
            .enabled,
        isFalse,
      );
      await tester.ensureVisible(pan);
      await tester.enterText(pan, TransferContent.externalCard.number);
      await tester.enterText(expiry, '0100');
      await tester.enterText(cvc, '123456');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(cvc).controller!.text, '123');
      expect(find.text('Срок истёк'), findsOneWidget);
      expect(
        tester
            .widget<RecordedSwipeConfirm>(find.byType(RecordedSwipeConfirm))
            .enabled,
        isFalse,
      );
      await tester.enterText(expiry, TransferContent.externalCard.expiry);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<RecordedSwipeConfirm>(find.byType(RecordedSwipeConfirm))
            .enabled,
        isTrue,
      );
      expect(repo.snapshot, same(before));
      expect(tester.takeException(), isNull);
    },
  );
}
