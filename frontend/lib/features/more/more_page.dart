import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(bankRepositoryProvider).scenario.moreItems;

    return ColoredBox(
      color: MobyColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i < 2 ? 26 : 24),
                child: _MoreRow(
                  item: items[i],
                  onTap: () => context.push(items[i].route),
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {},
              onLongPress: () => context.push('/demo'),
              style: TextButton.styleFrom(
                foregroundColor: MobyColors.secondary,
                minimumSize: const Size(48, 48),
              ),
              child: const Text(
                AppCopy.version,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.item, required this.onTap});

  final DemoMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: MobyColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: MobyColors.rowBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const SourceIcon('oval_dotted', size: 40),
                    SourceIcon(_moreIcon(item.iconName)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: MobyColors.legacyText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 9,
                  height: 24,
                  child: SourceIcon('ic_arrow_right'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

String _moreIcon(String name) => switch (name) {
  'settings' => 'ic_settings',
  'person' => 'ic_user_data',
  'description' => 'ic_agreement',
  'notifications' => 'ic_notification_common',
  'currency_exchange' => 'ic_currency_rates',
  'loyalty' => 'ic_manichki',
  'swap_horiz' => 'ic_nembo_exchange',
  'location_on' => 'ic_location_marker',
  'info' => 'ic_info',
  'security' => 'ic_safety',
  _ => name,
};
