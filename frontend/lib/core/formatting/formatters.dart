import 'package:intl/intl.dart';

import '../../data/bank_data.dart';

String formatMoney(Money money, {bool signed = false, bool incoming = false}) {
  final amount = NumberFormat('#,##0.00', 'ru').format(money.minorUnits / 100);
  return '${signed ? (incoming ? '+' : '−') : ''}$amount ${money.currency}';
}

String formatOperationAmount(DemoOperation operation) => formatMoney(
  operation.amount,
  signed: true,
  incoming: operation.direction == OperationDirection.incoming,
);
String formatDate(DateTime date) =>
    DateFormat('d MMMM yyyy', 'ru').format(date);
String formatDateTime(DateTime date) =>
    DateFormat('d MMMM yyyy HH:mm', 'ru').format(date);

/// Current-scenario year omits year in group headings; details keep full date.
String formatHistoryDay(DateTime date, {required int scenarioYear}) =>
    DateFormat(
      date.year == scenarioYear ? 'd MMMM' : 'd MMMM yyyy',
      'ru',
    ).format(date);
