import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../bank_data.dart';

/// Детско-семейный банкинг: всё мок-состояние живёт в этом файле.
///
/// Структура:
/// - [FamilyPairing] — QR-связывание: фиксированный демо-токен [childPairToken],
///   статус [FamilyPairStatus] (ожидание → подтверждено родителем).
/// - [FamilyChild] — профиль ребёнка после оформления пакета:
///   имя, дата рождения, возрастная группа [ChildAgeGroup] (права по ГК РБ),
///   карта ([ChildCardType]/[ChildCardStatus]), доступ в Moby
///   [ChildAccessStatus], разрешения [ChildPermission], заблокированные
///   категории [SpendingCategory], сервисы [FamilyService], лимиты
///   [ChildLimits], карманные деньги [PocketMoney], баланс и операции.
/// - [FamilyRequest] — запрос ребёнка на доступ/продукт (ТЗ 3.2 → 3.1).
/// - [FamilyNotification] — лента уведомлений для родителя.
/// - [FamilyState] — снимок: pairing + children + requests + notifications.
/// - [FamilyStore] — Notifier: привязка, оформление пакета, доступ, права,
///   лимиты, блокировка/потеря карты, запросы, подтверждение операций,
///   демо-триггеры. Всё в памяти; состояние сбрасывается вместе с
///   [demoSessionProvider] через DemoControlsPage.
///
/// Интеграция: читать через `ref.watch(familyProvider)`, изменять через
/// `ref.read(familyProvider.notifier)`. Бэкенда и персистентности нет.

const _pairingCode = 'DEMO-CHILD-01';

/// Deep-link, который рендерится в QR на экране ребёнка. Родительский
/// сканер валидирует введённый код с этим значением.
const childPairToken = 'moby-child://pair?token=$_pairingCode';

enum FamilyPairStatus { idle, waiting, linked }

/// 7–13 — сделки совершает родитель; 14–17 — ребёнок с согласия родителя.
enum ChildAgeGroup { junior, teen }

int childAgeYears(DateTime birthDate, {DateTime? now}) {
  final today = now ?? DateTime.now();
  var years = today.year - birthDate.year;
  final birthdayThisYear = DateTime(today.year, birthDate.month, birthDate.day);
  if (today.isBefore(birthdayThisYear)) years--;
  return years;
}

/// Группа по возрасту или null, если возраст вне 7–17 лет.
ChildAgeGroup? childAgeGroup(DateTime birthDate, {DateTime? now}) =>
    switch (childAgeYears(birthDate, now: now)) {
      >= 7 && <= 13 => ChildAgeGroup.junior,
      >= 14 && <= 17 => ChildAgeGroup.teen,
      _ => null,
    };

String childAgeGroupLabel(ChildAgeGroup group) => switch (group) {
  ChildAgeGroup.junior => '7–13 лет',
  ChildAgeGroup.teen => '14–17 лет',
};

/// Тип карты ребёнка в пакете.
enum ChildCardType { physical, virtual }

String childCardTypeLabel(ChildCardType type) => switch (type) {
  ChildCardType.physical => 'Физическая карта',
  ChildCardType.virtual => 'Цифровая карта',
};

/// Жизненный цикл карты: блокировку можно снять, потеря требует перевыпуска.
enum ChildCardStatus { issuing, active, frozen, lost, reissuing }

String childCardStatusLabel(ChildCardStatus status) => switch (status) {
  ChildCardStatus.issuing => 'Выпускается',
  ChildCardStatus.active => 'Активна',
  ChildCardStatus.frozen => 'Заблокирована',
  ChildCardStatus.lost => 'Потеряна',
  ChildCardStatus.reissuing => 'Перевыпускается',
};

/// Доступ ребёнка в Moby выдаёт родитель после выпуска пакета (ТЗ 3.1).
enum ChildAccessStatus { none, granted }

/// Разрешения: какие продукты ребёнок может выпускать и какие действия
/// и операции ему доступны (ТЗ 3.1 «Настраивает ограничения»).
enum ChildPermission {
  // Продукты.
  openSavingsGoal,
  openDeposit,
  issueVirtualCard,
  // Действия и операции.
  p2pTransfers,
  qrPayments,
  onlinePayments,
  cashWithdrawal,
}

String childPermissionLabel(ChildPermission permission) => switch (permission) {
  ChildPermission.openSavingsGoal => 'Копилку',
  ChildPermission.openDeposit => 'Вклад',
  ChildPermission.issueVirtualCard => 'Цифровую карту',
  ChildPermission.p2pTransfers => 'Переводы другим людям',
  ChildPermission.qrPayments => 'Оплату по QR',
  ChildPermission.onlinePayments => 'Оплату в интернете',
  ChildPermission.cashWithdrawal => 'Снятие наличных',
};

/// Разрешения-продукты («что ребёнок может выпускать»).
const productPermissions = {
  ChildPermission.openSavingsGoal,
  ChildPermission.openDeposit,
  ChildPermission.issueVirtualCard,
};

/// Категории трат. Азартные игры и 18+ заблокированы всегда —
/// это инвариант безопасности пакета, снять запрет нельзя.
enum SpendingCategory { gambling, adult, games, fastFood, entertainment }

const alwaysBlockedCategories = {
  SpendingCategory.gambling,
  SpendingCategory.adult,
};

String spendingCategoryLabel(SpendingCategory category) => switch (category) {
  SpendingCategory.gambling => 'Азартные игры',
  SpendingCategory.adult => 'Категории 18+',
  SpendingCategory.games => 'Игры и донаты',
  SpendingCategory.fastFood => 'Фастфуд',
  SpendingCategory.entertainment => 'Развлечения',
};

/// Сервисы семейного пакета (ТЗ 4.1 «Наполнение»).
enum FamilyService { pocketMoney, savingsGoal, insurance, education }

String familyServiceLabel(FamilyService service) => switch (service) {
  FamilyService.pocketMoney => 'Карманные деньги',
  FamilyService.savingsGoal => 'Накопление на цель',
  FamilyService.insurance => 'Страхование ребёнка',
  FamilyService.education => 'Обучающая подписка',
};

enum PocketMoneyPeriod { daily, weekly, monthly }

String pocketMoneyPeriodLabel(PocketMoneyPeriod period) => switch (period) {
  PocketMoneyPeriod.daily => 'каждый день',
  PocketMoneyPeriod.weekly => 'раз в неделю',
  PocketMoneyPeriod.monthly => 'раз в месяц',
};

enum FamilyRequestStatus { pending, approved, rejected }

/// Local synthetic amount bound, in kopecks; not a bank/product tariff.
const familyMaxAmountMinor = 100000000;

enum FamilyFailureCode {
  invalidAmount,
  invalidProfile,
  invalidLimits,
  notFound,
  terminalDecision,
  inactiveCard,
  accessDenied,
  permissionDenied,
  categoryBlocked,
  insufficientFunds,
  dailyLimit,
  monthlyLimit,
  stalePolicy,
  invalidCardTransition,
}

final class FamilyDomainException implements Exception {
  const FamilyDomainException(this.code, this.message);
  final FamilyFailureCode code;
  final String message;
  @override
  String toString() => message;
}

/// The card channel has no extra permission; other channels require their grant.
enum ChildPurchaseChannel { card, online, qr, p2p, cash }

enum ChildOperationStatus { done, pendingApproval, declined }

/// Права по умолчанию по возрастной группе (ГК РБ):
/// 7–13 — только базовые действия, продукты выпускает родитель;
/// 14–17 — расширенный набор в рамках согласия родителя.
Set<ChildPermission> defaultPermissionsFor(ChildAgeGroup group) =>
    switch (group) {
      ChildAgeGroup.junior => {ChildPermission.cashWithdrawal},
      ChildAgeGroup.teen => {
        ChildPermission.onlinePayments,
        ChildPermission.qrPayments,
        ChildPermission.p2pTransfers,
        ChildPermission.cashWithdrawal,
        ChildPermission.openSavingsGoal,
      },
    };

/// Сервисы пакета по умолчанию по группе.
Set<FamilyService> defaultServicesFor(ChildAgeGroup group) => switch (group) {
  ChildAgeGroup.junior => {FamilyService.pocketMoney, FamilyService.education},
  ChildAgeGroup.teen => {
    FamilyService.pocketMoney,
    FamilyService.savingsGoal,
    FamilyService.education,
  },
};

final class FamilyPairing {
  const FamilyPairing({required this.status, this.token});

  final FamilyPairStatus status;
  final String? token;

  FamilyPairing copyWith({FamilyPairStatus? status, String? token}) =>
      FamilyPairing(status: status ?? this.status, token: token ?? this.token);
}

final class ChildLimits {
  const ChildLimits({
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.approvalThreshold,
    this.adultCategoriesBlocked = true,
  });

  final Money dailyLimit;
  final Money monthlyLimit;

  /// Операции дороже порога ждут подтверждения родителя.
  final Money approvalThreshold;

  /// Азартные игры и категории 18+ — всегда запрещены, без опции отключения.
  final bool adultCategoriesBlocked;

  ChildLimits copyWith({
    Money? dailyLimit,
    Money? monthlyLimit,
    Money? approvalThreshold,
  }) => ChildLimits(
    dailyLimit: dailyLimit ?? this.dailyLimit,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    approvalThreshold: approvalThreshold ?? this.approvalThreshold,
  );
}

/// Регулярный перевод родителя на ежедневные траты ребёнка.
final class PocketMoney {
  const PocketMoney({required this.amount, required this.period});

  final Money amount;
  final PocketMoneyPeriod period;

  PocketMoney copyWith({Money? amount, PocketMoneyPeriod? period}) =>
      PocketMoney(amount: amount ?? this.amount, period: period ?? this.period);
}

final class FamilyChild {
  const FamilyChild({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.ageGroup,
    required this.cardType,
    required this.cardStatus,
    required this.accessStatus,
    required this.permissions,
    required this.blockedCategories,
    required this.services,
    required this.limits,
    required this.balance,
    required this.operations,
    required this.createdAt,
    this.pocketMoney,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final ChildAgeGroup ageGroup;
  final ChildCardType cardType;
  final ChildCardStatus cardStatus;
  final ChildAccessStatus accessStatus;
  final Set<ChildPermission> permissions;
  final Set<SpendingCategory> blockedCategories;
  final Set<FamilyService> services;
  final ChildLimits limits;
  final Money balance;
  final List<ChildOperation> operations;
  final DateTime createdAt;
  final PocketMoney? pocketMoney;

  FamilyChild copyWith({
    ChildCardStatus? cardStatus,
    ChildAccessStatus? accessStatus,
    Set<ChildPermission>? permissions,
    Set<SpendingCategory>? blockedCategories,
    Set<FamilyService>? services,
    ChildLimits? limits,
    Money? balance,
    List<ChildOperation>? operations,
    PocketMoney? Function()? pocketMoney,
  }) => FamilyChild(
    id: id,
    name: name,
    birthDate: birthDate,
    ageGroup: ageGroup,
    cardType: cardType,
    cardStatus: cardStatus ?? this.cardStatus,
    accessStatus: accessStatus ?? this.accessStatus,
    permissions: Set.unmodifiable(permissions ?? this.permissions),
    blockedCategories: Set.unmodifiable(
      blockedCategories ?? this.blockedCategories,
    ),
    services: Set.unmodifiable(services ?? this.services),
    limits: limits ?? this.limits,
    balance: balance ?? this.balance,
    operations: List.unmodifiable(operations ?? this.operations),
    createdAt: createdAt,
    pocketMoney: pocketMoney != null ? pocketMoney() : this.pocketMoney,
  );
}

final class FamilyState {
  const FamilyState({
    this.pairing = _idlePairing,
    this.children = const [],
    this.requests = const [],
    this.notifications = const [],
  });

  static const _idlePairing = FamilyPairing(status: FamilyPairStatus.idle);

  final FamilyPairing pairing;
  final List<FamilyChild> children;
  final List<FamilyRequest> requests;
  final List<FamilyNotification> notifications;

  FamilyChild? childById(String id) {
    for (final child in children) {
      if (child.id == id) return child;
    }
    return null;
  }

  /// Ожидающие ответа запросы конкретного ребёнка.
  List<FamilyRequest> pendingRequestsFor(String childId) => [
    for (final request in requests)
      if (request.childId == childId &&
          request.status == FamilyRequestStatus.pending)
        request,
  ];

  FamilyState copyWith({
    FamilyPairing? pairing,
    List<FamilyChild>? children,
    List<FamilyRequest>? requests,
    List<FamilyNotification>? notifications,
  }) => FamilyState(
    pairing: pairing ?? this.pairing,
    children: List.unmodifiable(children ?? this.children),
    requests: List.unmodifiable(requests ?? this.requests),
    notifications: List.unmodifiable(notifications ?? this.notifications),
  );
}

/// Мок-операция детского счёта.
final class ChildOperation {
  const ChildOperation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.incoming,
    required this.occurredAt,
    this.status = ChildOperationStatus.done,
    this.category,
    this.channel = ChildPurchaseChannel.card,
    this.failureCode,
  });

  final String id;
  final String title;
  final String subtitle;
  final Money amount;
  final bool incoming;
  final DateTime occurredAt;
  final ChildOperationStatus status;
  final SpendingCategory? category;
  final ChildPurchaseChannel channel;
  final FamilyFailureCode? failureCode;

  ChildOperation copyWith({
    ChildOperationStatus? status,
    DateTime? occurredAt,
  }) => ChildOperation(
    id: id,
    title: title,
    subtitle: subtitle,
    amount: amount,
    incoming: incoming,
    occurredAt: occurredAt ?? this.occurredAt,
    status: status ?? this.status,
    category: category,
    channel: channel,
    failureCode: failureCode,
  );
}

/// Запрос ребёнка: доступ к продукту/действию (permission) или произвольный
/// (title). Одобрение по permission включает разрешение автоматически.
final class FamilyRequest {
  const FamilyRequest({
    required this.id,
    required this.childId,
    required this.title,
    required this.createdAt,
    this.permission,
    this.policyVersion = 0,
    this.status = FamilyRequestStatus.pending,
  });

  final String id;
  final String childId;
  final String title;
  final DateTime createdAt;
  final ChildPermission? permission;
  final int policyVersion;
  final FamilyRequestStatus status;

  FamilyRequest copyWith({FamilyRequestStatus? status}) => FamilyRequest(
    id: id,
    childId: childId,
    title: title,
    createdAt: createdAt,
    permission: permission,
    policyVersion: policyVersion,
    status: status ?? this.status,
  );
}

/// Уведомление для родителя: события карты, операции, запросы ребёнка.
final class FamilyNotification {
  const FamilyNotification({
    required this.id,
    required this.text,
    required this.createdAt,
    this.childId,
    this.read = false,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final String? childId;
  final bool read;

  FamilyNotification copyWith({bool? read}) => FamilyNotification(
    id: id,
    text: text,
    createdAt: createdAt,
    childId: childId,
    read: read ?? this.read,
  );
}

final class FamilyStore extends Notifier<FamilyState> {
  @override
  FamilyState build() {
    ref.watch(demoSessionProvider);
    _cancelActivations();
    _policyVersions.clear();
    ref.onDispose(_cancelActivations);
    return const FamilyState();
  }

  /// Ребёнок открыл экран с QR — ждём подтверждения родителя.
  void startPairing() {
    if (state.pairing.status == FamilyPairStatus.waiting) return;
    state = state.copyWith(
      pairing: const FamilyPairing(
        status: FamilyPairStatus.waiting,
        token: childPairToken,
      ),
    );
  }

  /// Имитация: родитель подтвердил код (скрытый триггер на экране ребёнка).
  void simulateParentConfirm() {
    state = state.copyWith(
      pairing: FamilyPairing(
        status: FamilyPairStatus.linked,
        token: state.pairing.token ?? childPairToken,
      ),
    );
  }

  /// Проверка QR/ручного ввода на стороне родителя. Принимает весь
  /// deep-link или только код. Возвращает true при успешной привязке.
  bool linkByToken(String input) {
    final value = input.trim();
    final valid =
        value == childPairToken || value.toUpperCase() == _pairingCode;
    if (!valid) return false;
    state = state.copyWith(
      pairing: const FamilyPairing(
        status: FamilyPairStatus.linked,
        token: childPairToken,
      ),
    );
    return true;
  }

  /// Оформление семейного пакета: профиль создан, карта «выпускается»
  /// и через несколько секунд переходит в активную (имитация выпуска).
  FamilyChild issuePackage({
    required String name,
    required DateTime birthDate,
    required ChildAgeGroup ageGroup,
    required ChildCardType cardType,
    required Set<ChildPermission> permissions,
    required Set<SpendingCategory> blockedCategories,
    required Set<FamilyService> services,
    required ChildLimits limits,
    PocketMoney? pocketMoney,
  }) {
    if (name.trim().isEmpty ||
        name.trim().length > 120 ||
        childAgeGroup(birthDate) != ageGroup) {
      throw const FamilyDomainException(
        FamilyFailureCode.invalidProfile,
        'Проверьте имя и возраст ребёнка',
      );
    }
    _validateLimits(limits);
    if (pocketMoney != null) _validateMoney(pocketMoney.amount);
    final child = FamilyChild(
      id: 'child-${_nextIdentity++}',
      name: name.trim(),
      birthDate: birthDate,
      ageGroup: ageGroup,
      cardType: cardType,
      cardStatus: ChildCardStatus.issuing,
      accessStatus: ChildAccessStatus.none,
      permissions: Set.unmodifiable(permissions),
      blockedCategories: Set.unmodifiable({
        ...blockedCategories,
        ...alwaysBlockedCategories,
      }),
      services: Set.unmodifiable(services),
      limits: limits,
      pocketMoney: pocketMoney,
      balance: Money(5000),
      operations: mockChildOperations(),
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      pairing: const FamilyPairing(status: FamilyPairStatus.idle),
      children: [...state.children, child],
    );
    _notify(child.id, 'Карта для ${child.name} выпускается');
    _scheduleCardActivation(child.id);
    return child;
  }

  /// Родитель подтвердил QR/код ребёнка — доступ в Moby открыт.
  void grantAccess(String childId) {
    _requireChild(childId);
    _updateChild(
      childId,
      (child) => child.copyWith(accessStatus: ChildAccessStatus.granted),
    );
    final child = state.childById(childId);
    if (child != null) _notify(childId, '${child.name} получил доступ в Moby');
  }

  void setPermission(String childId, ChildPermission permission, bool enabled) {
    _requireChild(childId);
    _policyVersions[childId] = (_policyVersions[childId] ?? 0) + 1;
    _updateChild(childId, (child) {
      final permissions = {...child.permissions};
      enabled ? permissions.add(permission) : permissions.remove(permission);
      return child.copyWith(permissions: permissions);
    });
  }

  /// Запрет азартных игр и 18+ не снимается — это инвариант пакета.
  void setCategoryBlocked(
    String childId,
    SpendingCategory category,
    bool blocked,
  ) {
    _requireChild(childId);
    if (alwaysBlockedCategories.contains(category)) {
      if (!blocked) {
        throw const FamilyDomainException(
          FamilyFailureCode.categoryBlocked,
          'Обязательный запрет нельзя снять',
        );
      }
      return;
    }
    _updateChild(childId, (child) {
      final categories = {...child.blockedCategories};
      blocked ? categories.add(category) : categories.remove(category);
      return child.copyWith(blockedCategories: categories);
    });
  }

  void updateLimits(String childId, ChildLimits limits) {
    _requireChild(childId);
    _validateLimits(limits);
    _updateChild(childId, (child) => child.copyWith(limits: limits));
  }

  void setPocketMoney(String childId, PocketMoney? pocketMoney) {
    _requireChild(childId);
    if (pocketMoney != null) _validateMoney(pocketMoney.amount);
    _updateChild(
      childId,
      (child) => child.copyWith(pocketMoney: () => pocketMoney),
    );
  }

  void toggleCardFrozen(String childId) {
    final child = _requireChild(childId);
    if (child.cardStatus == ChildCardStatus.active) {
      _updateChild(
        childId,
        (c) => c.copyWith(cardStatus: ChildCardStatus.frozen),
      );
      _notify(childId, 'Карта ${child.name} заблокирована');
    } else if (child.cardStatus == ChildCardStatus.frozen) {
      _updateChild(
        childId,
        (c) => c.copyWith(cardStatus: ChildCardStatus.active),
      );
      _notify(childId, 'Карта ${child.name} разблокирована');
    }
  }

  /// Потеря карты: мгновенная блокировка, перевыпуск бесплатный.
  void reportCardLost(String childId) {
    _requireChild(childId);
    _activationTimers.remove(childId)?.cancel();
    _updateChild(childId, (c) => c.copyWith(cardStatus: ChildCardStatus.lost));
    final child = state.childById(childId);
    if (child != null) {
      _notify(childId, 'Карта ${child.name} заблокирована (потеря)');
    }
  }

  void reissueCard(String childId) {
    if (_requireChild(childId).cardStatus != ChildCardStatus.lost) {
      throw const FamilyDomainException(
        FamilyFailureCode.invalidCardTransition,
        'Перевыпуск доступен после потери карты',
      );
    }
    _updateChild(
      childId,
      (c) => c.copyWith(cardStatus: ChildCardStatus.reissuing),
    );
    _scheduleCardActivation(childId);
  }

  /// Разовое пополнение от родителя.
  void topUp(String childId, Money amount) {
    final child = _requireChild(childId);
    _validateMoney(amount);
    _validateMoney(child.balance + amount);
    _updateChild(
      childId,
      (c) => c.copyWith(
        balance: c.balance + amount,
        operations: [
          ChildOperation(
            id: 'op-${_seq++}',
            title: 'Пополнение от родителя',
            subtitle: 'Перевод',
            amount: amount,
            incoming: true,
            occurredAt: DateTime.now(),
          ),
          ...c.operations,
        ],
      ),
    );
    _notify(childId, 'Пополнение карты ${child.name}');
  }

  /// API для детской стороны: ребёнок запрашивает доступ к продукту
  /// или действию. Одобрение по [permission] включает его автоматически.
  void addRequest({
    required String childId,
    required String title,
    ChildPermission? permission,
  }) {
    final child = _requireChild(childId);
    if (title.trim().isEmpty || title.trim().length > 200) {
      throw const FamilyDomainException(
        FamilyFailureCode.invalidProfile,
        'Введите название запроса',
      );
    }
    final request = FamilyRequest(
      id: 'req-${_seq++}',
      childId: childId,
      title: title,
      permission: permission,
      policyVersion: _policyVersions[childId] ?? 0,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(requests: [...state.requests, request]);
    _notify(childId, 'Запрос от ${child.name}: $title');
  }

  void resolveRequest(String requestId, bool approve) {
    FamilyRequest? target;
    for (final request in state.requests) {
      if (request.id == requestId) target = request;
    }
    if (target == null) {
      throw const FamilyDomainException(
        FamilyFailureCode.notFound,
        'Запрос не найден',
      );
    }
    if (target.status != FamilyRequestStatus.pending) {
      throw const FamilyDomainException(
        FamilyFailureCode.terminalDecision,
        'Запрос уже рассмотрен',
      );
    }
    _requireChild(target.childId);
    if (approve &&
        target.permission != null &&
        target.policyVersion != (_policyVersions[target.childId] ?? 0)) {
      throw const FamilyDomainException(
        FamilyFailureCode.stalePolicy,
        'Права изменились. Нужен новый запрос',
      );
    }
    final grantedPermission = approve ? target.permission : null;
    if (grantedPermission != null) {
      _policyVersions[target.childId] =
          (_policyVersions[target.childId] ?? 0) + 1;
    }
    state = state.copyWith(
      children: grantedPermission == null
          ? state.children
          : [
              for (final child in state.children)
                child.id == target.childId
                    ? child.copyWith(
                        permissions: {...child.permissions, grantedPermission},
                      )
                    : child,
            ],
      requests: [
        for (final request in state.requests)
          request.id == requestId
              ? request.copyWith(
                  status: approve
                      ? FamilyRequestStatus.approved
                      : FamilyRequestStatus.rejected,
                )
              : request,
      ],
    );
    final child = state.childById(target.childId);
    if (child != null) {
      _notify(
        target.childId,
        approve
            ? 'Запрос «${target.title}» одобрен'
            : 'Запрос «${target.title}» отклонён',
      );
    }
  }

  /// Подтверждение операции выше порога: при одобрении списываем баланс.
  void resolveOperation(String childId, String operationId, bool approve) {
    final child = _requireChild(childId);
    ChildOperation? target;
    for (final op in child.operations) {
      if (op.id == operationId) target = op;
    }
    if (target == null) {
      throw const FamilyDomainException(
        FamilyFailureCode.notFound,
        'Операция не найдена',
      );
    }
    if (target.incoming ||
        target.status != ChildOperationStatus.pendingApproval) {
      throw const FamilyDomainException(
        FamilyFailureCode.terminalDecision,
        'Операция не ожидает подтверждения',
      );
    }
    if (approve) {
      _validateMoney(target.amount);
      final failure = _purchaseFailure(
        child,
        target.amount,
        target.category,
        target.channel,
      );
      if (failure != null) {
        throw FamilyDomainException(failure, familyFailureMessage(failure));
      }
    }
    _updateChild(childId, (c) {
      final operations = [
        for (final op in c.operations)
          op.id == operationId
              ? op.copyWith(
                  occurredAt: approve ? DateTime.now() : op.occurredAt,
                  status: approve
                      ? ChildOperationStatus.done
                      : ChildOperationStatus.declined,
                )
              : op,
      ];
      return c.copyWith(
        operations: operations,
        balance: approve ? c.balance - target!.amount : c.balance,
      );
    });
    _notify(
      childId,
      approve
          ? 'Операция «${target.title}» подтверждена'
          : 'Операция «${target.title}» отклонена',
    );
  }

  // --- Демо-триггеры: имитация активности ребёнка, пока детская
  // ветка не влита. Используются демо-панелью в кабинете ребёнка. ---

  /// Покупка ребёнка: запрещённая категия → declined, сумма выше порога
  /// → ждёт подтверждения, иначе обычное списание.
  ChildOperation simulateChildPurchase(
    String childId,
    int amountMinor, {
    String title = 'Покупка',
    SpendingCategory? category,
    ChildPurchaseChannel channel = ChildPurchaseChannel.card,
  }) {
    final child = _requireChild(childId);
    final amount = Money(amountMinor);
    _validateMoney(amount);
    if (title.trim().isEmpty || title.trim().length > 200) {
      throw const FamilyDomainException(
        FamilyFailureCode.invalidProfile,
        'Введите название операции',
      );
    }
    final failure = _purchaseFailure(child, amount, category, channel);
    final status = failure != null
        ? ChildOperationStatus.declined
        : amount.minorUnits > child.limits.approvalThreshold.minorUnits
        ? ChildOperationStatus.pendingApproval
        : ChildOperationStatus.done;
    final operation = ChildOperation(
      id: 'op-${_seq++}',
      title: title.trim(),
      subtitle: category != null ? spendingCategoryLabel(category) : 'Покупки',
      amount: amount,
      incoming: false,
      occurredAt: DateTime.now(),
      status: status,
      category: category,
      channel: channel,
      failureCode: failure,
    );
    _updateChild(
      childId,
      (c) => c.copyWith(
        operations: [operation, ...c.operations],
        balance: status == ChildOperationStatus.done
            ? c.balance - amount
            : c.balance,
      ),
    );
    _notify(childId, switch (status) {
      ChildOperationStatus.declined =>
        'Покупка ${child.name} отклонена: ${familyFailureMessage(failure!)}',
      ChildOperationStatus.pendingApproval =>
        '${child.name}: покупка ждёт подтверждения',
      ChildOperationStatus.done => 'Списание у ${child.name}: $title',
    });
    return operation;
  }

  /// Имитация запроса ребёнка «Оплата в интернете».
  void simulateChildRequest(String childId) => addRequest(
    childId: childId,
    title: childPermissionLabel(ChildPermission.onlinePayments),
    permission: ChildPermission.onlinePayments,
  );

  void markNotificationsRead() {
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications) n.copyWith(read: true),
      ],
    );
  }

  static int _seq = 0;

  void _notify(String childId, String text) {
    final notification = FamilyNotification(
      id: 'ntf-${_seq++}',
      childId: childId,
      text: text,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }

  static int _nextIdentity = 1;
  final _activationTimers = <String, Timer>{};
  final _policyVersions = <String, int>{};
  int _generation = 0;

  void _cancelActivations() {
    _generation++;
    for (final timer in _activationTimers.values) {
      timer.cancel();
    }
    _activationTimers.clear();
  }

  void _scheduleCardActivation(String childId) {
    _activationTimers.remove(childId)?.cancel();
    final generation = _generation;
    _activationTimers[childId] = Timer(const Duration(seconds: 4), () {
      if (!ref.mounted || generation != _generation) return;
      _activationTimers.remove(childId);
      final child = state.childById(childId);
      if (child == null) return;
      if (child.cardStatus == ChildCardStatus.issuing ||
          child.cardStatus == ChildCardStatus.reissuing) {
        _updateChild(
          childId,
          (c) => c.copyWith(cardStatus: ChildCardStatus.active),
        );
        _notify(childId, 'Карта ${child.name} активна');
      }
    });
  }

  FamilyChild _requireChild(String childId) =>
      state.childById(childId) ??
      (throw const FamilyDomainException(
        FamilyFailureCode.notFound,
        'Ребёнок не найден',
      ));

  void _validateMoney(Money money, {bool allowZero = false}) {
    if (money.currency != 'BYN' ||
        money.minorUnits < (allowZero ? 0 : 1) ||
        money.minorUnits > familyMaxAmountMinor) {
      throw const FamilyDomainException(
        FamilyFailureCode.invalidAmount,
        'Введите положительную сумму в BYN в пределах демо-лимита',
      );
    }
  }

  void _validateLimits(ChildLimits limits) {
    _validateMoney(limits.dailyLimit, allowZero: true);
    _validateMoney(limits.monthlyLimit, allowZero: true);
    _validateMoney(limits.approvalThreshold, allowZero: true);
    if (!limits.adultCategoriesBlocked) {
      throw const FamilyDomainException(
        FamilyFailureCode.invalidLimits,
        'Обязательные категории должны быть заблокированы',
      );
    }
  }

  FamilyFailureCode? _purchaseFailure(
    FamilyChild child,
    Money amount,
    SpendingCategory? category,
    ChildPurchaseChannel channel,
  ) {
    if (child.cardStatus != ChildCardStatus.active) {
      return FamilyFailureCode.inactiveCard;
    }
    if (child.accessStatus != ChildAccessStatus.granted) {
      return FamilyFailureCode.accessDenied;
    }
    final permission = switch (channel) {
      ChildPurchaseChannel.card => null,
      ChildPurchaseChannel.online => ChildPermission.onlinePayments,
      ChildPurchaseChannel.qr => ChildPermission.qrPayments,
      ChildPurchaseChannel.p2p => ChildPermission.p2pTransfers,
      ChildPurchaseChannel.cash => ChildPermission.cashWithdrawal,
    };
    if (permission != null && !child.permissions.contains(permission)) {
      return FamilyFailureCode.permissionDenied;
    }
    if (category != null &&
        (alwaysBlockedCategories.contains(category) ||
            child.blockedCategories.contains(category))) {
      return FamilyFailureCode.categoryBlocked;
    }
    if (amount.minorUnits > child.balance.minorUnits) {
      return FamilyFailureCode.insufficientFunds;
    }
    final now = DateTime.now();
    var daily = 0;
    var monthly = 0;
    for (final operation in child.operations) {
      if (operation.incoming || operation.status != ChildOperationStatus.done) {
        continue;
      }
      final date = operation.occurredAt;
      if (date.year == now.year && date.month == now.month) {
        monthly += operation.amount.minorUnits;
        if (date.day == now.day) daily += operation.amount.minorUnits;
      }
    }
    if (daily + amount.minorUnits > child.limits.dailyLimit.minorUnits) {
      return FamilyFailureCode.dailyLimit;
    }
    if (monthly + amount.minorUnits > child.limits.monthlyLimit.minorUnits) {
      return FamilyFailureCode.monthlyLimit;
    }
    return null;
  }

  void _updateChild(String childId, FamilyChild Function(FamilyChild) update) {
    _requireChild(childId);
    state = state.copyWith(
      children: [
        for (final child in state.children)
          child.id == childId ? update(child) : child,
      ],
    );
  }
}

final familyProvider = NotifierProvider<FamilyStore, FamilyState>(
  FamilyStore.new,
);

/// Стартовые мок-операции детского счёта — seed при создании профиля.
List<ChildOperation> mockChildOperations() {
  final now = DateTime.now();
  return List.unmodifiable([
    ChildOperation(
      id: 'seed-1',
      title: 'Магазин «Лист»',
      subtitle: 'Покупки',
      amount: Money(2790),
      incoming: false,
      occurredAt: DateTime(now.year, now.month, now.day, 14, 20),
    ),
    ChildOperation(
      id: 'seed-2',
      title: 'Столовая № 5',
      subtitle: 'Питание',
      amount: Money(740),
      incoming: false,
      occurredAt: DateTime(now.year, now.month, now.day, 12, 5),
    ),
    ChildOperation(
      id: 'seed-3',
      title: 'Пополнение от родителя',
      subtitle: 'Перевод',
      amount: Money(5000),
      incoming: true,
      occurredAt: DateTime(now.year, now.month, now.day - 1, 9, 0),
    ),
  ]);
}

String familyFailureMessage(FamilyFailureCode code) => switch (code) {
  FamilyFailureCode.inactiveCard => 'карта не активна',
  FamilyFailureCode.accessDenied => 'доступ ребёнка не предоставлен',
  FamilyFailureCode.permissionDenied => 'действие не разрешено',
  FamilyFailureCode.categoryBlocked => 'категория запрещена',
  FamilyFailureCode.insufficientFunds => 'недостаточно средств',
  FamilyFailureCode.dailyLimit => 'превышен дневной лимит',
  FamilyFailureCode.monthlyLimit => 'превышен месячный лимит',
  _ => 'действие недоступно',
};
