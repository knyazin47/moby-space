import 'package:flutter/material.dart';
import 'family_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/config/family_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../core/ui/native_progress.dart';
import '../../data/family/family_store.dart';

/// Экран ребёнка: QR с токеном привязки и ожидание подтверждения родителя.
/// Скрытый демо-триггер — долгое нажатие на QR имитирует подтверждение.
class ChildPairPage extends ConsumerStatefulWidget {
  const ChildPairPage({super.key});

  @override
  ConsumerState<ChildPairPage> createState() => _ChildPairPageState();
}

class _ChildPairPageState extends ConsumerState<ChildPairPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyProvider.notifier).startPairing();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(familyProvider.select((state) => state.pairing.status), (
      previous,
      status,
    ) {
      if (status == FamilyPairStatus.linked && context.mounted) {
        context.pushReplacement('/child/home');
      }
    });
    final token =
        ref.watch(familyProvider.select((state) => state.pairing.token)) ??
        childPairToken;

    return FamilyPage(
      title: FamilyContent.childPairTitle,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          const Text(
            FamilyContent.childPairHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'TikTokSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onLongPress: () =>
                  ref.read(familyProvider.notifier).simulateParentConfirm(),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: MtBrandColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: MtBrandColors.border),
                ),
                child: QrImageView(
                  data: token,
                  version: QrVersions.auto,
                  size: 220,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: MtBrandColors.ink,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: MtBrandColors.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${FamilyContent.childPairCodeLabel}: '
              '${token.split('=').last}',
              style: const TextStyle(
                fontSize: 13,
                color: MtBrandColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NativeProgress(size: 20),
              SizedBox(width: 12),
              Text(
                FamilyContent.childPairWaiting,
                style: TextStyle(fontSize: 15, color: MtBrandColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Center(
            child: Text(
              FamilyContent.childPairSimulate,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: MtBrandColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
