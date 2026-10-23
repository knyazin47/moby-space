import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/family_session.dart';
import 'package:moby_demo/core/theme/app_theme.dart';
import 'package:moby_demo/data/server/family_api.dart';
import 'package:moby_demo/data/server/money_intent.dart';
import 'package:moby_demo/data/server/session_vault.dart';
import 'package:moby_demo/features/family/server_family_pages.dart';
import 'package:moby_demo/features/onboarding/entry_pages.dart';
import 'package:moby_demo/features/onboarding/server_child_home_page.dart';

const _pairCode = 'A1B2C3D4E5F6';

class _SessionVault implements SessionVault {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async {}
}

class _IntentVault implements MoneyIntentVault {
  final _values = <String, String>{};
  @override
  Future<void> delete(String key) async => _values.remove(key);
  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

/// In-memory response adapter: these captures never open a socket or read keys.
class _LayoutApi extends FamilyApi {
  _LayoutApi() : super(Uri.parse('http://127.0.0.1:1'));
  @override
  Future<JsonMap> request(String method, String path, [JsonMap? body]) async {
    if (path == '/v1/pairings') {
      return {
        'id': 'layout-pair',
        'code': _pairCode,
        'requestSecret': 'in-memory-layout-fixture',
        'expiresAt': 2000000000,
        'status': 'waiting',
      };
    }
    if (path.endsWith('/poll')) return {'status': 'waiting'};
    if (path.endsWith('/cancel')) return {'status': 'cancelled'};
    throw StateError('Layout test attempted an unexpected command');
  }
}

class _LayoutSession extends FamilySession {
  _LayoutSession(String? role)
    : super(api: _LayoutApi(), vault: _SessionVault()) {
    connected = true;
    phase = role == null
        ? FamilySessionPhase.signedOut
        : FamilySessionPhase.signedIn;
    if (role != null) {
      snapshot = {
        'revision': 1,
        'businessDate': '2026-10-20',
        'actor': {
          'id': role == 'child' ? 'child-a' : 'adult-layout',
          'role': role,
          if (role == 'child') 'childId': 'child-a',
        },
        'children': role == 'child'
            ? [
                {
                  'id': 'child-a',
                  'displayName': 'Александра',
                  'balanceMinor': 12345,
                  'accountStatus': 'synthetic_open',
                  'cardStatus': 'active',
                  'membershipStatus': 'active',
                  'deviceAccessStatus': 'paired',
                  'policy': {
                    'payments': true,
                    'transfers': true,
                    'internet': false,
                    'dailyLimit': 10000,
                    'monthlyLimit': 40000,
                    'approvalThreshold': 5000,
                  },
                },
              ]
            : [],
        'operations': role == 'child'
            ? [
                {
                  'id': 'purchase-layout',
                  'childId': 'child-a',
                  'kind': 'purchase',
                  'amountMinor': 5001,
                  'status': 'pending',
                },
              ]
            : [],
      };
    }
    _outbox = MoneyIntentStore(
      api: api!,
      actorId: role == 'child' ? 'child-a' : 'adult-layout',
      vault: _IntentVault(),
    );
  }
  late final MoneyIntentStore _outbox;
  @override
  MoneyIntentStore get moneyIntents => _outbox;
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final directory = Platform.environment['MOBY_CAPTURE_DIR'];
  if (directory == null) return;
  Directory(directory).createSync(recursive: true);
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2));
  final data = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.png),
  );
  File('$directory/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  image!.dispose();
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
    await Future.wait([inter.load(), display.load(), icons.load()]);
  });

  final scenarios = <(String, String?, Widget, String)>[
    ('welcome', null, const FamilyWelcomePage(), 'Я ребёнок'),
    ('adult-phone', null, const AdultPhonePage(), 'Продолжить'),
    ('adult-code', null, const AdultCodePage(phoneSuffix: '67'), 'Войти'),
    ('child-pair', null, const ServerChildPairPage(), 'Отменить подключение'),
    ('add-child', 'adult', const ServerAddChildPage(), 'Создать профиль'),
    ('child-home', 'child', const ServerChildHomePage(), 'Выйти'),
  ];
  for (final scale in [1.0, 1.3]) {
    for (final (name, role, page, lastAction) in scenarios) {
      testWidgets('$name fits 360px at text scale $scale', (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final session = _LayoutSession(role);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [familySessionProvider.overrideWithValue(session)],
            child: MaterialApp(
              theme: buildMobyTheme(),
              locale: const Locale('ru'),
              supportedLocales: const [Locale('ru')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: RepaintBoundary(key: boundaryKey, child: page),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final captureDirectory = Platform.environment['MOBY_CAPTURE_DIR'];
        if (captureDirectory != null) {
          Directory(captureDirectory).createSync(recursive: true);
          final title = find.byType(Text).first;
          File(
            '$captureDirectory/$name-scale$scale-positions.txt',
          ).writeAsStringSync(
            'firstTextRect=${tester.getRect(title)} scrollOffset=${tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels}\n',
          );
        }
        await _capture(tester, boundaryKey, '$name-360-scale$scale-top');
        expect(tester.takeException(), isNull);
        final action = find.text(lastAction);
        await tester.scrollUntilVisible(
          action,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await _capture(tester, boundaryKey, '$name-360-scale$scale-bottom');
        expect(action.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (name == 'child-pair') {
          final code = find.byType(SelectableText);
          expect(tester.widget<SelectableText>(code).data, _pairCode);
          final editable = tester
              .state<EditableTextState>(
                find.descendant(of: code, matching: find.byType(EditableText)),
              )
              .renderEditable;
          final boxes = editable.getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: _pairCode.length),
          );
          final lineCount = boxes.map((box) => box.top.round()).toSet().length;
          final directory = Platform.environment['MOBY_CAPTURE_DIR'];
          if (directory != null) {
            File('$directory/pair-code-scale$scale.txt').writeAsStringSync(
              'viewport=360x800 textScale=$scale manualCodeLines=$lineCount '
              'codeLength=${_pairCode.length}\n',
            );
          }
          expect(
            lineCount,
            1,
            reason: 'Manual pairing code must remain readable on one line',
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
        session.dispose();
      });
    }
  }
}
