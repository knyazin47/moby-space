import 'dart:convert';
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
import 'package:moby_demo/core/theme/mt_brand_theme.dart';
import 'package:moby_demo/data/server/session_vault.dart';
import 'package:moby_demo/features/family/server_family_pages.dart';
import 'package:moby_demo/features/family/family_package_page.dart';

class _Vault implements SessionVault {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/reference/font/inter_regular.ttf'));
    final display = FontLoader('TikTokSans')
      ..addFont(rootBundle.load('assets/brand/fonts/TikTokSans.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([inter.load(), display.load(), icons.load()]);
  });
  test('route-scoped palette follows source; legacy theme preserved', () {
    final source =
        jsonDecode(File('../tools/assets/brand.json').readAsStringSync())
            as Map;
    for (final entry in {
      'mt_blue': MtBrandColors.blue,
      'mt_red': MtBrandColors.red,
      'mt_orange': MtBrandColors.orange,
      'mt_cloud_blue': MtBrandColors.cloud,
      'mt_sky_blue': MtBrandColors.sky,
      'mt_soft_blue': MtBrandColors.soft,
      'black': MtBrandColors.ink,
    }.entries) {
      expect(
        entry.value.toARGB32(),
        int.parse(
          'FF${(source['palette'][entry.key] as String).substring(1)}',
          radix: 16,
        ),
      );
    }
    expect(
      buildMtBrandTheme().textTheme.headlineLarge!.fontFamily,
      'TikTokSans',
    );
    expect(buildMtBrandTheme().textTheme.bodyLarge!.fontFamily, 'Inter');
    expect(buildMobyTheme().colorScheme.primary, const Color(0xFF1B74FD));
    final scheme = buildMtBrandTheme().colorScheme;
    expect(scheme.secondaryContainer, MtBrandColors.cloud);
    expect(scheme.onSecondaryContainer, MtBrandColors.blue);
    expect(scheme.surfaceContainerLow, Colors.white);
    expect(scheme.surfaceContainerHighest, MtBrandColors.cloud);
  });
  for (final width in [360.0, 430.0, 768.0]) {
    testWidgets('new family layout fits $width and enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final session = FamilySession(api: null, vault: _Vault())
        ..phase = FamilySessionPhase.signedIn
        ..connected = true
        ..snapshot = {
          'revision': 1,
          'preferences': {'familyIntroSeen': true},
          'actor': {'role': 'adult'},
          'children': [
            {
              'id': 'child-a',
              'displayName': 'Александра',
              'accountStatus': 'synthetic_open',
              'cardStatus': 'active',
              'deviceAccessStatus': 'paired',
              'membershipStatus': 'active',
              'balanceMinor': 5000,
            },
            {
              'id': 'child-b',
              'displayName': 'Михаил',
              'cardStatus': 'none',
              'deviceAccessStatus': 'unpaired',
              'membershipStatus': 'active',
              'balanceMinor': 0,
            },
          ],
        };
      final key = GlobalKey();
      Future<void> pump(Widget child) async {
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
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: RepaintBoundary(key: key, child: child),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await pump(const ServerFamilyPage());
      expect(find.text('Александра'), findsOneWidget);
      if (Platform.environment['MOBY_CAPTURE_DIR'] case final String dir) {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await tester.runAsync(
          () => boundary.toImage(pixelRatio: 2),
        );
        final data = await tester.runAsync(
          () => image!.toByteData(format: ui.ImageByteFormat.png),
        );
        File(
          '$dir/family-$width.png',
        ).writeAsBytesSync(data!.buffer.asUint8List());
        image!.dispose();
      }
      await pump(const FamilyPackagePage());
      await tester.pumpWidget(const SizedBox.shrink());
      session.dispose();
    });
  }
}
