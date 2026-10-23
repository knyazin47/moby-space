import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/family_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../data/family/family_store.dart';
import 'family_widgets.dart';

/// Выдача ребёнку доступа в Moby (ТЗ 3.1 «Даёт ребёнку доступ в Moby.
/// Согласие подтверждается в приложении»). Скан QR/код — имитация,
/// как в SourceQrPaymentPage: камера в офлайн-сборке не используется.
class ChildAccessPage extends ConsumerWidget {
  const ChildAccessPage({required this.childId, super.key});

  final String childId;

  /// После валидного кода — диалог согласия, затем доступ открывается.
  Future<void> _confirmAccess(BuildContext context, WidgetRef ref) async {
    final child = ref.read(familyProvider).childById(childId);
    final granted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(FamilyContent.accessConsentTitle),
        content: Text(
          '${child?.name ?? ''} — ${FamilyContent.accessGrantedBody}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(FamilyContent.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(FamilyContent.accessGive),
          ),
        ],
      ),
    );
    if (granted == true && context.mounted) {
      ref.read(familyProvider.notifier).grantAccess(childId);
      context.pushReplacement('/family/child/$childId');
    }
  }

  void _linked(BuildContext context, WidgetRef ref, String input) {
    final linked = ref.read(familyProvider.notifier).linkByToken(input);
    if (linked) _confirmAccess(context, ref);
  }

  Future<void> _manualCode(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    var invalid = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text(FamilyContent.manualCodeTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: FamilyContent.manualCodeHint,
              errorText: invalid ? FamilyContent.manualCodeInvalid : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(FamilyContent.cancel),
            ),
            FilledButton(
              onPressed: () {
                final linked = ref
                    .read(familyProvider.notifier)
                    .linkByToken(controller.text);
                if (linked) {
                  Navigator.of(dialogContext).pop(true);
                } else {
                  setState(() => invalid = true);
                }
              },
              child: const Text(FamilyContent.manualCodeConfirm),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      _confirmAccess(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => FamilyPage(
    title: FamilyContent.accessTitle,
    child: ColoredBox(
      color: MtBrandColors.cloud,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FamilyMaxWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  FamilyContent.accessHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'TikTokSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: MtBrandColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: MtBrandColors.border),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SourceIcon('ic_qr_code_scan', size: 72),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          FamilyContent.cameraUnavailable,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: MtBrandColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => _linked(context, ref, childPairToken),
                  child: const Text(FamilyContent.simulateScan),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _manualCode(context, ref),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: MtBrandColors.blue),
                    foregroundColor: MtBrandColors.blue,
                  ),
                  child: const Text(FamilyContent.manualCode),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
