import 'money.dart';

final class DemoProfile {
  const DemoProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';
}

final class DemoAccount {
  const DemoAccount({
    required this.id,
    required this.title,
    required this.maskedNumber,
    required this.balance,
  });

  final String id;
  final String title;
  final String maskedNumber;
  final Money balance;

  DemoAccount withBalance(Money value) {
    if (value.currency != balance.currency || value.minorUnits < 0) {
      throw ArgumentError.value(value, 'value', 'Invalid account balance');
    }
    return DemoAccount(
      id: id,
      title: title,
      maskedNumber: maskedNumber,
      balance: value,
    );
  }
}

enum DemoCardStatus { active, frozen }

final class DemoCard {
  const DemoCard({
    required this.id,
    required this.accountId,
    required this.title,
    required this.paymentSystem,
    required this.lastFour,
    required this.holderName,
    required this.expiresAt,
    this.status = DemoCardStatus.active,
    this.artAssetPath,
  });

  final String id;
  final String accountId;
  final String title;
  final String paymentSystem;
  final String lastFour;
  final String holderName;
  final DateTime expiresAt;
  final DemoCardStatus status;

  /// Reviewed public artwork; personal card fields remain separate synthetic data.
  final String? artAssetPath;

  String get maskedNumber => '•••• $lastFour';
}

enum OperationDirection { incoming, outgoing }

enum OperationCategory {
  groceries,
  transport,
  shopping,
  income,
  transfer,
  topUp,
}

enum OperationStatus { completed, pending, declined }

final class DemoOperation {
  const DemoOperation({
    required this.id,
    required this.accountId,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.direction,
    required this.category,
    required this.occurredAt,
    this.note,
    this.typeLabel,
    this.status = OperationStatus.completed,
    this.sourceAmount,
    this.mcc,
  });

  final String id;
  final String accountId;
  final String title;
  final String subtitle;

  /// Positive magnitude. [direction] determines whether funds came or went.
  final Money amount;
  final OperationDirection direction;
  final OperationCategory category;
  final DateTime occurredAt;
  final String? note;

  /// Presentation from a synthetic fixture, never imported bank account details.
  final String? typeLabel;
  final OperationStatus status;
  final Money? sourceAmount;
  final int? mcc;
}

/// One immutable view, shared by the home, card details and history screens.
final class BankSnapshot {
  BankSnapshot({
    required this.profile,
    required Iterable<DemoAccount> accounts,
    required Iterable<DemoCard> cards,
    required Iterable<DemoOperation> operations,
    this.balanceVisible = true,
  }) : accounts = List.unmodifiable(accounts),
       cards = List.unmodifiable(cards),
       operations = List.unmodifiable(operations) {
    if (this.accounts.isEmpty) {
      throw ArgumentError('A bank snapshot needs at least one account');
    }
  }

  final DemoProfile profile;
  final List<DemoAccount> accounts;
  final List<DemoCard> cards;
  final List<DemoOperation> operations;
  final bool balanceVisible;

  DemoAccount get primaryAccount => accounts.first;

  DemoAccount? accountById(String id) {
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  BankSnapshot copyWith({
    Iterable<DemoAccount>? accounts,
    Iterable<DemoOperation>? operations,
    bool? balanceVisible,
  }) => BankSnapshot(
    profile: profile,
    accounts: accounts ?? this.accounts,
    cards: cards,
    operations: operations ?? this.operations,
    balanceVisible: balanceVisible ?? this.balanceVisible,
  );
}
