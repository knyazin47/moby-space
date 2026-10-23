import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/family_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/family/family_store.dart';
import 'family_widgets.dart';

/// Экран успеха после родительского визарда.
class ChildSuccessPage extends ConsumerWidget {
  const ChildSuccessPage({required this.childId, super.key});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(familyProvider).childById(childId);

    return FamilyPage(
      title: '',
      child: ColoredBox(
        color: MtBrandColors.cloud,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            FamilyMaxWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: MtBrandColors.blue,
                    child: Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    FamilyContent.successTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    FamilyContent.successBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: MtBrandColors.secondary,
                    ),
                  ),
                  if (child != null) ...[
                    const SizedBox(height: 32),
                    ChildCard(child: child),
                  ],
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => context.pushReplacement(
                      '/family/child/$childId/access',
                    ),
                    child: const Text(FamilyContent.grantAccessAction),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/products'),
                    child: const Text(FamilyContent.later),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
