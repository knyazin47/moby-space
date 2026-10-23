import '../../core/formatting/formatters.dart';
import '../models/money.dart';

String formatFamilyMoney(Object? minor) =>
    formatMoney(Money((minor as num? ?? 0).toInt()));

/// Labels for the versioned server category enum; permissions remain server data.
const familyCategoryLabels = <String, String>{
  'food': 'Еда',
  'transport': 'Транспорт',
  'entertainment': 'Развлечения',
  'other': 'Другое',
};
