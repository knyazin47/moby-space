import '../models/bank_models.dart';
import '../models/money.dart';

enum TransferFailureCode {
  accountNotFound,
  recipientRequired,
  invalidAmount,
  currencyMismatch,
  insufficientFunds,
}

sealed class TransferResult {
  const TransferResult();
}

final class TransferSuccess extends TransferResult {
  const TransferSuccess(this.operation);

  final DemoOperation operation;
}

final class TransferFailure extends TransferResult {
  const TransferFailure(this.code);

  final TransferFailureCode code;
}

abstract interface class BankRepository {
  BankSnapshot get snapshot;

  /// Changes only; use [snapshot] to get the current state on subscription.
  Stream<BankSnapshot> get snapshots;

  void reset();
  void toggleBalanceVisibility();
  TransferResult transfer({
    required String fromAccountId,
    required String recipient,
    required Money amount,
    String? note,
  });
  void dispose();
}
