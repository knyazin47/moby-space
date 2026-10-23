import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tests turn this off: headless PNGs cannot render mobile platform views.
final nativeProgressEnabledProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS),
);

class NativeProgress extends ConsumerWidget {
  const NativeProgress({super.key, this.size = 48});
  final double size;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Semantics(
    label: 'Загрузка',
    child: SizedBox(
      width: size,
      height: size,
      child: !ref.watch(nativeProgressEnabledProvider)
          ? const SizedBox(key: ValueKey('native-progress-headless'))
          : switch (defaultTargetPlatform) {
              TargetPlatform.android => const AndroidView(
                viewType: 'moby/native-progress',
                creationParamsCodec: StandardMessageCodec(),
                layoutDirection: TextDirection.ltr,
              ),
              TargetPlatform.iOS => const UiKitView(
                viewType: 'moby/native-progress',
                creationParamsCodec: StandardMessageCodec(),
                layoutDirection: TextDirection.ltr,
              ),
              _ => const SizedBox(key: ValueKey('native-progress-headless')),
            },
    ),
  );
}
