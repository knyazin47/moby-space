import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/demo_motion.dart';
import '../../core/config/app_copy.dart';
import '../../core/ui/common.dart';
import '../../core/ui/native_progress.dart';
import '../../core/ui/source_assets.dart';
import '../../core/theme/app_theme.dart';

/// Replays the observed loading → unavailable sheet, without bank requests.
class CardApplicationPage extends StatefulWidget {
  const CardApplicationPage({super.key});
  @override
  State<CardApplicationPage> createState() => _CardApplicationPageState();
}

class _CardApplicationPageState extends State<CardApplicationPage> {
  Timer? _timer;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _timer = Timer(DemoMotion.cardApplicationLoad, _showUnavailable);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showUnavailable() async {
    if (!mounted) return;
    setState(() => _loading = false);
    final contact = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      sheetAnimationStyle: const AnimationStyle(
        duration: DemoMotion.sheetEnter,
        reverseDuration: DemoMotion.sheetExit,
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SourceIcon('ic_action_error', size: 32),
                const SizedBox(height: 16),
                const Text(
                  AppCopy.applicationUnavailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppCopy.applicationUnavailableHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: MobyColors.danger),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => Navigator.pop(sheetContext, true),
                  child: const Column(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SourceIcon('oval_dotted', size: 56),
                            SourceIcon(
                              'menu_icon_chat',
                              size: 24,
                              color: MobyColors.brand,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        AppCopy.contactBank,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: const Text(AppCopy.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    final router = GoRouter.of(context);
    router.canPop() ? router.pop() : router.go('/home');
    if (contact == true) router.push('/chat');
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: AppCopy.applyCard,
    child: Center(
      child: _loading ? const NativeProgress() : const SizedBox.shrink(),
    ),
  );
}
