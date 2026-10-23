import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// One accessible back control for the new family surfaces only.
class MtBackButton extends StatelessWidget {
  const MtBackButton({this.onPressed, this.fallback = '/family', super.key});
  final VoidCallback? onPressed;
  final String fallback;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    padding: const EdgeInsets.all(12),
    icon: const Icon(Icons.arrow_back_rounded, size: 24),
    onPressed:
        onPressed ??
        () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(fallback);
          }
        },
  );
}
