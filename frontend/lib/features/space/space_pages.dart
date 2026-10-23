import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/family_session.dart';
import '../../core/config/space_content.dart';
import '../../core/config/children_content.dart';
import '../../core/config/space_navigation_content.dart';
import '../../core/config/space_ui_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../core/ui/mt_back_button.dart';
import '../../data/server/family_api.dart';
import '../../data/server/family_space.dart';
import '../../data/server/money_intent.dart';
import '../../data/server/family_ui_contract.dart';
import 'space_components.dart';
import 'space_work_sections.dart';
import 'space_control_sections.dart';
import 'space_inbox_section.dart';

bool _active(JsonMap child) =>
    child['membershipStatus'] == 'active' &&
    child['accountStatus'] == 'synthetic_open';
String _name(JsonMap child) =>
    child['displayName'] as String? ?? SpaceContent.profile;
int _balance(JsonMap child) => child['balanceMinor'] as int? ?? 0;
int _age(JsonMap child, FamilySession session) {
  final dob = DateTime.tryParse(child['dateOfBirth'] as String? ?? '');
  final today =
      DateTime.tryParse(session.snapshot?['businessDate'] as String? ?? '') ??
      DateTime.now();
  if (dob == null) {
    return 0;
  }
  var age = today.year - dob.year;
  if (today.month < dob.month ||
      (today.month == dob.month && today.day < dob.day)) {
    age--;
  }
  return age;
}

int _pendingCount(FamilySession session, FamilySpace space, String id) =>
    space.requestsFor(id).where((r) => r.status == 'pending').length +
    (session.snapshot?['operations'] as List? ?? [])
        .whereType<JsonMap>()
        .where((op) => op['childId'] == id && op['status'] == 'pending')
        .length;

class SpaceAdultPage extends StatelessWidget {
  const SpaceAdultPage({super.key});
  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: Scaffold(
      appBar: AppBar(
        leading: const MtBackButton(),
        title: const Text(SpaceContent.family),
      ),
      body: SafeArea(
        bottom: false,
        child: SpaceSessionView(
          builder: (context, session, space, actions) {
            if (!space.isAvailable) {
              return _Unavailable(session: session, actions: actions);
            }
            final children = session.children
                .where((c) => c['membershipStatus'] == 'active')
                .toList();
            return SpaceBody(
              bottom: 112,
              children: [
                const SpaceHeading(
                  SpaceUiCopy.familyWallet,
                  body: SpaceContent.walletDescription,
                ),
                SpaceNotices(session: session, actions: actions),
                if (space.adultWallet case final wallet?)
                  SpaceHero(
                    title: SpaceContent.adultAvailable,
                    amount: spaceMoney(wallet.availableMinor),
                    details: [
                      (SpaceContent.reserved, spaceMoney(wallet.reservedMinor)),
                    ],
                    action: FilledButton(
                      onPressed: actions.busy || !session.connected
                          ? null
                          : () => _distribute(context, session, actions),
                      child: const Text(SpaceUiCopy.distribute),
                    ),
                  ),
                if (children.isEmpty)
                  SpaceEmpty(
                    title: SpaceUiCopy.chooseChild,
                    body: SpaceUiCopy.noSchedulesBody,
                    asset: SpaceAssets.allowance,
                    action: FilledButton(
                      onPressed: () => context.push('/family/apply'),
                      child: const Text(SpaceUiCopy.chooseChild),
                    ),
                  ),
                for (final child in children)
                  if (space
                      .installmentsFor(child['id'] as String)
                      .any(
                        (i) => {'insufficient', 'missed'}.contains(i.status),
                      ))
                    SpaceLink(
                      title: '${SpaceUiCopy.missingFunds} · ${_name(child)}',
                      icon: Icons.calendar_month_outlined,
                      onTap: () => context.push(
                        '/family/child/${child['id']}?section=money',
                      ),
                    ),
                SpacePanel(
                  child: SpaceLink(
                    title: SpaceContent.notifications,
                    subtitle: SpaceUiCopy.notificationsBody,
                    icon: Icons.notifications_none_rounded,
                    onTap: () => context.push('/family/inbox'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

Future<void> _distribute(
  BuildContext context,
  FamilySession session,
  SpaceActions actions, {
  String? childId,
}) async {
  final choices = {
    for (final child in session.children.where(_active))
      child['id'] as String: _name(child),
  };
  if (choices.isEmpty) {
    context.push('/family/apply');
    return;
  }
  final available =
      FamilySpace.fromSnapshot(session.snapshot).adultWallet?.availableMinor ??
      0;
  final form = await spaceForm(
    context,
    title: childId == null ? SpaceUiCopy.distribute : SpaceUiCopy.topUpChild,
    body: childId == null
        ? SpaceUiCopy.moneySource
        : '${choices[childId]} · ${SpaceUiCopy.moneySource}',
    fields: [
      if (childId == null)
        SpaceField(
          'childId',
          SpaceUiCopy.chooseChild,
          kind: SpaceFieldKind.choice,
          initial: childId,
          choices: choices,
        ),
      SpaceField(
        'amountMinor',
        SpaceContent.amount,
        kind: SpaceFieldKind.money,
        max: available,
        helper: SpaceUiCopy.availableAmount(spaceMoney(available)),
        maximumShortcut: true,
      ),
    ],
    submit: SpaceUiCopy.moneyTransfer,
  );
  if (form != null) {
    await actions.run({
      'type': 'wallet.transfer',
      ...form,
      'childId': ?childId,
    });
  }
}

class SpaceAdultChildPage extends StatelessWidget {
  const SpaceAdultChildPage({
    required this.childId,
    this.initialSection = 'overview',
    super.key,
  });
  final String childId, initialSection;
  String get _section => initialSection;
  void _open(BuildContext context, String section) =>
      context.push('/family/child/$childId/$section');
  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: Scaffold(
      appBar: AppBar(
        leading: const MtBackButton(),
        title: Text(
          SpaceNavigationContent.sections[_section]?.title ??
              SpaceUiCopy.familyBack,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SpaceSessionView(
          builder: (context, session, space, actions) {
            final children = session.children
                .where((c) => c['id'] == childId)
                .toList();
            if (children.isEmpty) {
              return const Center(child: Text(SpaceUiCopy.noDataBody));
            }
            final child = children.first;
            return SpaceBody(
              top: _section == 'overview' ? 12 : 24,
              bottom: 24,
              children: [
                if (_section == 'overview')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: MtBrandColors.cloud,
                          foregroundColor: MtBrandColors.blue,
                          child: Text(
                            _name(child).characters.first,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name(child),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ChildrenContent.childAge(_age(child, session)),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: MtBrandColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SpaceHeading(
                    _name(child),
                    body: SpaceNavigationContent.sections[_section]?.body,
                  ),
                SpaceNotices(session: session, actions: actions),
                if (!_active(child))
                  SpaceEmpty(
                    title: SpaceUiCopy.unfinished,
                    body: SpaceUiCopy.unfinishedBody,
                    asset: SpaceAssets.allowance,
                    action: FilledButton(
                      onPressed: () =>
                          context.push('/family/child/$childId/setup'),
                      child: const Text(SpaceUiCopy.setup),
                    ),
                  )
                else if (!space.isAvailable)
                  _Unavailable(session: session, actions: actions)
                else
                  ..._content(context, session, space, actions, child),
              ],
            );
          },
        ),
      ),
    ),
  );
  List<Widget> _content(
    BuildContext context,
    FamilySession session,
    FamilySpace space,
    SpaceActions actions,
    JsonMap child,
  ) {
    final id = childId;
    return switch (_section) {
      'money' => [
        FilledButton.icon(
          onPressed: actions.busy || !session.connected
              ? null
              : () => _distribute(context, session, actions, childId: id),
          icon: const Icon(Icons.add_rounded),
          label: const Text(SpaceUiCopy.topUpChild),
        ),
        const SizedBox(height: 24),
        SpaceHistory(
          session: session,
          childId: id,
          actions: actions,
          adult: true,
          pendingOnly: true,
        ),
        SpaceRequestsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: true,
        ),
        SpaceSchedulesSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: true,
        ),
        SpaceHistory(
          session: session,
          childId: id,
          actions: actions,
          adult: true,
          excludePending: true,
        ),
        _Weekly(space: space, childId: id),
      ],
      'work' => [
        SpaceTasksSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: true,
        ),
        const SizedBox(height: 24),
        SpaceErrandsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: true,
        ),
      ],
      'goals' => [
        SpaceGoalsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: true,
        ),
      ],
      'growth' => [
        SpaceLearningSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: true,
        ),
      ],
      'settings' => [
        SpacePanel(
          child: SpaceLink(
            title: child['cardStatus'] == 'blocked'
                ? SpaceUiCopy.unblockCard
                : SpaceUiCopy.blockCard,
            icon: Icons.lock_outline_rounded,
            onTap:
                actions.protectiveBusy ||
                    !session.connected ||
                    (actions.busy && child['cardStatus'] == 'blocked')
                ? null
                : () async {
                    if (await spaceConfirm(
                      context,
                      title: child['cardStatus'] == 'blocked'
                          ? SpaceUiCopy.unblockCard
                          : SpaceUiCopy.blockCard,
                      body: SpaceUiCopy.safetyBody,
                    )) {
                      if (child['cardStatus'] == 'blocked') {
                        await actions.perform(() async {
                          await session.command('PATCH', '/v1/children/$id', {
                            'cardStatus': 'active',
                          });
                        });
                      } else {
                        await actions.run({
                          'type': 'card.block',
                          'childId': id,
                        });
                      }
                    }
                  },
          ),
        ),
        SpaceSettingsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: true,
        ),
        SpacePanel(
          child: SpaceLink(
            title: SpaceUiCopy.setup,
            subtitle: SpaceUiCopy.setupBody,
            icon: Icons.fact_check_outlined,
            onTap: () => context.push('/family/child/$id/setup'),
          ),
        ),
      ],
      _ => [
        SpaceHero(
          compact: true,
          title: SpaceUiCopy.canSpend,
          amount: spaceMoney(_balance(child)),
          details: [
            (
              SpaceUiCopy.inGoals,
              spaceMoney(
                space.goalsFor(id).fold(0, (sum, g) => sum + g.savedMinor),
              ),
            ),
          ],
          action: FilledButton(
            onPressed: actions.busy || !session.connected
                ? null
                : () => _distribute(context, session, actions, childId: id),
            child: const Text(SpaceUiCopy.topUpChild),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            SpaceUiCopy.manage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Column(
          children: [
            for (final entry in SpaceNavigationContent.sections.entries) ...[
              if (entry.key != 'money') const Divider(height: 1),
              SpaceLink(
                dense: true,
                title: entry.value.title,
                subtitle:
                    entry.key == 'money' &&
                        _pendingCount(session, space, id) > 0
                    ? '${entry.value.body} · ${SpaceUiCopy.waitingRequests(_pendingCount(session, space, id))}'
                    : entry.value.body,
                icon: _sectionIcon(entry.key),
                onTap: () => _open(context, entry.key),
              ),
            ],
          ],
        ),
      ],
    };
  }
}

IconData _sectionIcon(String section) => switch (section) {
  'money' => Icons.account_balance_wallet_outlined,
  'work' => Icons.task_alt_rounded,
  'goals' => Icons.flag_outlined,
  'growth' => Icons.menu_book_outlined,
  _ => Icons.credit_card_outlined,
};

class SpaceChildPage extends StatefulWidget {
  const SpaceChildPage({super.key});
  @override
  State<SpaceChildPage> createState() => _SpaceChildPageState();
}

class _SpaceChildPageState extends State<SpaceChildPage> {
  int _index = 0;
  final _details = <String>[];
  String? get _detail => _details.lastOrNull;
  void _showDetail(String value) => setState(() => _details.add(value));
  void _backDetail() => setState(() => _details.removeLast());
  void _selectTab(int index) => setState(() {
    _index = index;
    _details.clear();
  });
  Widget _profileAction(JsonMap child) => SpaceProfileButton(
    name: _name(child),
    onPressed: () => _showDetail('profile'),
  );
  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: SpaceSessionView(
      builder: (context, session, space, actions) {
        final child = session.child;
        return PopScope(
          canPop: _detail == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _backDetail();
            }
          },
          child: Scaffold(
            body: SafeArea(
              bottom: false,
              child: child == null
                  ? const Center(child: CircularProgressIndicator())
                  : !space.isAvailable
                  ? _Unavailable(session: session, actions: actions)
                  : AnimatedSwitcher(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      child: SpaceBody(
                        key: ValueKey('$_index/$_detail'),
                        children: [
                          if (_detail != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  MtBackButton(onPressed: _backDetail),
                                  const SizedBox(width: 8),
                                  Text(
                                    _details.length > 1
                                        ? SpaceContent.profile
                                        : SpaceContent.childNav[_index],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          SpaceNotices(session: session, actions: actions),
                          ..._content(context, session, space, actions, child),
                        ],
                      ),
                    ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: MtBrandColors.border)),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < SpaceContent.childNav.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: _index == i,
                          button: true,
                          label: SpaceContent.childNav[i],
                          child: InkWell(
                            onTap: () => _selectTab(i),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 72),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 10,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (i == 0)
                                      SourceIcon(
                                        _index == i
                                            ? 'main_logo_p'
                                            : 'ic_main_inactive',
                                        size: 26,
                                      )
                                    else
                                      Icon(
                                        [
                                          Icons.account_balance_wallet_outlined,
                                          Icons.task_alt_rounded,
                                          Icons.flag_outlined,
                                          Icons.menu_book_outlined,
                                        ][i - 1],
                                        size: 26,
                                        color: _index == i
                                            ? MtBrandColors.blue
                                            : MtBrandColors.secondary,
                                      ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        SpaceContent.childNav[i],
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _index == i
                                              ? MtBrandColors.blue
                                              : MtBrandColors.secondary,
                                          fontWeight: _index == i
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  List<Widget> _content(
    BuildContext context,
    FamilySession session,
    FamilySpace space,
    SpaceActions actions,
    JsonMap child,
  ) {
    final id = child['id'] as String;
    if (_detail == 'profile') {
      return [
        SpaceHeading(
          _name(child),
          body: SpaceUiCopy.childAge(
            SpaceContent.profile,
            _age(child, session),
          ),
        ),
        SpacePanel(
          child: Column(
            children: [
              SpaceLink(
                title: SpaceUiCopy.familyRules,
                icon: Icons.tune_rounded,
                onTap: () => _showDetail('rules'),
              ),
              SpaceLink(
                title: SpaceContent.notifications,
                icon: Icons.notifications_none_rounded,
                onTap: () => _showDetail('notices'),
              ),
              SpaceLink(
                title: SpaceContent.history,
                icon: Icons.receipt_long_outlined,
                onTap: () => _showDetail('history'),
              ),
              SpaceLink(
                title: SpaceUiCopy.products,
                icon: Icons.widgets_outlined,
                onTap: () => _showDetail('products'),
              ),
              SpaceLink(
                title: SpaceUiCopy.support,
                icon: Icons.support_agent_outlined,
                onTap: () => _showDetail('help'),
              ),
            ],
          ),
        ),
        if (child['cardStatus'] == 'active')
          OutlinedButton.icon(
            onPressed: actions.busy || !session.connected
                ? null
                : () async {
                    if (await spaceConfirm(
                      context,
                      title: SpaceUiCopy.blockCard,
                      body: SpaceUiCopy.safetyBody,
                      action: SpaceUiCopy.blockCard,
                    )) {
                      await actions.run({'type': 'card.block', 'childId': id});
                    }
                  },
            icon: const Icon(Icons.lock_outline_rounded),
            label: const Text(SpaceUiCopy.blockCard),
          ),
        if (child['cardStatus'] == 'blocked')
          const SpacePanel(child: Text(SpaceUiCopy.blocked)),
        OutlinedButton(
          onPressed: actions.busy
              ? null
              : () async {
                  if (await spaceConfirm(
                    context,
                    title: SpaceUiCopy.logout,
                    body: SpaceUiCopy.logoutBody,
                    action: SpaceUiCopy.logout,
                  )) {
                    await actions.perform(session.logout);
                  }
                },
          child: const Text(SpaceUiCopy.logout),
        ),
      ];
    }
    if (_detail == 'rules') {
      return [
        SpaceSettingsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
        ),
      ];
    }
    if (_detail == 'notices') {
      return [
        const SpaceHeading(SpaceContent.notifications),
        SpaceInboxSection(
          session: session,
          space: space,
          actions: actions,
          onChildSection: (section) {
            if (section == 'settings') {
              _showDetail('rules');
            } else {
              _selectTab(
                {'money': 1, 'work': 2, 'goals': 3, 'growth': 4}[section] ?? 0,
              );
            }
          },
        ),
      ];
    }
    if (_detail == 'history') {
      return [
        const SpaceHeading(SpaceContent.history),
        SpaceHistory(
          session: session,
          childId: id,
          actions: actions,
          adult: false,
        ),
      ];
    }
    if (_detail == 'products') {
      return [
        const SpaceHeading(
          SpaceUiCopy.products,
          body: SpaceUiCopy.productsBody,
        ),
        for (final title in [
          SpaceUiCopy.longTerm,
          SpaceUiCopy.insurance,
          SpaceUiCopy.benefits,
        ])
          SpacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const Text(SpaceUiCopy.productBoundary),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: actions.busy || !session.connected
                      ? null
                      : () => actions.run({
                          'type': 'request.create',
                          'childId': id,
                          'title': title,
                          'kind': 'help',
                        }),
                  child: const Text(SpaceUiCopy.discuss),
                ),
              ],
            ),
          ),
      ];
    }
    if (_detail == 'help') {
      return [
        const SpaceHeading(
          SpaceUiCopy.safetyTitle,
          body: SpaceUiCopy.safetyBody,
        ),
        SpaceRequestsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
        ),
      ];
    }
    return switch (_index) {
      1 => [
        SpaceHeading(SpaceContent.money, action: _profileAction(child)),
        SpaceHero(
          title: SpaceUiCopy.canSpend,
          amount: spaceMoney(_balance(child)),
          asset: SpaceAssets.allowance,
          action: FilledButton(
            onPressed:
                !_active(child) ||
                    child['cardStatus'] == 'blocked' ||
                    actions.busy ||
                    !session.connected
                ? null
                : () => _purchase(context, session, actions, child),
            child: const Text(SpaceUiCopy.purchase),
          ),
        ),
        if (child['cardStatus'] == 'blocked')
          const SpacePanel(child: Text(SpaceUiCopy.blocked)),
        SpaceRequestsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
        ),
        SpaceSchedulesSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
        ),
        SpaceHistory(
          session: session,
          childId: id,
          actions: actions,
          adult: false,
        ),
        _Weekly(space: space, childId: id),
      ],
      2 => [
        SpaceHeading(SpaceContent.tasks, action: _profileAction(child)),
        SpaceTasksSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
        ),
        const SizedBox(height: 24),
        SpaceErrandsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
        ),
      ],
      3 => [
        SpaceGoalsSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
          headerAction: _profileAction(child),
        ),
      ],
      4 => [
        SpaceLearningSection(
          session: session,
          space: space,
          actions: actions,
          childId: id,
          adult: false,
          headerAction: _profileAction(child),
        ),
      ],
      _ => _home(context, session, space, actions, child),
    };
  }

  List<Widget> _home(
    BuildContext context,
    FamilySession session,
    FamilySpace space,
    SpaceActions actions,
    JsonMap child,
  ) {
    final id = child['id'] as String;
    final goals = space.goalsFor(id);
    final tasks = space
        .tasksFor(id)
        .where((t) => !{'approved', 'canceled', 'cancelled'}.contains(t.status))
        .toList();
    final schedules = space.allowancesFor(id).where((a) => a.active).toList()
      ..sort((a, b) => a.nextDate.compareTo(b.nextDate));
    return [
      SpaceHeading(
        SpaceUiCopy.greeting(_name(child), _age(child, session) >= 14),
        eyebrow: SpaceUiCopy.myMoby,
        action: _profileAction(child),
      ),
      SpaceHero(
        title: SpaceUiCopy.canSpend,
        amount: spaceMoney(_balance(child)),
        details: [
          (
            SpaceUiCopy.inGoals,
            spaceMoney(goals.fold(0, (sum, g) => sum + g.savedMinor)),
          ),
        ],
        action: FilledButton(
          onPressed:
              actions.busy || !session.connected || actions.pending != null
              ? null
              : () => _age(child, session) >= 14 && goals.isNotEmpty
                    ? _moveToGoal(context, id, goals, actions, _balance(child))
                    : _askMoney(context, id, actions),
          child: Text(
            _age(child, session) >= 14 && goals.isNotEmpty
                ? SpaceUiCopy.toGoal
                : SpaceUiCopy.askMoney,
          ),
        ),
      ),
      if (schedules.isNotEmpty)
        SpacePanel(
          child: SpaceLink(
            title: SpaceContent.allowances,
            subtitle:
                '${SpaceUiCopy.paymentDate(schedules.first.nextDate)} · ${spaceMoney(schedules.first.amountMinor)}',
            icon: Icons.calendar_month_outlined,
            onTap: () => _selectTab(1),
          ),
        ),
      if (tasks.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Text(
            SpaceUiCopy.now,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SpacePanel(
          cloud: true,
          child: SpaceLink(
            title: tasks.first.title,
            subtitle: SpaceUiCopy.rewardAfterReview(
              spaceMoney(tasks.first.rewardMinor),
            ),
            icon: Icons.task_alt_rounded,
            onTap: () => _selectTab(2),
          ),
        ),
      ],
    ];
  }
}

Future<void> _moveToGoal(
  BuildContext context,
  String id,
  List<SpaceGoal> goals,
  SpaceActions actions,
  int availableMinor,
) async {
  final result = await spaceForm(
    context,
    title: SpaceUiCopy.toGoal,
    body: SpaceUiCopy.goalBody,
    fields: [
      SpaceField(
        'entityId',
        SpaceContent.goals,
        kind: SpaceFieldKind.choice,
        choices: {for (final goal in goals) goal.id: goal.title},
      ),
      SpaceField(
        'amountMinor',
        SpaceContent.amount,
        kind: SpaceFieldKind.money,
        max: availableMinor,
        helper: SpaceUiCopy.availableAmount(spaceMoney(availableMinor)),
        maximumShortcut: true,
      ),
    ],
  );
  if (result != null) {
    await actions.run({
      'type': 'goal.move',
      'childId': id,
      'action': 'deposit',
      ...result,
    });
  }
}

Future<void> _askMoney(
  BuildContext context,
  String childId,
  SpaceActions actions,
) async {
  final values = await spaceForm(
    context,
    title: SpaceUiCopy.askMoney,
    body: SpaceUiCopy.askMoneyBody,
    fields: const [
      SpaceField('title', SpaceUiCopy.requestReason),
      SpaceField(
        'amountMinor',
        SpaceContent.amount,
        kind: SpaceFieldKind.money,
      ),
    ],
  );
  if (values != null) {
    await actions.run({
      'type': 'request.create',
      'childId': childId,
      'kind': 'money',
      ...values,
    });
  }
}

Future<void> _purchase(
  BuildContext context,
  FamilySession session,
  SpaceActions actions,
  JsonMap child,
) async {
  final values = await spaceForm(
    context,
    title: SpaceUiCopy.purchase,
    body: SpaceUiCopy.purchaseBody,
    fields: [
      const SpaceField('merchant', SpaceUiCopy.merchant),
      SpaceField(
        'amountMinor',
        SpaceContent.amount,
        kind: SpaceFieldKind.money,
        max: _balance(child),
        helper: SpaceUiCopy.availableAmount(spaceMoney(_balance(child))),
      ),
      SpaceField(
        'category',
        SpaceUiCopy.category,
        kind: SpaceFieldKind.choice,
        choices: familyCategoryLabels,
      ),
      const SpaceField(
        'internet',
        SpaceUiCopy.internet,
        kind: SpaceFieldKind.toggle,
      ),
    ],
  );
  if (values == null) {
    return;
  }
  await actions.perform(() async {
    final store = session.moneyIntents;
    final id = child['id'] as String;
    final pending = await store.load(
      childId: id,
      kind: MoneyIntentKind.purchase,
    );
    if (pending != null) {
      throw const PendingMoneyIntentException();
    }
    await store.submit(
      childId: id,
      kind: MoneyIntentKind.purchase,
      payload: {
        'amountMinor': values['amountMinor'],
        'currency': 'BYN',
        'category': values['category'],
        'channel': values['internet'] == true ? 'internet' : 'pos',
        'merchant': values['merchant'],
      },
    );
  });
}

class SpaceHistory extends StatelessWidget {
  const SpaceHistory({
    required this.session,
    required this.childId,
    required this.actions,
    required this.adult,
    this.pendingOnly = false,
    this.excludePending = false,
    super.key,
  });
  final FamilySession session;
  final String childId;
  final SpaceActions actions;
  final bool adult, pendingOnly, excludePending;
  @override
  Widget build(BuildContext context) {
    final operations =
        (session.snapshot?['operations'] as List? ?? [])
            .whereType<JsonMap>()
            .where(
              (o) =>
                  o['childId'] == childId &&
                  (!pendingOnly || o['status'] == 'pending') &&
                  (!excludePending || o['status'] != 'pending'),
            )
            .toList()
          ..sort(
            (a, b) => (b['createdAt'] as num).compareTo(a['createdAt'] as num),
          );
    final activity =
        FamilySpace.fromSnapshot(session.snapshot).activity
            .where(
              (entry) =>
                  !pendingOnly &&
                  entry.childId == childId &&
                  entry.kind != 'task_complete',
            )
            .toList()
          ..sort((a, b) => b.at.compareTo(a.at));
    if (pendingOnly && operations.isEmpty) return const SizedBox.shrink();
    if (operations.isEmpty && activity.isEmpty) {
      return const SpaceEmpty(
        title: SpaceUiCopy.noHistory,
        body: SpaceUiCopy.noHistoryBody,
        asset: SpaceAssets.allowance,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            pendingOnly ? SpaceContent.pendingRequests : SpaceContent.history,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (activity.isNotEmpty) ...[
          Text(
            SpaceUiCopy.activityTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final entry in activity.take(60))
            SpacePanel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(SpaceUiCopy.operationLabel(entry.kind))),
                  const SizedBox(width: 12),
                  Text(spaceMoney(entry.amountMinor)),
                ],
              ),
            ),
        ],
        for (final op in (pendingOnly ? operations : operations.take(60)))
          SpacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (op['merchant'] as String? ?? '').trim().isNotEmpty
                            ? op['merchant'] as String
                            : SpaceUiCopy.operationLabel(
                                op['kind'] as String? ?? '',
                              ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(formatFamilyMoney(op['amountMinor'])),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SpacePill(op['status'] as String? ?? 'pending'),
                ),
                if (adult && op['status'] == 'pending') ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final approve in [true, false])
                        OutlinedButton(
                          onPressed: actions.busy || !session.connected
                              ? null
                              : () => actions.perform(() async {
                                  await session.command(
                                    'POST',
                                    '/v1/operations/${op['id']}/decision',
                                    {'approve': approve},
                                  );
                                }),
                          child: Text(
                            approve
                                ? SpaceContent.actionLabel('approve')
                                : SpaceContent.actionLabel('decline'),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Weekly extends StatelessWidget {
  const _Weekly({required this.space, required this.childId});
  final FamilySpace space;
  final String childId;
  @override
  Widget build(BuildContext context) {
    final week = space.weeklyFor(childId);
    if (week == null) {
      return const SizedBox.shrink();
    }
    return SpacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            SpaceContent.week,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          for (final pair in [
            (SpaceContent.incoming, spaceMoney(week.incomingMinor)),
            (SpaceContent.spent, spaceMoney(week.spentMinor)),
            (SpaceContent.saved, spaceMoney(week.savedMinor)),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: Text(pair.$1)),
                  Text(pair.$2, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            SpaceUiCopy.weeklyScope,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.session, required this.actions});
  final FamilySession session;
  final SpaceActions actions;
  @override
  Widget build(BuildContext context) => SpaceBody(
    children: [
      const SpaceHeading(SpaceUiCopy.noData, body: SpaceUiCopy.noDataBody),
      SpaceNotices(session: session, actions: actions),
      OutlinedButton(
        onPressed: actions.busy
            ? null
            : () => actions.perform(() async {
                await session.refresh();
              }),
        child: const Text(SpaceUiCopy.refresh),
      ),
      if (session.phase == FamilySessionPhase.signedIn)
        OutlinedButton(
          onPressed: actions.busy
              ? null
              : () => actions.perform(session.logout),
          child: const Text(SpaceUiCopy.logout),
        ),
    ],
  );
}

class SpaceInboxPage extends StatelessWidget {
  const SpaceInboxPage({super.key});
  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: Scaffold(
      appBar: AppBar(
        leading: const MtBackButton(),
        title: const Text(SpaceContent.notifications),
      ),
      body: SafeArea(
        bottom: false,
        child: SpaceSessionView(
          builder: (context, session, space, actions) => SpaceBody(
            bottom: 112,
            children: [
              SpaceNotices(session: session, actions: actions),
              SpaceInboxSection(
                session: session,
                space: space,
                actions: actions,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
