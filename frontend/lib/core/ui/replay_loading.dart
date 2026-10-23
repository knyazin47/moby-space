import 'dart:async';

import 'package:flutter/material.dart';

import '../config/demo_motion.dart';
import 'native_progress.dart';

/// An observed loading surface replayed with an explicit synthetic delay.
class ReplayBodyLoading extends StatefulWidget {
  const ReplayBodyLoading({
    super.key,
    required this.child,
    this.background = Colors.white,
  });
  final Widget child;
  final Color background;
  @override
  State<ReplayBodyLoading> createState() => _ReplayBodyLoadingState();
}

class _ReplayBodyLoadingState extends State<ReplayBodyLoading> {
  Timer? _timer;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _timer = Timer(DemoMotion.bodyLoad, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? ColoredBox(
          color: widget.background,
          child: const Center(child: NativeProgress()),
        )
      : widget.child;
}
