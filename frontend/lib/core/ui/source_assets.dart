import 'package:flutter/material.dart';

import 'source_asset_paths.dart';

/// Semantic app icon backed by a Material glyph or project-owned illustration.
/// Unknown names fail explicitly rather than rendering an unrelated fallback.
class SourceIcon extends StatelessWidget {
  const SourceIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
    this.width,
    this.height,
  });
  final String name;
  final double size;
  final double? width;
  final double? height;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final path = sourceAssetPaths[name];
    final glyph = sourceIconGlyphs[name];
    final progress = sourceProgressIconNames.contains(name);
    if (path == null && glyph == null && !progress) {
      throw FlutterError('Missing semantic icon: $name');
    }
    return Align(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox(
        width: width ?? size,
        height: height ?? size,
        child: progress
            ? CircularProgressIndicator(color: color, strokeWidth: 2)
            : path != null
            ? Image.asset(
                path,
                width: width ?? size,
                height: height ?? size,
                fit: BoxFit.contain,
                color: color,
              )
            : FittedBox(
                fit: BoxFit.contain,
                child: Icon(glyph, size: size, color: color),
              ),
      ),
    );
  }
}
