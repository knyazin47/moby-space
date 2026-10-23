import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moby_demo/app/providers.dart';
import 'package:moby_demo/data/bank_data.dart';
import 'package:moby_demo/data/family/family_store.dart';

void main() {
  late ProviderContainer container;
  late FamilyStore store;
  setUp(() {
    container = ProviderContainer();
    store = container.read(familyProvider.notifier);
  });
  tearDown(() => container.dispose());
  FamilyChild issue({ChildLimits? limits}) => store.issuePackage(
    name: 'Синтетический ребёнок',
    birthDate: DateTime(DateTime.now().year - 10, 1, 1),
    ageGroup: ChildAgeGroup.junior,
    cardType: ChildCardType.physical,
    permissions: ChildPermission.values.toSet(),
    blockedCategories: {},
    services: {},
    limits:
        limits ??
        ChildLimits(
          dailyLimit: Money(10000),
          monthlyLimit: Money(40000),
          approvalThreshold: Money(1000),
        ),
  );
  FamilyChild current(String id) =>
      container.read(familyProvider).childById(id)!;
  Future<FamilyChild> ready(WidgetTester tester, {ChildLimits? limits}) async {
    final child = issue(limits: limits);
    store.grantAccess(child.id);
    await tester.pump(const Duration(seconds: 4));
    return current(child.id);
  }

  testWidgets(
    'negative purchase and top-up cannot change the family snapshot',
    (tester) async {
      final child = await ready(tester);
      final before = container.read(familyProvider);
      expect(
        () => store.simulateChildPurchase(child.id, -100),
        throwsException,
      );
      expect(() => store.topUp(child.id, Money(-100)), throwsException);
      expect(container.read(familyProvider), same(before));
    },
  );
  testWidgets('approval is pending outgoing only and debits exactly once', (
    tester,
  ) async {
    final child = await ready(tester);
    store.simulateChildPurchase(child.id, 1500);
    final pending = current(child.id).operations.first;
    store.resolveOperation(child.id, pending.id, true);
    final after = container.read(familyProvider);
    expect(current(child.id).balance, Money(3500));
    expect(
      () => store.resolveOperation(child.id, pending.id, true),
      throwsException,
    );
    expect(
      () => store.resolveOperation(child.id, pending.id, false),
      throwsException,
    );
    expect(container.read(familyProvider), same(after));
    store.topUp(child.id, Money(100));
    final incoming = current(child.id).operations.first;
    final beforeIncoming = container.read(familyProvider);
    expect(
      () => store.resolveOperation(child.id, incoming.id, true),
      throwsException,
    );
    expect(container.read(familyProvider), same(beforeIncoming));
  });
  testWidgets('blocked-category decline cannot later be approved', (
    tester,
  ) async {
    final child = await ready(tester);
    store.simulateChildPurchase(
      child.id,
      100,
      category: SpendingCategory.gambling,
    );
    final declined = current(child.id).operations.first;
    expect(declined.status, ChildOperationStatus.declined);
    final before = container.read(familyProvider);
    expect(
      () => store.resolveOperation(child.id, declined.id, true),
      throwsException,
    );
    expect(container.read(familyProvider), same(before));
  });
  testWidgets(
    'terminal permission request cannot restore a revoked permission',
    (tester) async {
      final child = await ready(tester);
      store.setPermission(child.id, ChildPermission.onlinePayments, false);
      store.simulateChildRequest(child.id);
      final request = container.read(familyProvider).requests.single;
      store.resolveRequest(request.id, true);
      store.setPermission(child.id, ChildPermission.onlinePayments, false);
      final before = container.read(familyProvider);
      expect(() => store.resolveRequest(request.id, true), throwsException);
      expect(container.read(familyProvider), same(before));
      expect(
        current(child.id).permissions,
        isNot(contains(ChildPermission.onlinePayments)),
      );
    },
  );
  testWidgets(
    'reset gives a new identity and cancels the old activation deadline',
    (tester) async {
      final first = issue();
      await tester.pump(const Duration(seconds: 2));
      container.read(demoSessionProvider.notifier).restart();
      container.read(familyProvider);
      final second = issue();
      expect(second.id, isNot(first.id));
      await tester.pump(const Duration(seconds: 2));
      expect(current(second.id).cardStatus, ChildCardStatus.issuing);
      await tester.pump(const Duration(seconds: 2));
      expect(current(second.id).cardStatus, ChildCardStatus.active);
    },
  );
  Matcher failsWith(FamilyFailureCode code) => throwsA(
    isA<FamilyDomainException>().having((error) => error.code, 'code', code),
  );

  testWidgets(
    'amount commands reject zero, excessive values and wrong currency atomically',
    (tester) async {
      final child = await ready(tester);
      for (final amount in [
        Money(0),
        Money(-1),
        Money(familyMaxAmountMinor + 1),
        Money(100, currency: 'USD'),
      ]) {
        final before = container.read(familyProvider);
        expect(
          () => store.topUp(child.id, amount),
          failsWith(FamilyFailureCode.invalidAmount),
        );
        expect(container.read(familyProvider), same(before));
      }
      for (final amount in [0, -1, familyMaxAmountMinor + 1]) {
        final before = container.read(familyProvider);
        expect(
          () => store.simulateChildPurchase(child.id, amount),
          failsWith(FamilyFailureCode.invalidAmount),
        );
        expect(container.read(familyProvider), same(before));
      }
      store.topUp(
        child.id,
        Money(familyMaxAmountMinor - child.balance.minorUnits),
      );
      final full = container.read(familyProvider);
      expect(
        () => store.topUp(child.id, Money(1)),
        failsWith(FamilyFailureCode.invalidAmount),
      );
      expect(container.read(familyProvider), same(full));
    },
  );

  testWidgets(
    'issuing, no-access, frozen, lost and reissuing cards cannot spend',
    (tester) async {
      final child = issue();
      expect(
        store.simulateChildPurchase(child.id, 100).failureCode,
        FamilyFailureCode.inactiveCard,
      );
      await tester.pump(const Duration(seconds: 4));
      expect(
        store.simulateChildPurchase(child.id, 100).failureCode,
        FamilyFailureCode.accessDenied,
      );
      store.grantAccess(child.id);
      store.toggleCardFrozen(child.id);
      expect(
        store.simulateChildPurchase(child.id, 100).failureCode,
        FamilyFailureCode.inactiveCard,
      );
      store.toggleCardFrozen(child.id);
      store.reportCardLost(child.id);
      expect(
        store.simulateChildPurchase(child.id, 100).failureCode,
        FamilyFailureCode.inactiveCard,
      );
      store.toggleCardFrozen(child.id);
      expect(current(child.id).cardStatus, ChildCardStatus.lost);
      store.reissueCard(child.id);
      expect(
        store.simulateChildPurchase(child.id, 100).failureCode,
        FamilyFailureCode.inactiveCard,
      );
      await tester.pump(const Duration(seconds: 4));
      expect(
        store.simulateChildPurchase(child.id, 100).status,
        ChildOperationStatus.done,
      );
      expect(current(child.id).balance, Money(4900));
    },
  );

  testWidgets(
    'each channel checks its permission and rechecks it at approval',
    (tester) async {
      final child = await ready(tester);
      final channels = {
        ChildPurchaseChannel.online: ChildPermission.onlinePayments,
        ChildPurchaseChannel.qr: ChildPermission.qrPayments,
        ChildPurchaseChannel.p2p: ChildPermission.p2pTransfers,
        ChildPurchaseChannel.cash: ChildPermission.cashWithdrawal,
      };
      for (final entry in channels.entries) {
        store.setPermission(child.id, entry.value, false);
        expect(
          store
              .simulateChildPurchase(child.id, 100, channel: entry.key)
              .failureCode,
          FamilyFailureCode.permissionDenied,
        );
        store.setPermission(child.id, entry.value, true);
        final pending = store.simulateChildPurchase(
          child.id,
          1100,
          channel: entry.key,
        );
        expect(pending.status, ChildOperationStatus.pendingApproval);
        store.setPermission(child.id, entry.value, false);
        final before = container.read(familyProvider);
        expect(
          () => store.resolveOperation(child.id, pending.id, true),
          failsWith(FamilyFailureCode.permissionDenied),
        );
        expect(container.read(familyProvider), same(before));
        store.resolveOperation(child.id, pending.id, false);
      }
      expect(current(child.id).balance, child.balance);
    },
  );

  testWidgets('funds are rechecked across competing pending approvals', (
    tester,
  ) async {
    final child = await ready(tester);
    final first = store.simulateChildPurchase(child.id, 3000);
    final second = store.simulateChildPurchase(child.id, 3000);
    expect(first.status, ChildOperationStatus.pendingApproval);
    expect(second.status, ChildOperationStatus.pendingApproval);
    store.resolveOperation(child.id, first.id, true);
    final before = container.read(familyProvider);
    expect(
      () => store.resolveOperation(child.id, second.id, true),
      failsWith(FamilyFailureCode.insufficientFunds),
    );
    expect(container.read(familyProvider), same(before));
    expect(current(child.id).balance, Money(2000));
    expect(
      store.simulateChildPurchase(child.id, 2001).failureCode,
      FamilyFailureCode.insufficientFunds,
    );
  });

  testWidgets(
    'daily and monthly limits include completed debits and revalidate pending operations',
    (tester) async {
      final child = await ready(tester);
      final pending = store.simulateChildPurchase(child.id, 1500);
      // Initial completed outgoing history is 35.30 BYN. Pending/declined/incoming are not spent.
      store.updateLimits(
        child.id,
        ChildLimits(
          dailyLimit: Money(4000),
          monthlyLimit: Money(40000),
          approvalThreshold: Money(1000),
        ),
      );
      expect(
        store.simulateChildPurchase(child.id, 471).failureCode,
        FamilyFailureCode.dailyLimit,
      );
      var before = container.read(familyProvider);
      expect(
        () => store.resolveOperation(child.id, pending.id, true),
        failsWith(FamilyFailureCode.dailyLimit),
      );
      expect(container.read(familyProvider), same(before));
      store.updateLimits(
        child.id,
        ChildLimits(
          dailyLimit: Money(10000),
          monthlyLimit: Money(4000),
          approvalThreshold: Money(1000),
        ),
      );
      expect(
        store.simulateChildPurchase(child.id, 471).failureCode,
        FamilyFailureCode.monthlyLimit,
      );
      before = container.read(familyProvider);
      expect(
        () => store.resolveOperation(child.id, pending.id, true),
        failsWith(FamilyFailureCode.monthlyLimit),
      );
      expect(container.read(familyProvider), same(before));
      expect(
        store.simulateChildPurchase(child.id, 470).status,
        ChildOperationStatus.done,
      );
      expect(
        store.simulateChildPurchase(child.id, 1).failureCode,
        FamilyFailureCode.monthlyLimit,
      );
    },
  );

  testWidgets(
    'approval rechecks frozen/lost card and newly blocked category without mutation',
    (tester) async {
      final child = await ready(tester);
      final pending = store.simulateChildPurchase(
        child.id,
        1500,
        category: SpendingCategory.games,
      );
      store.toggleCardFrozen(child.id);
      var before = container.read(familyProvider);
      expect(
        () => store.resolveOperation(child.id, pending.id, true),
        failsWith(FamilyFailureCode.inactiveCard),
      );
      expect(container.read(familyProvider), same(before));
      store.toggleCardFrozen(child.id);
      store.setCategoryBlocked(child.id, SpendingCategory.games, true);
      before = container.read(familyProvider);
      expect(
        () => store.resolveOperation(child.id, pending.id, true),
        failsWith(FamilyFailureCode.categoryBlocked),
      );
      expect(container.read(familyProvider), same(before));
      store.setCategoryBlocked(child.id, SpendingCategory.games, false);
      store.reportCardLost(child.id);
      before = container.read(familyProvider);
      expect(
        () => store.resolveOperation(child.id, pending.id, true),
        failsWith(FamilyFailureCode.inactiveCard),
      );
      expect(container.read(familyProvider), same(before));
      store.resolveOperation(child.id, pending.id, false);
      expect(
        current(child.id).operations.first.status,
        ChildOperationStatus.declined,
      );
      expect(current(child.id).balance, child.balance);
    },
  );

  testWidgets('rejected and stale permission requests cannot grant rights', (
    tester,
  ) async {
    final child = await ready(tester);
    store.setPermission(child.id, ChildPermission.onlinePayments, false);
    store.simulateChildRequest(child.id);
    final rejected = container.read(familyProvider).requests.last;
    store.resolveRequest(rejected.id, false);
    var before = container.read(familyProvider);
    expect(
      () => store.resolveRequest(rejected.id, true),
      failsWith(FamilyFailureCode.terminalDecision),
    );
    expect(container.read(familyProvider), same(before));
    store.simulateChildRequest(child.id);
    final stale = container.read(familyProvider).requests.last;
    store.setPermission(child.id, ChildPermission.onlinePayments, false);
    before = container.read(familyProvider);
    expect(
      () => store.resolveRequest(stale.id, true),
      failsWith(FamilyFailureCode.stalePolicy),
    );
    expect(container.read(familyProvider), same(before));
    expect(
      current(child.id).permissions,
      isNot(contains(ChildPermission.onlinePayments)),
    );
    store.resolveRequest(stale.id, false);
  });

  testWidgets(
    'domain setters reject invalid limits, mandatory unblock and pocket amounts',
    (tester) async {
      final child = await ready(tester);
      for (final invalid in [
        Money(-1),
        Money(familyMaxAmountMinor + 1),
        Money(1, currency: 'USD'),
      ]) {
        final before = container.read(familyProvider);
        expect(
          () => store.updateLimits(
            child.id,
            child.limits.copyWith(dailyLimit: invalid),
          ),
          failsWith(FamilyFailureCode.invalidAmount),
        );
        expect(
          () => store.updateLimits(
            child.id,
            child.limits.copyWith(monthlyLimit: invalid),
          ),
          failsWith(FamilyFailureCode.invalidAmount),
        );
        expect(
          () => store.updateLimits(
            child.id,
            child.limits.copyWith(approvalThreshold: invalid),
          ),
          failsWith(FamilyFailureCode.invalidAmount),
        );
        expect(
          () => store.setPocketMoney(
            child.id,
            PocketMoney(amount: invalid, period: PocketMoneyPeriod.daily),
          ),
          failsWith(FamilyFailureCode.invalidAmount),
        );
        expect(container.read(familyProvider), same(before));
      }
      expect(
        () => store.setCategoryBlocked(child.id, SpendingCategory.adult, false),
        failsWith(FamilyFailureCode.categoryBlocked),
      );
      expect(
        () => store.updateLimits(
          child.id,
          ChildLimits(
            dailyLimit: Money(100),
            monthlyLimit: Money(100),
            approvalThreshold: Money(0),
            adultCategoriesBlocked: false,
          ),
        ),
        failsWith(FamilyFailureCode.invalidLimits),
      );
      store.updateLimits(
        child.id,
        ChildLimits(
          dailyLimit: Money(0),
          monthlyLimit: Money(0),
          approvalThreshold: Money(0),
        ),
      );
      expect(
        store.simulateChildPurchase(child.id, 1).failureCode,
        FamilyFailureCode.dailyLimit,
      );
    },
  );

  testWidgets(
    'lost-card cancellation cannot activate a reissue on the old deadline',
    (tester) async {
      final child = issue();
      await tester.pump(const Duration(seconds: 2));
      store.reportCardLost(child.id);
      store.reissueCard(child.id);
      await tester.pump(const Duration(seconds: 2));
      expect(current(child.id).cardStatus, ChildCardStatus.reissuing);
      await tester.pump(const Duration(seconds: 2));
      expect(current(child.id).cardStatus, ChildCardStatus.active);
      expect(
        () => store.reissueCard(child.id),
        failsWith(FamilyFailureCode.invalidCardTransition),
      );
    },
  );

  testWidgets('disposing a store cancels pending activation timers', (
    tester,
  ) async {
    final child = issue();
    store.reportCardLost(child.id);
    store.reissueCard(child.id);
    container.dispose();
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'request approval publishes decision and permission atomically and preserves immediate revocation',
    (tester) async {
      final child = await ready(tester);
      store.setPermission(child.id, ChildPermission.onlinePayments, false);
      store.simulateChildRequest(child.id);
      final request = container.read(familyProvider).requests.single;
      var observedDecision = false;
      final subscription = container.listen(familyProvider, (previous, next) {
        if (observedDecision ||
            next.requests.single.status != FamilyRequestStatus.approved) {
          return;
        }
        observedDecision = true;
        expect(
          next.childById(child.id)!.permissions,
          contains(ChildPermission.onlinePayments),
        );
        store.setPermission(child.id, ChildPermission.onlinePayments, false);
      });
      addTearDown(subscription.close);
      store.resolveRequest(request.id, true);
      expect(observedDecision, isTrue);
      expect(
        current(child.id).permissions,
        isNot(contains(ChildPermission.onlinePayments)),
      );
    },
  );

  testWidgets(
    'duplicate approval from a synchronous observer cannot double debit',
    (tester) async {
      final child = await ready(tester);
      final pending = store.simulateChildPurchase(child.id, 1500);
      var retried = false;
      final subscription = container.listen(familyProvider, (previous, next) {
        if (retried ||
            next.childById(child.id)!.operations.first.status !=
                ChildOperationStatus.done) {
          return;
        }
        retried = true;
        expect(
          () => store.resolveOperation(child.id, pending.id, true),
          failsWith(FamilyFailureCode.terminalDecision),
        );
      });
      addTearDown(subscription.close);
      store.resolveOperation(child.id, pending.id, true);
      expect(retried, isTrue);
      expect(current(child.id).balance, Money(3500));
    },
  );

  testWidgets(
    'invalid package input is rejected before creating a profile or timer',
    (tester) async {
      final before = container.read(familyProvider);
      FamilyChild invalid({
        String name = 'Синтетический ребёнок',
        DateTime? birthDate,
        ChildLimits? limits,
      }) => store.issuePackage(
        name: name,
        birthDate: birthDate ?? DateTime(DateTime.now().year - 10, 1, 1),
        ageGroup: ChildAgeGroup.junior,
        cardType: ChildCardType.physical,
        permissions: {},
        blockedCategories: {},
        services: {},
        limits:
            limits ??
            ChildLimits(
              dailyLimit: Money(10000),
              monthlyLimit: Money(40000),
              approvalThreshold: Money(1000),
            ),
      );
      expect(
        () => invalid(name: '  '),
        failsWith(FamilyFailureCode.invalidProfile),
      );
      expect(
        () => invalid(birthDate: DateTime.now()),
        failsWith(FamilyFailureCode.invalidProfile),
      );
      expect(
        () => invalid(birthDate: DateTime(DateTime.now().year - 15)),
        failsWith(FamilyFailureCode.invalidProfile),
      );
      expect(
        () => invalid(
          limits: ChildLimits(
            dailyLimit: Money(-1),
            monthlyLimit: Money(100),
            approvalThreshold: Money(0),
          ),
        ),
        failsWith(FamilyFailureCode.invalidAmount),
      );
      expect(container.read(familyProvider), same(before));
      await tester.pump(const Duration(seconds: 10));
      expect(container.read(familyProvider), same(before));
    },
  );
}
