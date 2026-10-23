import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/family_content.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';
import '../../data/family/family_store.dart';
import 'family_widgets.dart';

/// Заглушка детской главной после подтверждения привязки.
class ChildHomePage extends ConsumerWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = Money(5000);
    final operations = mockChildOperations();

    return FamilyPage(
      title: FamilyContent.childHomeTitle,
      child: ListView(
        padding: const EdgeInsets.all(MtBrandMetrics.pagePadding),
        children: [
          const Text(
            FamilyContent.childHomeGreeting,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            FamilyContent.childHomeStub,
            style: TextStyle(fontSize: 13, color: MtBrandColors.secondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MtBrandColors.blue, MtBrandColors.soft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    SourceIcon('ic_cards', size: 24, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      FamilyContent.childMyCard,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formatMoney(balance),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ChildAction(
            icon: 'ic_wallet',
            label: FamilyContent.childAskMoney,
          ),
          const SizedBox(height: 24),
          const Text(
            FamilyContent.childMyOperations,
            style: TextStyle(
              fontFamily: 'TikTokSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final operation in operations)
            ChildOperationRow(operation: operation),
        ],
      ),
    );
  }
}

class _ChildAction extends StatelessWidget {
  const _ChildAction({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: MtBrandColors.white,
      borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
      border: Border.all(color: MtBrandColors.border),
    ),
    child: Row(
      children: [
        SourceIcon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
