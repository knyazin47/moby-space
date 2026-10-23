import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/family_session.dart';
import '../../core/config/children_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/server/family_api.dart';
import '../../data/server/family_ui_contract.dart';
import 'family_widgets.dart';
import '../space/space_components.dart';
import '../../data/server/family_space.dart';
import '../../core/config/space_ui_content.dart';
import '../../core/config/space_content.dart';

/// The shell owns the persistent tab bar; this widget provides only its body.
class ChildrenTabPage extends ConsumerStatefulWidget {
  const ChildrenTabPage({this.reviewIntro = false, super.key});

  /// Help is readable again without changing the persisted onboarding choice.
  final bool reviewIntro;

  @override
  ConsumerState<ChildrenTabPage> createState() => _ChildrenTabPageState();
}

class _ChildrenTabPageState extends ConsumerState<ChildrenTabPage> {
  bool _saving = false;
  bool _refreshing = false;
  String? _actionError;

  Future<void> _completeIntro(FamilySession session) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _actionError = null;
    });
    try {
      await session.completeFamilyIntro();
    } catch (_) {
      if (mounted) {
        setState(() => _actionError = ChildrenContent.completionFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _refresh(FamilySession session) async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _actionError = null;
    });
    try {
      if (session.phase == FamilySessionPhase.restoring) {
        await session.restore();
      } else {
        await session.refresh();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _actionError = ChildrenContent.refreshFailed);
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(familySessionProvider);
    return Theme(
      data: buildMtBrandTheme(),
      child: Material(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: session,
            builder: (context, _) {
              if (widget.reviewIntro) return _intro(context, session);
              if (session.phase == FamilySessionPhase.restoring ||
                  !session.familyPreferencesAvailable) {
                return _preferencesUnavailable(context, session);
              }
              return session.familyIntroSeen
                  ? _family(context, session)
                  : _intro(context, session);
            },
          ),
        ),
      ),
    );
  }

  Widget _preferencesUnavailable(BuildContext context, FamilySession session) {
    final restoring =
        session.phase == FamilySessionPhase.restoring && session.error == null;
    return _TabScroll(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (restoring) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 24),
            const Text(ChildrenContent.restoring, textAlign: TextAlign.center),
          ] else ...[
            Text(
              ChildrenContent.unavailableTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              ChildrenContent.unavailableBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _refreshing ? null : () => _refresh(session),
              child: Text(
                _refreshing
                    ? ChildrenContent.refreshing
                    : ChildrenContent.retry,
              ),
            ),
          ],
          if (_actionError != null) _ActionError(_actionError!),
        ],
      ),
    );
  }

  Widget _intro(BuildContext context, FamilySession session) => _TabScroll(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(ChildrenContent.introTitle, style: _heading(context)),
        const SizedBox(height: 12),
        Text(
          ChildrenContent.introBody,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Image.asset(
          ChildrenContent.introImage,
          height: 190,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < ChildrenContent.introBenefits.length; i++) ...[
          if (i > 0) const Divider(height: 16),
          _BenefitRow(
            benefit: ChildrenContent.introBenefits[i],
            highlighted: i == 0,
          ),
        ],
        const SizedBox(height: 24),
        if (!session.connected || session.error != null)
          _ConnectionNotice(session: session),
        if (_actionError != null) _ActionError(_actionError!),
        FilledButton(
          onPressed: widget.reviewIntro
              ? () => context.go('/family')
              : _saving
              ? null
              : () => _completeIntro(session),
          child: Text(
            widget.reviewIntro
                ? ChildrenContent.returnToFamily
                : _saving
                ? ChildrenContent.completing
                : ChildrenContent.start,
          ),
        ),
      ],
    ),
  );

  Widget _family(BuildContext context, FamilySession session) {
    final children = session.children
        .where((child) => child['membershipStatus'] == 'active')
        .toList(growable: false);
    final space = FamilySpace.fromSnapshot(session.snapshot);
    final activeIds = children.map((child) => child['id']).toSet();
    final pending =
        space.requests
            .where(
              (request) =>
                  request.status == 'pending' &&
                  request.kind == 'money' &&
                  activeIds.contains(request.childId),
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FamilyHeading(),
          const SizedBox(height: 12),
          Text(
            ChildrenContent.familyBody,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: MtBrandColors.secondary),
          ),
          if (!session.connected || session.error != null) ...[
            const SizedBox(height: 16),
            _ConnectionNotice(session: session),
          ],
          if (space.adultWallet case final wallet?) ...[
            const SizedBox(height: 20),
            _FamilyWallet(wallet: wallet),
          ],
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: MtBrandColors.cloud,
                      child: Icon(
                        Icons.people_outline_rounded,
                        color: MtBrandColors.blue,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    ChildrenContent.emptyTitle,
                    textAlign: TextAlign.center,
                    style: _heading(context).copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ChildrenContent.emptyBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: MtBrandColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: session.connected
                        ? () => context.push('/family/apply')
                        : null,
                    child: const Text(ChildrenContent.addChild),
                  ),
                ],
              ),
            )
          else ...[
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ChildrenContent.childrenTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: session.connected
                      ? () => context.push('/family/apply')
                      : null,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(ChildrenContent.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MtBrandColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Divider(height: 1),
                      ),
                    _ChildRow(
                      child: children[i],
                      businessDate:
                          session.snapshot?['businessDate'] as String?,
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 16),
            _PendingMoneyRequest(
              request: pending.first,
              child: children.firstWhere(
                (c) => c['id'] == pending.first.childId,
              ),
              remaining: pending.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

TextStyle _heading(BuildContext context) => Theme.of(context)
    .textTheme
    .headlineLarge!
    .copyWith(fontSize: 32, height: 1.05, fontWeight: FontWeight.w600);

class _FamilyHeading extends StatelessWidget {
  const _FamilyHeading();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(ChildrenContent.familyTitle, style: _heading(context)),
      ),
      const SizedBox(width: 8),
      IconButton(
        tooltip: SpaceContent.notifications,
        onPressed: () => context.push('/family/inbox'),
        icon: const Icon(
          Icons.notifications_none_rounded,
          color: MtBrandColors.blue,
        ),
      ),
      IconButton(
        tooltip: ChildrenContent.howItWorks,
        onPressed: () => context.push('/family/intro'),
        icon: const Icon(Icons.help_outline_rounded, color: MtBrandColors.blue),
      ),
    ],
  );
}

class _TabScroll extends StatelessWidget {
  const _TabScroll({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => FamilyMaxWidth(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final bottom =
            MobyMetrics.contentBottomPadding +
            MediaQuery.paddingOf(context).bottom +
            MediaQuery.viewInsetsOf(context).bottom;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - 24 - bottom),
            ),
            // LayoutBuilder descendants cannot provide intrinsic dimensions.
            // Let actual layout determine scroll extent and hit-test bounds.
            child: child,
          ),
        );
      },
    ),
  );
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit, required this.highlighted});
  final ChildrenBenefit benefit;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: highlighted ? MtBrandColors.cloud : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: highlighted ? Colors.white : MtBrandColors.cloud,
          foregroundColor: MtBrandColors.blue,
          child: Icon(switch (benefit.kind) {
            ChildrenBenefitKind.money => Icons.account_balance_wallet_outlined,
            ChildrenBenefitKind.rules => Icons.tune_rounded,
            ChildrenBenefitKind.connection => Icons.phone_android_rounded,
          }, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                benefit.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                benefit.body,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: MtBrandColors.secondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FamilyWallet extends StatelessWidget {
  const _FamilyWallet({required this.wallet});
  final SpaceWallet wallet;

  @override
  Widget build(BuildContext context) => Material(
    color: MtBrandColors.cloud,
    borderRadius: BorderRadius.circular(24),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: const ValueKey('family-wallet'),
      onTap: () => context.push('/family/space'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SpaceUiCopy.familyWallet,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spaceMoney(wallet.availableMinor),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: MtBrandColors.blue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ChildrenContent.walletReserved(
                      spaceMoney(wallet.reservedMinor),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (MediaQuery.textScalerOf(context).scale(1) <= 1.15)
              Image.asset(
                SpaceAssets.allowance,
                width: 78,
                height: 94,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: MtBrandColors.blue,
            ),
          ],
        ),
      ),
    ),
  );
}

class _PendingMoneyRequest extends StatelessWidget {
  const _PendingMoneyRequest({
    required this.request,
    required this.child,
    required this.remaining,
  });
  final SpaceRequest request;
  final JsonMap child;
  final int remaining;

  @override
  Widget build(BuildContext context) => SpacePanel(
    cloud: true,
    padding: 12,
    child: SpaceLink(
      title: ChildrenContent.moneyRequest(
        child['displayName'] as String? ?? ChildrenContent.childFallbackName,
        spaceMoney(request.amountMinor),
      ),
      subtitle: [
        request.title,
        ChildrenContent.needsDecision,
        if (remaining > 0) ChildrenContent.moreMoneyRequests(remaining),
      ].join(' · '),
      icon: Icons.chat_bubble_outline_rounded,
      onTap: () => context.push('/family/child/${request.childId}/money'),
    ),
  );
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({required this.child, this.businessDate});
  final JsonMap child;
  final String? businessDate;

  int? get _age {
    final today = DateTime.tryParse(businessDate ?? '');
    final birth = DateTime.tryParse(child['dateOfBirth'] as String? ?? '');
    if (today == null || birth == null || birth.isAfter(today)) return null;
    var value = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      value--;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = child['displayName'] as String?;
    final name = displayName == null || displayName.trim().isEmpty
        ? ChildrenContent.childFallbackName
        : displayName;
    final hasAccount = child['accountStatus'] == 'synthetic_open';
    final paired = child['deviceAccessStatus'] == 'paired';
    final status = !hasAccount
        ? ChildrenContent.unfinished
        : paired
        ? ChildrenContent.phoneConnected
        : child['deviceAccessStatus'] == 'revoked'
        ? ChildrenContent.accessRevoked
        : ChildrenContent.phoneNotConnected;
    final subtitle = [
      if (hasAccount && _age != null) ChildrenContent.childAge(_age!),
      status,
    ].join(' · ');
    final balance = hasAccount
        ? formatFamilyMoney(child['balanceMinor'])
        : ChildrenContent.profileCreated;
    return InkWell(
      key: ValueKey('family-child-${child['id']}'),
      onTap: () => context.push('/family/child/${child['id']}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: MtBrandColors.cloud,
              foregroundColor: MtBrandColors.blue,
              child: Text(
                name.characters.first.toUpperCase(),
                style: const TextStyle(fontSize: 21),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wrap =
                      MediaQuery.textScalerOf(context).scale(1) > 1.15 ||
                      constraints.maxWidth < 205;
                  final money = Text(
                    balance,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: hasAccount
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (!wrap) ...[const SizedBox(width: 8), money],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (!hasAccount &&
                          subtitle != ChildrenContent.unfinished) ...[
                        const SizedBox(height: 4),
                        const Text(
                          ChildrenContent.unfinished,
                          style: TextStyle(
                            color: MtBrandColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (wrap) ...[
                        const SizedBox(height: 6),
                        Align(alignment: Alignment.centerRight, child: money),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: MtBrandColors.blue,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionNotice extends StatelessWidget {
  const _ConnectionNotice({required this.session});
  final FamilySession session;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          size: 18,
          color: MtBrandColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            session.error ?? ChildrenContent.disconnected,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class _ActionError extends StatelessWidget {
  const _ActionError(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: MtBrandColors.red),
      ),
    ),
  );
}
