import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/family_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/family/family_store.dart';
import 'family_widgets.dart';

/// Лендинг семейного пакета (ТЗ 3.1 «Родитель узнаёт о пакете»):
/// что получит семья, условия и права по возрастной группе.
class FamilyPackagePage extends StatefulWidget {
  const FamilyPackagePage({super.key});

  @override
  State<FamilyPackagePage> createState() => _FamilyPackagePageState();
}

class _FamilyPackagePageState extends State<FamilyPackagePage> {
  ChildAgeGroup _group = ChildAgeGroup.junior;

  @override
  Widget build(BuildContext context) => FamilyPage(
    title: FamilyContent.packageTitle,
    child: ColoredBox(
      color: MtBrandColors.cloud,
      child: Column(
        children: [
          Expanded(
            child: FamilyMaxWidth(
              child: ListView(
                padding: const EdgeInsets.all(MtBrandMetrics.pagePadding),
                children: [
                  const Text(
                    FamilyContent.packageSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: MtBrandColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<ChildAgeGroup>(
                    segments: [
                      for (final group in ChildAgeGroup.values)
                        ButtonSegment(
                          value: group,
                          label: Text(childAgeGroupLabel(group)),
                        ),
                    ],
                    selected: {_group},
                    onSelectionChanged: (value) =>
                        setState(() => _group = value.first),
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? MtBrandColors.blue
                            : MtBrandColors.white,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : MtBrandColors.blue,
                      ),
                      side: const WidgetStatePropertyAll(
                        BorderSide(color: MtBrandColors.sky),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    FamilyContent.packageComposition,
                    style: TextStyle(
                      fontFamily: 'TikTokSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _PackageItem(FamilyContent.packageCardItem),
                  const _PackageItem(FamilyContent.packagePocketItem),
                  const _PackageItem(FamilyContent.packageGoalItem),
                  const _PackageItem(FamilyContent.packageInsuranceItem),
                  const _PackageItem(FamilyContent.packageEducationItem),
                  const _PackageItem(FamilyContent.packagePartnersItem),
                  const SizedBox(height: 8),
                  // Отличие групп: кто выпускает продукты (правовые рамки).
                  _PackageItem(
                    _group == ChildAgeGroup.junior
                        ? FamilyContent.packageJuniorRights
                        : FamilyContent.packageTeenRights,
                    highlight: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    FamilyContent.legalRightsTitle,
                    style: TextStyle(
                      fontFamily: 'TikTokSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FamilyInfoCard(
                    text: _group == ChildAgeGroup.junior
                        ? FamilyContent.legalJuniorCard
                        : '${FamilyContent.legalTeenCard}\n\n'
                              '${FamilyContent.legalTeenEarningsNote}',
                    icon: Icons.gavel_outlined,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    FamilyContent.packageConditions,
                    style: TextStyle(
                      fontFamily: 'TikTokSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const FamilyInfoCard(
                    text: FamilyContent.packageConditionsBody,
                    icon: Icons.percent,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    FamilyContent.packageSafety,
                    style: TextStyle(
                      fontFamily: 'TikTokSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const FamilyInfoCard(
                    text: FamilyContent.packageSafetyBody,
                    icon: Icons.shield_outlined,
                  ),
                ],
              ),
            ),
          ),
          FamilyMaxWidth(
            child: FamilyBottomButton(
              label: FamilyContent.issuePackage,
              onPressed: () => context.push('/family/apply'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PackageItem extends StatelessWidget {
  const _PackageItem(this.text, {this.highlight = false});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          highlight ? Icons.star_outline : Icons.check_circle_outline,
          size: 18,
          color: MtBrandColors.blue,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}
