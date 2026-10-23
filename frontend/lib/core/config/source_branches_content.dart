/// Source-confirmed map/filter labels and explicit local fallback copy.
/// No runtime bank point, address, coordinate, map tile or region is invented.
abstract final class SourceBranchesContent {
  static const title = 'Точки обслуживания';
  static const search = 'Поиск';
  static const searchLimit = 255;
  static const clear = 'Очистить';
  static const cancel = 'Отмена';
  static const filter = 'Фильтр';
  static const reset = 'Сбросить';
  static const apply = 'Применить';
  static const back = 'Назад';
  static const workingNow = 'Работают сейчас';
  static const region = 'Регион';
  static const metro = 'Метро';
  static const services = 'Точки обслуживания';
  static const currency = 'Валюта';
  static const location = 'Местоположение';
  static const locationUnavailable = 'Определение местоположения недоступно.';
  static const unavailableTitle = 'Точки обслуживания недоступны';
  static const unavailableBody =
      'Не удалось загрузить список точек обслуживания. Повторите попытку позже.';
  static const choicesUnavailable = 'Данные временно недоступны.';
  static const retry = 'Повторить';
  static const close = 'Закрыть';
  static const loadingDuration = Duration(milliseconds: 450);

  // XML provides a TabLayout, but not runtime tab names. These labels are
  // local navigation copy, not claimed to have been observed in the recording.
  static const tabs = <SourceBranchesView, String>{
    SourceBranchesView.map: 'На карте',
    SourceBranchesView.list: 'Список',
  };
  static const kinds = <SourceBranchKind, String>{
    SourceBranchKind.department: 'Отделение',
    SourceBranchKind.atm: 'Банкомат',
  };
  static const currencies = <SourceBranchCurrency, String>{
    SourceBranchCurrency.byn: 'BYN',
    SourceBranchCurrency.usd: 'USD',
    SourceBranchCurrency.eur: 'EUR',
  };
  static const currencyAssets = <SourceBranchCurrency, String>{
    SourceBranchCurrency.byn: 'image_byn',
    SourceBranchCurrency.usd: 'image_usd',
    SourceBranchCurrency.eur: 'image_eur',
  };
}

enum SourceBranchesView { map, list }

enum SourceBranchKind { department, atm }

enum SourceBranchCurrency { byn, usd, eur }

/// Immutable local filter draft. Defaults are explicit local UI choices;
/// applying filters never implies that an unavailable catalog was searched.
final class SourceBranchesFilter {
  SourceBranchesFilter({
    this.workingNow = false,
    Set<SourceBranchKind> kinds = const {
      SourceBranchKind.department,
      SourceBranchKind.atm,
    },
    Set<SourceBranchCurrency> currencies = const {},
  }) : kinds = Set.unmodifiable(kinds),
       currencies = Set.unmodifiable(currencies);

  final bool workingNow;
  final Set<SourceBranchKind> kinds;
  final Set<SourceBranchCurrency> currencies;
  bool get isActive =>
      workingNow ||
      kinds.length != SourceBranchKind.values.length ||
      currencies.isNotEmpty;

  SourceBranchesFilter copyWith({
    bool? workingNow,
    Set<SourceBranchKind>? kinds,
    Set<SourceBranchCurrency>? currencies,
  }) => SourceBranchesFilter(
    workingNow: workingNow ?? this.workingNow,
    kinds: kinds ?? this.kinds,
    currencies: currencies ?? this.currencies,
  );
}
