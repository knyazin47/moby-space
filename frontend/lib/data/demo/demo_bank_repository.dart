import 'dart:async';

import '../models/bank_models.dart';
import '../models/money.dart';
import '../repositories/bank_repository.dart';
import 'demo_scenario.dart';

/// An in-memory offline simulation. Never performs a financial/network call.
final class DemoBankRepository implements BankRepository {
  DemoBankRepository({DemoScenario? scenario})
    : scenario = scenario ?? createDemoScenario() {
    _snapshot = this.scenario.initialSnapshot;
  }

  final DemoScenario scenario;
  final _controller = StreamController<BankSnapshot>.broadcast();
  late BankSnapshot _snapshot;
  int _actionSequence = 0;
  bool _disposed = false;

  @override
  BankSnapshot get snapshot => _snapshot;

  @override
  Stream<BankSnapshot> get snapshots => _controller.stream;

  @override
  void reset() {
    _ensureOpen();
    _actionSequence = 0;
    _publish(scenario.initialSnapshot);
  }

  @override
  void toggleBalanceVisibility() {
    _ensureOpen();
    _publish(_snapshot.copyWith(balanceVisible: !_snapshot.balanceVisible));
  }

  @override
  TransferResult transfer({
    required String fromAccountId,
    required String recipient,
    required Money amount,
    String? note,
  }) {
    _ensureOpen();
    final account = _snapshot.accountById(fromAccountId);
    if (account == null) {
      return const TransferFailure(TransferFailureCode.accountNotFound);
    }
    if (recipient.trim().isEmpty) {
      return const TransferFailure(TransferFailureCode.recipientRequired);
    }
    final failure = _validateAmount(account, amount);
    if (failure != null) return failure;
    if (amount.minorUnits > account.balance.minorUnits) {
      return const TransferFailure(TransferFailureCode.insufficientFunds);
    }
    return _applyOperation(
      account: account,
      amount: amount,
      direction: OperationDirection.outgoing,
      category: OperationCategory.transfer,
      title: recipient.trim(),
      subtitle: 'Перевод',
      note: note?.trim(),
    );
  }

  /// Atomic local payment. It shares the ledger but never contacts an operator.
  TransferResult pay({
    String? note,
    required String description,
    required String accountId,
    required String recipient,
    required Money amount,
  }) {
    _ensureOpen();
    final account = _snapshot.accountById(accountId);
    if (account == null) {
      return const TransferFailure(TransferFailureCode.accountNotFound);
    }
    if (recipient.trim().isEmpty) {
      return const TransferFailure(TransferFailureCode.recipientRequired);
    }
    if (amount.currency != 'BYN') {
      return const TransferFailure(TransferFailureCode.currencyMismatch);
    }
    final failure = _validateAmount(account, amount);
    if (failure != null) return failure;
    if (amount.minorUnits > account.balance.minorUnits) {
      return const TransferFailure(TransferFailureCode.insufficientFunds);
    }
    return _applyOperation(
      account: account,
      amount: amount,
      direction: OperationDirection.outgoing,
      category: OperationCategory.shopping,
      title: recipient.trim(),
      subtitle: description,
      note: note,
    );
  }

  /// A local credit useful for exercising the same state flow as a transfer.
  TransferResult topUp({required String accountId, required Money amount}) {
    _ensureOpen();
    final account = _snapshot.accountById(accountId);
    if (account == null) {
      return const TransferFailure(TransferFailureCode.accountNotFound);
    }
    final failure = _validateAmount(account, amount);
    if (failure != null) return failure;
    // Avoid native signed-int overflow before constructing the next snapshot.
    if (BigInt.from(account.balance.minorUnits) +
            BigInt.from(amount.minorUnits) >
        BigInt.from(0x7fffffffffffffff)) {
      return const TransferFailure(TransferFailureCode.invalidAmount);
    }
    return _applyOperation(
      account: account,
      amount: amount,
      direction: OperationDirection.incoming,
      category: OperationCategory.topUp,
      title: 'Пополнение счёта',
      subtitle: 'Зачисление на счёт',
    );
  }

  TransferFailure? _validateAmount(DemoAccount account, Money amount) {
    if (amount.minorUnits <= 0) {
      return const TransferFailure(TransferFailureCode.invalidAmount);
    }
    if (amount.currency != account.balance.currency) {
      return const TransferFailure(TransferFailureCode.currencyMismatch);
    }
    return null;
  }

  TransferSuccess _applyOperation({
    required DemoAccount account,
    required Money amount,
    required OperationDirection direction,
    required OperationCategory category,
    required String title,
    required String subtitle,
    String? note,
  }) {
    final nextSequence = _actionSequence + 1;
    final operation = DemoOperation(
      id: 'demo-action-$nextSequence',
      accountId: account.id,
      title: title,
      subtitle: subtitle,
      amount: amount,
      direction: direction,
      category: category,
      occurredAt: scenario.actionTime.add(Duration(minutes: nextSequence - 1)),
      note: note == null || note.isEmpty ? null : note,
    );
    final newBalance = direction == OperationDirection.outgoing
        ? account.balance - amount
        : account.balance + amount;
    final nextSnapshot = _snapshot.copyWith(
      accounts: _snapshot.accounts.map(
        (item) => item.id == account.id ? item.withBalance(newBalance) : item,
      ),
      operations: [operation, ..._snapshot.operations],
    );
    _actionSequence = nextSequence;
    _publish(nextSnapshot);
    return TransferSuccess(operation);
  }

  void _publish(BankSnapshot next) {
    _snapshot = next;
    _controller.add(next);
  }

  void _ensureOpen() {
    if (_disposed) throw StateError('DemoBankRepository is disposed');
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_controller.close());
  }
}
