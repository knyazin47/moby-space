import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/core/config/source_catalog_content.dart';
import 'package:moby_demo/core/ui/source_asset_paths.dart';
import 'package:moby_demo/core/ui/source_assets.dart';
import 'package:moby_demo/core/config/source_emoji_catalog.dart';
import 'package:moby_demo/data/demo/demo_scenario.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('semantic resource names retain explicit Material/artwork mappings', () {
    final names = {
      ...sourceIconGlyphs.keys,
      ...sourceAssetPaths.keys,
      ...sourceProgressIconNames,
    };
    // Stable compatibility surface used by both replica and network screens.
    expect(names.length, 116);
    expect(
      sourceIconGlyphs.keys.toSet().intersection(sourceAssetPaths.keys.toSet()),
      isEmpty,
    );
    for (final glyph in sourceIconGlyphs.values) {
      expect(glyph.fontFamily, 'MaterialIcons');
      expect(glyph.codePoint, greaterThan(0));
    }
    expect(
      sourceIconGlyphs['ic_eye_open'],
      isNot(sourceIconGlyphs['ic_eye_close']),
    );
    expect(
      {
        sourceIconGlyphs['ic_operation_item_failure'],
        sourceIconGlyphs['ic_operation_item_success'],
        sourceIconGlyphs['ic_operation_item_waiting'],
      }.length,
      3,
    );
    expect(sourceIconGlyphs['ic_bank_logo'], Icons.account_balance);
    expect(sourceIconGlyphs['ic_mastercard_logo'], Icons.credit_card);
    expect(sourceIconGlyphs['ic_visa'], Icons.credit_card);
  });

  test(
    'scenario and illustration slots load project-owned raster assets',
    () async {
      final scenario = createDemoScenario();
      expect(scenario.homeBanners, hasLength(2));
      expect(scenario.productBanners, hasLength(6));
      final paths = {
        ...sourceAssetPaths.values,
        SourceCatalogContent.loyaltyArt,
        for (final card in scenario.initialSnapshot.cards)
          if (card.artAssetPath != null) card.artAssetPath!,
        for (final banner in [
          ...scenario.homeBanners,
          ...scenario.productBanners,
        ])
          banner.assetPath,
      };
      for (final path in paths) {
        expect(path, startsWith('assets/brand/'));
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0), reason: path);
        expect(frame.image.height, greaterThan(0), reason: path);
        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  testWidgets('all semantic Material controls render without asset fallbacks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final name in sourceIconGlyphs.keys) SourceIcon(name),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Icon), findsNWidgets(sourceIconGlyphs.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('semantic icons preserve bounds/color and loading feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SourceIcon(
              'ic_close',
              size: 30,
              width: 48,
              height: 18,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SourceIcon)), const Size(48, 18));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.close);
    expect(icon.size, 30);
    expect(icon.color, Colors.red);
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: SourceIcon('loader_mobile_determining', size: 20)),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.getSize(find.byType(SourceIcon)), const Size(20, 20));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown semantic icon names remain errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SourceIcon('missing-semantic-name')),
    );
    expect(tester.takeException(), isFlutterError);
  });
  test(
    'all source emoji and nested variants are bundled with exact PNG dimensions',
    () async {
      final paths = <String>{
        SourceEmojiCatalog.recentAssetPath,
        SourceEmojiCatalog.backspaceAssetPath,
      };
      void visit(SourceEmoji emoji) {
        expect(emoji.text, isNotEmpty);
        paths.add(emoji.assetPath);
        for (final variant in emoji.variants) {
          visit(variant);
        }
      }

      for (final category in SourceEmojiCatalog.categories) {
        paths.add(category.tabAssetPath);
        for (final emoji in category.emojis) {
          visit(emoji);
        }
      }
      expect(SourceEmojiCatalog.categories.length, 8);
      expect(SourceEmojiCatalog.smileysAndPeople.length, 460);
      expect(paths.length, 3021);
      for (final path in paths) {
        final data = await rootBundle.load(path);
        expect(data.getUint32(0), 0x89504e47, reason: path);
        final expected = path.contains('/tabs/') ? 72 : 64;
        expect(data.getUint32(16), expected, reason: path);
        expect(data.getUint32(20), expected, reason: path);
      }
    },
  );
}
