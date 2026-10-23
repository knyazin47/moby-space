import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/demo_motion.dart';
import '../../core/config/family_content.dart';
import '../../core/config/observed_web_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/native_progress.dart';

/// Operator-only reconstruction: the recording does not establish its entry.
/// The native host denies navigation and network access. Checkboxes live only
/// inside this Android/iOS platform view and disappear on route disposal.
class ObservedWebPage extends ConsumerStatefulWidget {
  const ObservedWebPage({super.key});

  @override
  ConsumerState<ObservedWebPage> createState() => _ObservedWebPageState();
}

enum _ObservedWebStage { blank, loading, frame, content }

class _ObservedWebPageState extends ConsumerState<ObservedWebPage> {
  late final Timer _timer;
  var _stage = _ObservedWebStage.blank;

  @override
  void initState() {
    super.initState();
    // Replay intervals are synthetic; the observed order is retained.
    _timer = Timer.periodic(DemoMotion.bodyLoad, (timer) {
      if (!mounted) return;
      setState(() => _stage = _ObservedWebStage.values[_stage.index + 1]);
      if (_stage == _ObservedWebStage.content) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final native = ref.watch(nativeProgressEnabledProvider);
    return MobyPage(
      title: ObservedWebContent.toolbarTitle,
      child: Column(
        children: [
          Expanded(
            child: KeyedSubtree(
              key: ValueKey('reference-web-${_stage.name}'),
              child: switch (_stage) {
                _ObservedWebStage.blank => const SizedBox.expand(),
                _ObservedWebStage.loading => const Center(
                  child: NativeProgress(size: 24),
                ),
                _ObservedWebStage.frame => SizedBox.expand(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E3EB)),
                    ),
                  ),
                ),
                _ObservedWebStage.content =>
                  native
                      ? _nativeContent()
                      : const Center(
                          key: ValueKey('reference-web-headless'),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              ObservedWebContent.headlessNotice,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
              },
            ),
          ),
          // Демо-вход детского флоу на экране входа/регистрации.
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: OutlinedButton(
              onPressed: () => context.push('/child/pair'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
                side: const BorderSide(color: MobyColors.brand),
                foregroundColor: MobyColors.brand,
              ),
              child: const Text(FamilyContent.iAmChild),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nativeContent() => switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidView(
      key: const ValueKey('reference-web-native'),
      viewType: 'moby/offline-web',
      creationParams: {
        'html': ObservedWebContent.html,
        'closeLabel': ObservedWebContent.close,
      },
      creationParamsCodec: const StandardMessageCodec(),
      layoutDirection: TextDirection.ltr,
    ),
    TargetPlatform.iOS => UiKitView(
      key: const ValueKey('reference-web-native'),
      viewType: 'moby/offline-web',
      creationParams: {
        'html': ObservedWebContent.html,
        'closeLabel': ObservedWebContent.close,
      },
      creationParamsCodec: const StandardMessageCodec(),
      layoutDirection: TextDirection.ltr,
    ),
    _ => const SizedBox(key: ValueKey('reference-web-headless')),
  };
}
