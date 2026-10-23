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
import 'package:moby_demo/core/config/children_content.dart';
import 'package:moby_demo/core/config/children_form_content.dart';
import 'package:moby_demo/core/theme/app_theme.dart';
import 'package:moby_demo/core/ui/source_assets.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/money_intent.dart';
import 'package:moby_demo/data/server/session_vault.dart';

class _MemorySessionVault implements SessionVault {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async {}
}

class _MemoryIntentVault implements MoneyIntentVault {
  final _values = <String, String>{};
  @override
  Future<void> delete(String key) async => _values.remove(key);
  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

/// The production router and session run against in-memory responses only.
class _PreviewApi extends FamilyApi {
  _PreviewApi(this.data) : super(Uri.parse('http://127.0.0.1:1'));
  JsonMap data;
  int completionCalls = 0;
  bool failCompletion = false;
  JsonMap? createdPayload;

  @override
  Future<JsonMap> request(String method, String path, [JsonMap? body]) async {
    if (method == 'POST' && path == '/v1/preferences/family-intro/complete') {
      completionCalls++;
      if (failCompletion) {
        throw const FamilyApiException(503, 'preview_unavailable');
      }
      data = {
        ...data,
        'revision': (data['revision'] as int) + 1,
        'preferences': {'familyIntroSeen': true},
      };
      return data;
    }
    if (method == 'POST' && path == '/v1/children') {
      createdPayload = Map<String, dynamic>.from(body!);
      final child = <String, dynamic>{
        'id': 'new-child',
        ...body,
        'membershipStatus': 'active',
        'accountStatus': 'not_opened',
        'cardStatus': 'none',
        'deviceAccessStatus': 'unpaired',
      }..remove('idempotencyKey');
      data = {
        ...data,
        'revision': (data['revision'] as int) + 1,
        'children': [...data['children'] as List, child],
      };
      return child;
    }
    if (method == 'GET' && path == '/v1/snapshot') return data;
    throw StateError('Unexpected preview request: $method $path');
  }

  @override
  Stream<JsonMap> events() => const Stream.empty();
}

class _PreviewSession extends FamilySession {
  _PreviewSession(_PreviewApi preview)
    : super(api: preview, vault: _MemorySessionVault()) {
    phase = FamilySessionPhase.signedIn;
    connected = true;
    snapshot = preview.data;
    _outbox = MoneyIntentStore(
      api: preview,
      actorId: 'preview-adult',
      vault: _MemoryIntentVault(),
      onAcknowledged: refresh,
    );
  }

  late final MoneyIntentStore _outbox;
  @override
  MoneyIntentStore get moneyIntents => _outbox;
}

JsonMap _snapshot({required bool introSeen, bool populated = false}) => {
  'revision': 1,
  'businessDate': '2026-10-20',
  'actor': {'id': 'preview-adult', 'role': 'adult'},
  'preferences': {'familyIntroSeen': introSeen},
  'children': populated
      ? [
          {
            'id': 'child-a',
            'displayName': 'Александра',
            'membershipStatus': 'active',
            'accountStatus': 'synthetic_open',
            'cardStatus': 'active',
            'deviceAccessStatus': 'paired',
            'balanceMinor': 5000,
          },
          {
            'id': 'child-b',
            'displayName': 'Михаил',
            'membershipStatus': 'active',
            'accountStatus': 'not_opened',
            'cardStatus': 'none',
            'deviceAccessStatus': 'unpaired',
            // A stale/non-applicable balance must never be shown as an account.
            'balanceMinor': 99999,
          },
        ]
      : <JsonMap>[],
  'operations': <JsonMap>[],
};

class _Harness {
  _Harness(
    this.api,
    this.session,
    this.container,
    this.router,
    this.boundaryKey,
  );
  final _PreviewApi api;
  final _PreviewSession session;
  final ProviderContainer container;
  final GoRouter router;
  final GlobalKey boundaryKey;

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    session.dispose();
  }
}

Future<_Harness> _pumpRouter(
  WidgetTester tester, {
  required bool introSeen,
  bool populated = false,
  String location = '/family',
  double width = 390,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final api = _PreviewApi(
    _snapshot(introSeen: introSeen, populated: populated),
  );
  final session = _PreviewSession(api);
  final container = ProviderContainer(
    overrides: [familySessionProvider.overrideWithValue(session)],
  );
  final router = container.read(appRouterProvider)..go(location);
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: buildMobyTheme(),
          locale: const Locale('ru'),
          supportedLocales: const [Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage(ChildrenContent.introImage),
      boundaryKey.currentContext!,
    );
    // SourceIcon's SVG bundle reads also finish outside the fake test clock.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return _Harness(api, session, container, router, boundaryKey);
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
      harness.boundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
  // A full-router capture must include retained shell/navigation layers too.
  void repaint(RenderObject object) {
    object.visitChildren(repaint);
    object.markNeedsPaint();
  }

  repaint(boundary);
  await tester.pump();
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2));
  final data = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.png),
  );
  File('$directory/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  image!.dispose();
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void _expectOriginalNavIcons(WidgetTester tester, {String? selected}) {
  final names = tester
      .widgetList<SourceIcon>(find.byType(SourceIcon))
      .map((icon) => icon.name)
      .toSet();
  expect(
    names,
    containsAll([
      selected == 'home' ? 'main_logo_p' : 'ic_main_inactive',
      selected == 'products' ? 'ic_products_tab' : 'ic_products_inactive',
      'menu_icon_chat',
      selected == 'more' ? 'ic_more_active' : 'ic_more',
    ]),
  );
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
    final heading = FontLoader('TikTokSans')
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
      heading.load(),
      icons.load(),
      legacy.load(),
    ]);
  });

  final scenarios = <(String, bool, bool, String, String)>[
    ('intro', false, false, '/family', ChildrenContent.start),
    ('empty', true, false, '/family', ChildrenContent.addChild),
    ('populated', true, true, '/family', ChildrenContent.add),
    ('create', true, false, '/family/apply', ChildrenFormContent.create),
  ];
  for (final (width, scale) in [(390.0, 1.0), (360.0, 1.3)]) {
    for (final (name, seen, populated, location, cta) in scenarios) {
      testWidgets(
        '$name actual router ${width.toInt()}px scale $scale',
        (tester) async {
          final harness = await _pumpRouter(
            tester,
            introSeen: seen,
            populated: populated,
            location: location,
            width: width,
            scale: scale,
          );
          _expectOriginalNavIcons(tester);
          final captureName =
              '$name-${width.toInt()}${scale == 1 ? '' : '-scale$scale'}';
          await _capture(tester, harness, captureName);
          if (name == 'intro' && width == 390 && scale == 1) {
            final button = tester.getRect(
              find.widgetWithText(FilledButton, ChildrenContent.start),
            );
            final navLabel = tester.getRect(find.text('Детям').hitTestable());
            expect(button.bottom, lessThan(navLabel.top - 40));
          }

          if (name == 'populated') {
            expect(find.text('Александра'), findsOneWidget);
            expect(find.text('Михаил'), findsOneWidget);
            expect(find.text('50,00 BYN'), findsOneWidget);
            expect(find.text('999,99 BYN'), findsNothing);
            expect(find.text(ChildrenContent.profileCreated), findsOneWidget);
            expect(find.text(ChildrenContent.unfinished), findsOneWidget);
          }
          if (name == 'create') {
            expect(find.text(ChildrenFormContent.name), findsOneWidget);
            expect(find.textContaining('Никнейм'), findsNothing);
            expect(find.text(ChildrenFormContent.legalName), findsNothing);
          }
          await _reveal(tester, find.text(cta));
          await _capture(tester, harness, '$captureName-action');
          if (name == 'create') {
            await tester.tap(find.text(ChildrenFormContent.create));
            await tester.pumpAndSettle();
            expect(find.text(ChildrenFormContent.invalidName), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
          await harness.close(tester);
        },
        skip: !familyApiEnabled,
      );
    }
  }

  testWidgets(
    'Start persists through tab changes; add and cancel use real router',
    (tester) async {
      final harness = await _pumpRouter(tester, introSeen: false);
      await _reveal(tester, find.text(ChildrenContent.start));
      await tester.tap(find.text(ChildrenContent.start));
      await tester.pumpAndSettle();
      expect(harness.api.completionCalls, 1);
      expect(harness.session.familyIntroSeen, isTrue);
      expect(find.text(ChildrenContent.emptyTitle), findsOneWidget);
      expect(find.text(ChildrenContent.introTitle), findsNothing);
      for (final (label, selected) in [
        ('Главная', 'home'),
        ('Продукты', 'products'),
        ('Ещё', 'more'),
      ]) {
        await tester.tap(find.text(label).hitTestable());
        await tester.pumpAndSettle();
        _expectOriginalNavIcons(tester, selected: selected);
        await tester.tap(find.text('Детям').hitTestable());
        await tester.pumpAndSettle();
        expect(find.text(ChildrenContent.emptyTitle), findsOneWidget);
        expect(find.text(ChildrenContent.introTitle), findsNothing);
      }
      await _reveal(tester, find.text(ChildrenContent.addChild));
      await tester.tap(find.text(ChildrenContent.addChild));
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/family/apply');
      expect(find.text(ChildrenFormContent.name), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text(ChildrenFormContent.legalName), findsNothing);
      await _reveal(tester, find.text(ChildrenFormContent.cancel));
      await tester.tap(find.text(ChildrenFormContent.cancel));
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/family');
      expect(find.text(ChildrenContent.emptyTitle), findsOneWidget);
      expect(harness.api.completionCalls, 1);
      expect(tester.takeException(), isNull);
      await harness.close(tester);
    },
    skip: !familyApiEnabled,
  );

  testWidgets(
    'failed Start retains intro and can retry without child-count inference',
    (tester) async {
      final harness = await _pumpRouter(
        tester,
        introSeen: false,
        populated: true,
      );
      harness.api.failCompletion = true;
      expect(find.text(ChildrenContent.introTitle), findsOneWidget);
      expect(find.text('Александра'), findsNothing);
      await _reveal(tester, find.text(ChildrenContent.start));
      await tester.tap(find.text(ChildrenContent.start));
      await tester.pumpAndSettle();
      expect(harness.session.familyIntroSeen, isFalse);
      expect(harness.api.completionCalls, 1);
      expect(find.text(ChildrenContent.completionFailed), findsOneWidget);
      expect(find.text(ChildrenContent.introTitle), findsOneWidget);
      harness.api.failCompletion = false;
      await _reveal(tester, find.text(ChildrenContent.start));
      await tester.tap(find.text(ChildrenContent.start));
      await tester.pumpAndSettle();
      expect(harness.api.completionCalls, 2);
      expect(harness.session.familyIntroSeen, isTrue);
      expect(find.text('Александра'), findsOneWidget);
      expect(find.text(ChildrenContent.completionFailed), findsNothing);
      expect(tester.takeException(), isNull);
      await harness.close(tester);
    },
    skip: !familyApiEnabled,
  );

  testWidgets(
    'Name and DOB create a draft through real form and return to hub',
    (tester) async {
      final harness = await _pumpRouter(
        tester,
        introSeen: true,
        location: '/family/apply',
      );
      await tester.enterText(
        find.byKey(const ValueKey('child-name')),
        'Михаил',
      );
      await tester.tap(find.byKey(const ValueKey('child-birth-date')));
      await tester.pumpAndSettle();
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      await tester.tap(
        find.text(
          MaterialLocalizations.of(
            tester.element(find.byType(DatePickerDialog)),
          ).okButtonLabel,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
      await _capture(tester, harness, 'create-filled-390');
      final date = picker.initialDate!;
      await _reveal(tester, find.text(ChildrenFormContent.create));
      await tester.tap(find.text(ChildrenFormContent.create));
      await tester.pumpAndSettle();
      expect(harness.api.createdPayload!['displayName'], 'Михаил');
      expect(
        harness.api.createdPayload!['dateOfBirth'],
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      );
      expect(harness.api.createdPayload!.containsKey('legalName'), isFalse);
      expect(harness.api.createdPayload!['idempotencyKey'], isNotEmpty);
      expect(harness.router.state.uri.path, '/family');
      expect(find.text('Михаил'), findsOneWidget);
      expect(find.text(ChildrenContent.profileCreated), findsOneWidget);
      expect(find.text(ChildrenContent.unfinished), findsOneWidget);
      expect(tester.takeException(), isNull);
      await harness.close(tester);
    },
    skip: !familyApiEnabled,
  );

  testWidgets(
    'manual help returns to hub without posting completion',
    (tester) async {
      final harness = await _pumpRouter(tester, introSeen: true);
      await tester.tap(find.byTooltip(ChildrenContent.howItWorks));
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/family/intro');
      await _reveal(tester, find.text(ChildrenContent.returnToFamily));
      await tester.tap(find.text(ChildrenContent.returnToFamily));
      await tester.pumpAndSettle();
      expect(harness.router.state.uri.path, '/family');
      expect(find.text(ChildrenContent.emptyTitle), findsOneWidget);
      expect(harness.api.completionCalls, 0);
      await harness.close(tester);
    },
    skip: !familyApiEnabled,
  );
}
