import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/family_content.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';
import '../../data/family/family_store.dart';
import 'family_widgets.dart';

/// Кабинет ребёнка (ТЗ 3.1 «Управляет аккаунтом»): баланс и операции,
/// доступ в Moby, запросы и подтверждения, блокировка и потеря карты,
/// разрешения, лимиты, карманные деньги — всё через [FamilyStore].
class ChildManagePage extends ConsumerWidget {
  const ChildManagePage({required this.childId, super.key});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyProvider);
    final child = family.childById(childId);

    if (child == null) {
      return const FamilyPage(
        title: FamilyContent.manageTitle,
        child: Center(child: Text('Профиль не найден')),
      );
    }

    final notifier = ref.read(familyProvider.notifier);
    final pendingRequests = family.pendingRequestsFor(childId);
    final pendingOps = [
      for (final op in child.operations)
        if (op.status == ChildOperationStatus.pendingApproval) op,
    ];
    final childNotifications = [
      for (final n in family.notifications)
        if (n.childId == childId) n,
    ].take(3);
    final cardActive = child.cardStatus == ChildCardStatus.active;
    final cardFrozen = child.cardStatus == ChildCardStatus.frozen;
    final cardLost = child.cardStatus == ChildCardStatus.lost;
    final cardReissuing = child.cardStatus == ChildCardStatus.reissuing;

    return FamilyPage(
      title: child.name,
      child: ColoredBox(
        color: MtBrandColors.cloud,
        child: ListView(
          padding: const EdgeInsets.all(MtBrandMetrics.pagePadding),
          children: [
            FamilyMaxWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (child.accessStatus == ChildAccessStatus.none) ...[
                    _AccessBanner(childId: child.id),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: cardFrozen || cardLost
                            ? const [MtBrandColors.ink, MtBrandColors.soft]
                            : const [MtBrandColors.blue, MtBrandColors.soft],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        MtBrandMetrics.radius,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SourceIcon(
                              'ic_cards',
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${childAgeGroupLabel(child.ageGroup)} · '
                                '${childCardTypeLabel(child.cardType)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                childCardStatusLabel(child.cardStatus),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          formatMoney(child.balance),
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
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: cardActive || cardFrozen
                              ? () {
                                  notifier.topUp(child.id, Money(5000));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Счёт пополнен на 50 BYN'),
                                    ),
                                  );
                                }
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: MtBrandColors.sky.withValues(
                              alpha: .45,
                            ),
                            foregroundColor: MtBrandColors.blue,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(FamilyContent.topUp),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: cardActive || cardFrozen
                              ? () => notifier.toggleCardFrozen(child.id)
                              : null,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            side: const BorderSide(color: MtBrandColors.red),
                            foregroundColor: MtBrandColors.red,
                          ),
                          icon: Icon(
                            cardFrozen ? Icons.lock_open : Icons.lock_outline,
                            size: 18,
                          ),
                          label: Text(
                            cardFrozen
                                ? FamilyContent.unfreezeCard
                                : FamilyContent.freezeCard,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: cardLost
                              ? () => notifier.reissueCard(child.id)
                              : cardReissuing
                              ? null
                              : () => _reportLost(context, ref, child.id),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: MtBrandColors.red,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(Icons.report_outlined, size: 16),
                          label: Text(
                            cardLost
                                ? FamilyContent.reissueCard
                                : cardReissuing
                                ? childCardStatusLabel(
                                    ChildCardStatus.reissuing,
                                  )
                                : FamilyContent.lostCard,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _fileDispute(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: MtBrandColors.blue,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(Icons.gpp_maybe_outlined, size: 16),
                          label: const Text(FamilyContent.disputeOperation),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (pendingRequests.isNotEmpty) ...[
                    FamilyCard(
                      title: FamilyContent.requestsSection,
                      children: [
                        for (final request in pendingRequests)
                          FamilyRequestCard(
                            title: request.title,
                            subtitle: 'Запрос от ${child.name}',
                            onApprove: () =>
                                notifier.resolveRequest(request.id, true),
                            onDeny: () =>
                                notifier.resolveRequest(request.id, false),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (pendingOps.isNotEmpty) ...[
                    FamilyCard(
                      title: FamilyContent.pendingOpsSection,
                      children: [
                        for (final op in pendingOps)
                          FamilyRequestCard(
                            title: '${op.title} · ${formatMoney(op.amount)}',
                            subtitle: FamilyContent.opPending,
                            approveLabel: FamilyContent.opApprove,
                            onApprove: () => notifier.resolveOperation(
                              child.id,
                              op.id,
                              true,
                            ),
                            onDeny: () => notifier.resolveOperation(
                              child.id,
                              op.id,
                              false,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  FamilyCard(
                    title: FamilyContent.limitsSection,
                    children: [
                      FamilyLimitSlider(
                        label: FamilyContent.dailyLimit,
                        minorUnits: child.limits.dailyLimit.minorUnits,
                        min: 10,
                        max: 300,
                        onChanged: (v) => notifier.updateLimits(
                          child.id,
                          child.limits.copyWith(dailyLimit: Money(v)),
                        ),
                      ),
                      FamilyLimitSlider(
                        label: FamilyContent.monthlyLimit,
                        minorUnits: child.limits.monthlyLimit.minorUnits,
                        min: 50,
                        max: 1000,
                        onChanged: (v) => notifier.updateLimits(
                          child.id,
                          child.limits.copyWith(monthlyLimit: Money(v)),
                        ),
                      ),
                      FamilyLimitSlider(
                        label: FamilyContent.approvalThreshold,
                        minorUnits: child.limits.approvalThreshold.minorUnits,
                        min: 10,
                        max: 200,
                        onChanged: (v) => notifier.updateLimits(
                          child.id,
                          child.limits.copyWith(approvalThreshold: Money(v)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FamilySwitch(
                        label: FamilyContent.pocketMoneyTitle,
                        note: child.pocketMoney == null
                            ? null
                            : '${formatMoney(child.pocketMoney!.amount)} · '
                                  '${pocketMoneyPeriodLabel(child.pocketMoney!.period)}',
                        value: child.pocketMoney != null,
                        onChanged: (value) => notifier.setPocketMoney(
                          child.id,
                          value
                              ? PocketMoney(
                                  amount: Money(2000),
                                  period: PocketMoneyPeriod.weekly,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FamilyCard(
                    title: FamilyContent.canIssueProducts,
                    children: [
                      for (final p in productPermissions) ...[
                        FamilySwitch(
                          label: childPermissionLabel(p),
                          value: child.permissions.contains(p),
                          onChanged: (v) =>
                              notifier.setPermission(child.id, p, v),
                        ),
                        const Divider(height: 1),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  FamilyCard(
                    title: FamilyContent.canDoActions,
                    children: [
                      for (final p in ChildPermission.values.where(
                        (p) => !productPermissions.contains(p),
                      )) ...[
                        FamilySwitch(
                          label: childPermissionLabel(p),
                          value: child.permissions.contains(p),
                          onChanged: (v) =>
                              notifier.setPermission(child.id, p, v),
                        ),
                        const Divider(height: 1),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  FamilyCard(
                    title: FamilyContent.categoriesLabel,
                    children: [
                      const FamilySwitch(
                        label: FamilyContent.adultBlocked,
                        note: FamilyContent.adultBlockedNote,
                        value: true,
                        onChanged: null,
                      ),
                      const Divider(height: 1),
                      for (final c in SpendingCategory.values.where(
                        (c) => !alwaysBlockedCategories.contains(c),
                      )) ...[
                        FamilySwitch(
                          label: spendingCategoryLabel(c),
                          value: child.blockedCategories.contains(c),
                          onChanged: (v) =>
                              notifier.setCategoryBlocked(child.id, c, v),
                        ),
                        const Divider(height: 1),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  FamilyCard(
                    title: FamilyContent.notificationsTitle,
                    children: [
                      if (childNotifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            FamilyContent.notificationsEmpty,
                            style: TextStyle(
                              fontSize: 13,
                              color: MtBrandColors.secondary,
                            ),
                          ),
                        )
                      else
                        for (final n in childNotifications)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: MtBrandColors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    n.text,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: MtBrandColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FamilyCard(
                    title: FamilyContent.manageOperations,
                    children: [
                      for (final operation in child.operations)
                        ChildOperationRow(operation: operation),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FamilyInfoCard(
                    icon: Icons.gavel_outlined,
                    text: child.ageGroup == ChildAgeGroup.junior
                        ? FamilyContent.legalJuniorCard
                        : '${FamilyContent.legalTeenCard}\n\n'
                              '${FamilyContent.legalTeenEarningsNote}',
                  ),
                  const SizedBox(height: 16),
                  // Демо-панель: имитация активности ребёнка на живом демо,
                  // пока детская ветка не влита в общий мок-слой.
                  FamilyCard(
                    children: [
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text(
                            FamilyContent.demoPanel,
                            style: TextStyle(
                              fontSize: 13,
                              color: MtBrandColors.secondary,
                            ),
                          ),
                          children: [
                            _DemoButton(
                              label: FamilyContent.demoBuy,
                              onPressed: () => notifier.simulateChildPurchase(
                                child.id,
                                1500,
                                title: 'Шаурма',
                              ),
                            ),
                            _DemoButton(
                              label: FamilyContent.demoBuyOver,
                              onPressed: () => notifier.simulateChildPurchase(
                                child.id,
                                8000,
                                title: 'Наушники',
                              ),
                            ),
                            _DemoButton(
                              label: FamilyContent.demoCasino,
                              onPressed: () => notifier.simulateChildPurchase(
                                child.id,
                                2500,
                                title: 'Казино «Фортуна»',
                                category: SpendingCategory.gambling,
                              ),
                            ),
                            _DemoButton(
                              label: FamilyContent.demoRequest,
                              onPressed: () =>
                                  notifier.simulateChildRequest(child.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог потери карты: мгновенная блокировка + бесплатный перевыпуск.
  static void _reportLost(BuildContext context, WidgetRef ref, String childId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(FamilyContent.lostCard),
        content: const Text(FamilyContent.lostCardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(FamilyContent.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(familyProvider.notifier).reportCardLost(childId);
              Navigator.of(dialogContext).pop();
            },
            child: const Text(FamilyContent.lostCard),
          ),
        ],
      ),
    );
  }

  /// Заявка по спорной операции — заглушка процесса из ТЗ «Безопасность».
  static void _fileDispute(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(FamilyContent.disputeOperation),
        content: const Text(FamilyContent.disputeBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(FamilyContent.disputeFiled),
          ),
        ],
      ),
    );
  }
}

/// Плашка «нет доступа в Moby» с переходом на экран выдачи.
class _AccessBanner extends StatelessWidget {
  const _AccessBanner({required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: MtBrandColors.sky.withValues(alpha: .35),
      borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
      border: Border.all(color: MtBrandColors.sky),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.phonelink_lock_outlined,
          size: 20,
          color: MtBrandColors.blue,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            FamilyContent.accessNone,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        FilledButton.tonal(
          // Тема задаёт кнопке бесконечную минимальную ширину —
          // в Row без Expanded это ломает лейаут.
          style: FilledButton.styleFrom(
            backgroundColor: MtBrandColors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () => context.push('/family/child/$childId/access'),
          child: const Text(FamilyContent.accessGive),
        ),
      ],
    ),
  );
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        side: const BorderSide(color: MtBrandColors.border),
        foregroundColor: MtBrandColors.ink,
      ),
      child: Text(label),
    ),
  );
}
