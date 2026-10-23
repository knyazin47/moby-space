import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/family_content.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../core/ui/mt_back_button.dart';
import '../../data/bank_data.dart';
import '../../data/family/family_store.dart';

/// Shared components for the new, light MTBank family screens.
class FamilyPage extends StatelessWidget {
  const FamilyPage({
    required this.title,
    required this.child,
    this.actions,
    this.showAppBar = true,
    super.key,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              leading: const MtBackButton(fallback: '/home'),
              actions: actions,
            )
          : null,
      body: SafeArea(top: !showAppBar, child: child),
    ),
  );
}

class FamilyFieldLabel extends StatelessWidget {
  const FamilyFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}

/// Нижняя кнопка шага визарда — как _BottomNext в recorded_forms.dart.
class FamilyBottomButton extends StatelessWidget {
  const FamilyBottomButton({
    required this.label,
    required this.onPressed,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(MtBrandMetrics.pagePadding),
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(MtBrandMetrics.buttonHeight),
      ),
      child: Text(label),
    ),
  );
}

/// Свитч в стиле _SettingsSwitch из recorded_pages.dart.
class FamilySwitch extends StatelessWidget {
  const FamilySwitch({
    required this.label,
    required this.value,
    this.onChanged,
    this.note,
    super.key,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? note;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              if (note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    note!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: MtBrandColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: Transform.scale(
            scale: .8,
            alignment: Alignment.centerRight,
            child: Theme(
              data: ThemeData(
                useMaterial3: false,
                colorScheme: Theme.of(context).colorScheme,
              ),
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: MtBrandColors.blue,
                activeTrackColor: MtBrandColors.blue.withValues(alpha: .25),
                inactiveThumbColor: const Color(0xFFFAF9FD),
                inactiveTrackColor: const Color(0xFFE1E0EB),
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Заголовок секции в списке продуктов.
class FamilySectionLabel extends StatelessWidget {
  const FamilySectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, color: MtBrandColors.secondary),
    ),
  );
}

/// Светлая инфо-карточка с иконкой — юридическая справка, условия пакета.
class FamilyInfoCard extends StatelessWidget {
  const FamilyInfoCard({
    required this.text,
    this.icon = Icons.info_outline,
    super.key,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: MtBrandColors.cloud,
      borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: MtBrandColors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: MtBrandColors.secondary,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Карточка ребёнка на вкладке «Продукты»: имя, группа, статус, баланс.
class ChildCard extends StatelessWidget {
  const ChildCard({required this.child, super.key});

  final FamilyChild child;

  @override
  Widget build(BuildContext context) => Material(
    color: MtBrandColors.white,
    borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/family/child/${child.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: MtBrandColors.border),
          borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: MtBrandColors.sky.withValues(alpha: .4),
              child: Text(
                child.name.characters.first.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MtBrandColors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${childAgeGroupLabel(child.ageGroup)} · '
                    '${childCardStatusLabel(child.cardStatus)}'
                    '${child.accessStatus == ChildAccessStatus.granted ? '' : ' · ${FamilyContent.accessNone}'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: MtBrandColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatMoney(child.balance),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Строка мок-операции детского счёта со статусом
/// (ждёт подтверждения / отклонена — показываются под заголовком).
class ChildOperationRow extends StatelessWidget {
  const ChildOperationRow({required this.operation, super.key});

  final ChildOperation operation;

  @override
  Widget build(BuildContext context) {
    final declined = operation.status == ChildOperationStatus.declined;
    final pending = operation.status == ChildOperationStatus.pendingApproval;
    return Opacity(
      opacity: declined ? .55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SourceIcon(
              operation.incoming
                  ? 'ic_operation_refill'
                  : 'ic_operation_item_success',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    operation.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pending
                        ? '${operation.subtitle} · ${FamilyContent.opPending}'
                        : declined
                        ? '${operation.subtitle} · ${FamilyContent.opDeclined}'
                        : operation.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: declined
                          ? MtBrandColors.red
                          : pending
                          ? MtBrandColors.blue
                          : MtBrandColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatMoney(
                operation.amount,
                signed: true,
                incoming: operation.incoming,
              ),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: operation.incoming
                    ? MtBrandColors.success
                    : MtBrandColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Слайдер денежного лимита: значение приходит из стора
/// в minor units, onChanged отдаёт minor units обратно.
class FamilyLimitSlider extends StatelessWidget {
  const FamilyLimitSlider({
    required this.label,
    required this.minorUnits,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int minorUnits;

  /// Диапазон в рублях (BYN) — как в визарде.
  final double min;
  final double max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final rub = minorUnits / 100;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
            Text(
              formatMoney(Money(minorUnits)),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Slider(
          value: rub.clamp(min, max),
          min: min,
          max: max,
          onChanged: (value) => onChanged((value * 100).round()),
        ),
      ],
    );
  }
}

/// Секция-контейнер: белая карточка с заголовком — группирует
/// настройки кабинета и лендинга в читаемые блоки.
class FamilyCard extends StatelessWidget {
  const FamilyCard({required this.children, this.title, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: MtBrandColors.white,
      borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
      border: Border.all(color: MtBrandColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ...children,
      ],
    ),
  );
}

/// Центрирование контента с ограничением ширины —
/// на широких экранах флоу не растягивается во всю ширину.
class FamilyMaxWidth extends StatelessWidget {
  const FamilyMaxWidth({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: MtBrandMetrics.maxContentWidth,
      ),
      child: child,
    ),
  );
}

/// Карточка запроса ребёнка или операции на подтверждении:
/// заголовок + кнопки «Разрешить»/«Отклонить».
class FamilyRequestCard extends StatelessWidget {
  const FamilyRequestCard({
    required this.title,
    required this.subtitle,
    required this.onApprove,
    required this.onDeny,
    this.approveLabel = FamilyContent.requestApprove,
    this.denyLabel = FamilyContent.requestDeny,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final String approveLabel;
  final String denyLabel;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: MtBrandColors.white,
      borderRadius: BorderRadius.circular(MtBrandMetrics.radius),
      border: Border.all(color: MtBrandColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: MtBrandColors.secondary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: onApprove,
                style: FilledButton.styleFrom(
                  backgroundColor: MtBrandColors.sky.withValues(alpha: .4),
                  foregroundColor: MtBrandColors.blue,
                ),
                child: Text(approveLabel),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: onDeny,
                style: OutlinedButton.styleFrom(
                  foregroundColor: MtBrandColors.red,
                  side: BorderSide(
                    color: MtBrandColors.red.withValues(alpha: .4),
                  ),
                ),
                child: Text(denyLabel),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
