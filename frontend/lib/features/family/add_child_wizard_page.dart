import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/family_content.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/bank_data.dart';
import '../../data/family/family_store.dart';
import 'family_widgets.dart';

/// Родительский визард: данные → согласия → подтверждение (SMS-код).
/// Настройки пакета берутся по умолчанию по возрастной группе —
/// все они потом меняются в кабинете ребёнка.
class AddChildWizardPage extends ConsumerStatefulWidget {
  const AddChildWizardPage({super.key});

  @override
  ConsumerState<AddChildWizardPage> createState() => _AddChildWizardPageState();
}

class _AddChildWizardPageState extends ConsumerState<AddChildWizardPage> {
  final _name = TextEditingController();
  DateTime? _birthDate;
  String? _dataError;
  bool _consentPersonal = false;
  bool _consentData = false;
  bool _consentPackage = false;
  int _step = 0;

  static const _steps = [
    FamilyContent.stepData,
    FamilyContent.stepConsents,
    FamilyContent.stepSummary,
  ];

  ChildAgeGroup? get _group =>
      _birthDate == null ? null : childAgeGroup(_birthDate!);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 10),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dataError = _validateBirthDate(picked);
      });
    }
  }

  /// Возраст должен быть 7–17 — по нему вычисляется группа (ГК РБ).
  String? _validateBirthDate(DateTime date) =>
      childAgeGroup(date) == null ? FamilyContent.ageOutOfRange : null;

  bool get _dataValid => _name.text.trim().isNotEmpty && _group != null;

  bool get _canContinue => switch (_step) {
    0 => _dataValid,
    1 => _consentPersonal && _consentData && _consentPackage,
    _ => true,
  };

  void _next() {
    if (!_canContinue) return;
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      return;
    }
    _issue();
  }

  /// Оформление пакета с дефолтными настройками возрастной группы —
  /// SMS-подтверждение временно отключено.
  void _issue() {
    final group = _group!;
    final services = defaultServicesFor(group);
    final child = ref
        .read(familyProvider.notifier)
        .issuePackage(
          name: _name.text,
          birthDate: _birthDate!,
          ageGroup: group,
          cardType: ChildCardType.physical,
          permissions: defaultPermissionsFor(group),
          blockedCategories: const {},
          services: services,
          limits: ChildLimits(
            dailyLimit: Money(10000),
            monthlyLimit: Money(40000),
            approvalThreshold: Money(5000),
          ),
          pocketMoney: services.contains(FamilyService.pocketMoney)
              ? PocketMoney(
                  amount: Money(2000),
                  period: PocketMoneyPeriod.weekly,
                )
              : null,
        );
    context.pushReplacement('/family/success?id=${child.id}');
  }

  @override
  Widget build(BuildContext context) => FamilyPage(
    title: FamilyContent.wizardTitle,
    child: ColoredBox(
      color: MtBrandColors.cloud,
      child: Column(
        children: [
          Expanded(
            child: FamilyMaxWidth(
              child: ListView(
                padding: const EdgeInsets.all(MtBrandMetrics.pagePadding),
                children: [
                  Text(
                    'Шаг ${_step + 1} из ${_steps.length} · ${_steps[_step]}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: MtBrandColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  switch (_step) {
                    0 => _dataStep(),
                    1 => _consentsStep(),
                    _ => _summaryStep(),
                  },
                ],
              ),
            ),
          ),
          FamilyMaxWidth(
            child: FamilyBottomButton(
              label: _step == _steps.length - 1
                  ? FamilyContent.confirm
                  : FamilyContent.next,
              onPressed: _canContinue ? _next : null,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _dataStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const FamilyFieldLabel(FamilyContent.childName),
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          hintText: FamilyContent.childNameHint,
        ),
      ),
      const SizedBox(height: 24),
      const FamilyFieldLabel(FamilyContent.birthDate),
      GestureDetector(
        onTap: _pickBirthDate,
        child: InputDecorator(
          decoration: const InputDecoration(
            hintText: FamilyContent.birthDateHint,
          ),
          isEmpty: _birthDate == null,
          child: _birthDate == null
              ? const SizedBox.shrink()
              : Text(
                  formatDate(_birthDate!),
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ),
      if (_dataError != null) ...[
        const SizedBox(height: 12),
        Text(
          _dataError!,
          style: const TextStyle(fontSize: 13, color: MtBrandColors.red),
        ),
      ],
      if (_group != null) ...[
        const SizedBox(height: 24),
        const FamilyFieldLabel(FamilyContent.ageGroup),
        Text(
          childAgeGroupLabel(_group!),
          style: const TextStyle(
            fontFamily: 'TikTokSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Права ребёнка по ГК РБ для вычисленной группы — это определяет
        // состав пакета и набор согласий на следующем шаге.
        FamilyInfoCard(
          text: _group == ChildAgeGroup.junior
              ? FamilyContent.legalJuniorCard
              : '${FamilyContent.legalTeenCard}\n\n'
                    '${FamilyContent.legalTeenEarningsNote}',
        ),
      ],
    ],
  );

  Widget _consentsStep() {
    final junior = _group == ChildAgeGroup.junior;
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            junior
                ? FamilyContent.consentDealJunior
                : FamilyContent.consentDealTeen,
            style: const TextStyle(fontSize: 15),
          ),
          value: _consentPersonal,
          onChanged: (value) =>
              setState(() => _consentPersonal = value ?? false),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            FamilyContent.consentDataProcessing,
            style: TextStyle(fontSize: 15),
          ),
          value: _consentData,
          onChanged: (value) => setState(() => _consentData = value ?? false),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            FamilyContent.consentPackage,
            style: TextStyle(fontSize: 15),
          ),
          value: _consentPackage,
          onChanged: (value) =>
              setState(() => _consentPackage = value ?? false),
        ),
      ],
    );
  }

  Widget _summaryStep() => Column(
    children: [
      _SummaryRow(FamilyContent.childName, _name.text.trim()),
      _SummaryRow(FamilyContent.birthDate, formatDate(_birthDate!)),
      _SummaryRow(FamilyContent.ageGroup, childAgeGroupLabel(_group!)),
      const _SummaryRow(FamilyContent.cardTypeLabel, 'Физическая карта'),
      const _SummaryRow(FamilyContent.dailyLimit, '100 BYN'),
      const _SummaryRow(FamilyContent.adultBlocked, 'Всегда'),
      const SizedBox(height: 24),
      const FamilyInfoCard(
        text:
            'Разрешения, лимиты, категории и карманные деньги '
            'подставлены по возрасту — всё это можно изменить '
            'в профиле ребёнка после оформления.',
      ),
    ],
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: MtBrandColors.secondary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
