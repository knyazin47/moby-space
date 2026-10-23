/// Optional discussion starters, never age rules or automatic permissions.
/// Only these four values change; all other policy fields are preserved.
enum SpacePolicyPresetId { firstPurchases, planning, moreIndependence }

final class SpacePolicyPreset {
  const SpacePolicyPreset({
    required this.id,
    required this.title,
    required this.description,
    required this.dailyMinor,
    required this.monthlyMinor,
    required this.approvalMinor,
    required this.internet,
  }) : assert(dailyMinor >= 0 && dailyMinor <= 10000000),
       assert(monthlyMinor >= dailyMinor && monthlyMinor <= 100000000),
       assert(approvalMinor >= 0 && approvalMinor <= 10000000);

  final SpacePolicyPresetId id;
  final String title, description;
  final int dailyMinor, monthlyMinor, approvalMinor;
  final bool internet;

  Map<String, dynamic> preview(Map<String, dynamic> original) => {
    ...original,
    'dailyLimit': dailyMinor,
    'monthlyLimit': monthlyMinor,
    'approvalThreshold': approvalMinor,
    'internet': internet,
    'categories': Map<String, dynamic>.from(original['categories'] as Map),
  };
}

abstract final class SpacePolicyPresets {
  static const values = <SpacePolicyPreset>[
    SpacePolicyPreset(
      id: SpacePolicyPresetId.firstPurchases,
      title: 'Первые покупки',
      description: 'Небольшие повседневные траты с частым согласованием.',
      dailyMinor: 1000,
      monthlyMinor: 5000,
      approvalMinor: 500,
      internet: false,
    ),
    SpacePolicyPreset(
      id: SpacePolicyPresetId.planning,
      title: 'Планирование',
      description: 'Больше места для самостоятельного плана расходов.',
      dailyMinor: 3000,
      monthlyMinor: 15000,
      approvalMinor: 1500,
      internet: false,
    ),
    SpacePolicyPreset(
      id: SpacePolicyPresetId.moreIndependence,
      title: 'Больше самостоятельности',
      description: 'Более широкие лимиты и покупки в интернете.',
      dailyMinor: 5000,
      monthlyMinor: 30000,
      approvalMinor: 3000,
      internet: true,
    ),
  ];
}
