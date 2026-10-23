import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/data/bank_data.dart';

void main() {
  late DemoBankRepository repository;

  setUp(() => repository = DemoBankRepository());
  tearDown(() => repository.dispose());

  test(
    'payment rejects mismatched currency and insufficient funds before one atomic debit',
    () async {
      final before = repository.snapshot;
      final changes = <BankSnapshot>[];
      final subscription = repository.snapshots.listen(changes.add);
      addTearDown(subscription.cancel);
      for (final amount in [
        Money(100, currency: 'USD'),
        Money(0),
        Money(before.primaryAccount.balance.minorUnits + 1),
      ]) {
        expect(
          repository.pay(
            description: 'Оплата',
            accountId: primaryAccountId,
            recipient: 'Получатель',
            amount: amount,
          ),
          isA<TransferFailure>(),
        );
        expect(repository.snapshot, same(before));
      }
      expect(
        repository.pay(
          description: 'Оплата',
          accountId: 'account-usd',
          recipient: 'Получатель',
          amount: Money(100, currency: 'USD'),
        ),
        isA<TransferFailure>(),
      );
      expect(repository.snapshot, same(before));
      final result = repository.pay(
        description: 'Оплата',
        accountId: primaryAccountId,
        recipient: 'Получатель',
        amount: Money(100),
        note: 'Назначение',
      );
      await Future<void>.delayed(Duration.zero);
      expect(result, isA<TransferSuccess>());
      expect(changes, hasLength(1));
      expect(
        repository.snapshot.primaryAccount.balance.minorUnits,
        before.primaryAccount.balance.minorUnits - 100,
      );
      expect(repository.snapshot.operations.first.note, 'Назначение');
    },
  );

  test(
    'a transfer publishes the debit and operation together exactly once',
    () async {
      final before = repository.snapshot;
      final changes = <BankSnapshot>[];
      final subscription = repository.snapshots.listen(changes.add);
      addTearDown(subscription.cancel);

      final result = repository.transfer(
        fromAccountId: primaryAccountId,
        recipient: '  Демо-получатель  ',
        amount: Money(12345),
        note: '  Тестовый перевод  ',
      );
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<TransferSuccess>());
      final operation = (result as TransferSuccess).operation;
      final after = repository.snapshot;
      expect(changes, hasLength(1));
      expect(changes.single, same(after));
      expect(
        after.primaryAccount.balance,
        before.primaryAccount.balance - Money(12345),
      );
      expect(after.accounts[1], same(before.accounts[1]));
      expect(after.cards, orderedEquals(before.cards));
      expect(after.operations, hasLength(before.operations.length + 1));
      expect(after.operations.first, same(operation));
      expect(operation.title, 'Демо-получатель');
      expect(operation.note, 'Тестовый перевод');
      expect(operation.accountId, primaryAccountId);
      expect(operation.amount, Money(12345));
      expect(operation.direction, OperationDirection.outgoing);
      expect(operation.occurredAt, repository.scenario.actionTime);
      // A previously rendered snapshot is not mutated by a later action.
      expect(before.primaryAccount.balance, Money(248631));
      expect(before.operations, hasLength(4));
    },
  );

  test(
    'rejected actions leave all state and the event stream untouched',
    () async {
      final before = repository.snapshot;
      final changes = <BankSnapshot>[];
      final subscription = repository.snapshots.listen(changes.add);
      addTearDown(subscription.cancel);

      void reject({
        String accountId = primaryAccountId,
        String recipient = 'Демо-получатель',
        required Money amount,
        required TransferFailureCode code,
      }) {
        final result = repository.transfer(
          fromAccountId: accountId,
          recipient: recipient,
          amount: amount,
        );
        expect(result, isA<TransferFailure>());
        expect((result as TransferFailure).code, code);
        expect(repository.snapshot, same(before));
      }

      reject(amount: Money(0), code: TransferFailureCode.invalidAmount);
      reject(amount: Money(-1), code: TransferFailureCode.invalidAmount);
      reject(
        amount: Money(248632),
        code: TransferFailureCode.insufficientFunds,
      );
      reject(
        amount: Money(1, currency: 'USD'),
        code: TransferFailureCode.currencyMismatch,
      );
      reject(
        amount: Money(1),
        recipient: '   ',
        code: TransferFailureCode.recipientRequired,
      );
      reject(
        accountId: 'missing',
        amount: Money(1),
        code: TransferFailureCode.accountNotFound,
      );
      await Future<void>.delayed(Duration.zero);
      expect(changes, isEmpty);
      final successful =
          repository.transfer(
                fromAccountId: primaryAccountId,
                recipient: 'Демо-получатель',
                amount: Money(1),
              )
              as TransferSuccess;
      expect(successful.operation.id, 'demo-action-1');
      expect(successful.operation.occurredAt, repository.scenario.actionTime);
    },
  );

  test(
    'an exact-balance transfer leaves zero and the next debit is rejected',
    () {
      final fullBalance = repository.snapshot.primaryAccount.balance;
      final result = repository.transfer(
        fromAccountId: primaryAccountId,
        recipient: 'Демо-получатель',
        amount: fullBalance,
      );
      expect(result, isA<TransferSuccess>());
      expect(repository.snapshot.primaryAccount.balance, Money(0));
      final after = repository.snapshot;
      final rejected =
          repository.transfer(
                fromAccountId: primaryAccountId,
                recipient: 'Демо-получатель',
                amount: Money(1),
              )
              as TransferFailure;
      expect(rejected.code, TransferFailureCode.insufficientFunds);
      expect(repository.snapshot, same(after));
    },
  );

  test(
    'top up credits only the target account and records incoming history',
    () {
      final before = repository.snapshot;
      final result =
          repository.topUp(
                accountId: 'account-usd',
                amount: Money(1575, currency: 'USD'),
              )
              as TransferSuccess;
      expect(repository.snapshot.primaryAccount, same(before.primaryAccount));
      expect(
        repository.snapshot.accountById('account-usd')!.balance,
        Money(33115, currency: 'USD'),
      );
      expect(result.operation.direction, OperationDirection.incoming);
      expect(result.operation.category, OperationCategory.topUp);
      expect(repository.snapshot.operations.first, same(result.operation));
    },
  );

  test(
    'top up rejects invalid values and native integer overflow atomically',
    () {
      final before = repository.snapshot;
      for (final amount in [Money(0), Money(-1), Money(0x7fffffffffffffff)]) {
        final result =
            repository.topUp(accountId: primaryAccountId, amount: amount)
                as TransferFailure;
        expect(result.code, TransferFailureCode.invalidAmount);
        expect(repository.snapshot, same(before));
      }
      final wrongCurrency =
          repository.topUp(
                accountId: primaryAccountId,
                amount: Money(1, currency: 'USD'),
              )
              as TransferFailure;
      expect(wrongCurrency.code, TransferFailureCode.currencyMismatch);
      expect(repository.snapshot, same(before));
    },
  );

  test(
    'reset restores fixtures, privacy state and deterministic action sequence',
    () {
      final initial = repository.snapshot;
      TransferSuccess transfer() =>
          repository.transfer(
                fromAccountId: primaryAccountId,
                recipient: 'Демо-получатель',
                amount: Money(103),
              )
              as TransferSuccess;

      final first = transfer().operation;
      final second = transfer().operation;
      expect(second.id, isNot(first.id));
      expect(
        second.occurredAt.difference(first.occurredAt),
        const Duration(minutes: 1),
      );
      repository.toggleBalanceVisibility();
      expect(repository.snapshot.balanceVisible, isFalse);
      repository.reset();
      expect(repository.snapshot, same(initial));
      expect(repository.snapshot.balanceVisible, isTrue);
      final repeated = transfer().operation;
      expect(repeated.id, first.id);
      expect(repeated.occurredAt, first.occurredAt);
      expect(repeated.amount, first.amount);
    },
  );

  test('snapshot and scenario collections cannot be mutated by consumers', () {
    expect(() => repository.snapshot.accounts.clear(), throwsUnsupportedError);
    expect(() => repository.snapshot.cards.clear(), throwsUnsupportedError);
    expect(
      () => repository.snapshot.operations.clear(),
      throwsUnsupportedError,
    );
    expect(
      () => repository.scenario.homeBanners.clear(),
      throwsUnsupportedError,
    );
    expect(() => repository.scenario.products.clear(), throwsUnsupportedError);
    expect(
      () => repository.scenario.applyProducts.clear(),
      throwsUnsupportedError,
    );
    expect(() => repository.scenario.moreItems.clear(), throwsUnsupportedError);
  });

  test(
    'all fixture cards and operations reference a matching-currency account',
    () {
      final state = repository.snapshot;
      for (final card in state.cards) {
        expect(state.accountById(card.accountId), isNotNull);
        expect(RegExp(r'^\d{4}$').hasMatch(card.lastFour), isTrue);
      }
      for (final operation in state.operations) {
        final account = state.accountById(operation.accountId);
        expect(account, isNotNull);
        expect(operation.amount.currency, account!.balance.currency);
        expect(operation.amount.minorUnits, greaterThan(0));
      }
      expect(state.profile.fullName, 'Иван Демин');
      expect(
        state.accounts.map((account) => account.id).toSet(),
        hasLength(state.accounts.length),
      );
      expect(
        state.operations.map((operation) => operation.id).toSet(),
        hasLength(state.operations.length),
      );
    },
  );

  test('dispose closes updates and refuses new mutations', () async {
    final closed = expectLater(repository.snapshots, emitsDone);
    repository.dispose();
    repository.dispose();
    await closed;
    expect(repository.reset, throwsStateError);
    expect(repository.toggleBalanceVisibility, throwsStateError);
    expect(
      () => repository.transfer(
        fromAccountId: primaryAccountId,
        recipient: 'Демо-получатель',
        amount: Money(1),
      ),
      throwsStateError,
    );
  });

  test('money arithmetic stays exact and rejects mixed currencies', () {
    expect(Money(10) + Money(20), Money(30));
    expect(Money(100) - Money(99), Money(1));
    expect(() => Money(1) + Money(1, currency: 'USD'), throwsArgumentError);
    expect(() => Money(1, currency: 'byn'), throwsArgumentError);
  });
}
