import 'package:flutter/material.dart';

import '../../app/family_session.dart';
import '../../core/config/space_content.dart';
import '../../core/config/space_ui_content.dart';
import '../../core/config/space_work_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/server/family_api.dart';
import '../../data/server/family_space.dart';
import 'space_components.dart';

bool _canAct(FamilySession session, SpaceActions actions) =>
    session.connected && !actions.busy && actions.pending == null;
bool _open(String status) => const {
  'accepted',
  'submitted',
  'clarification',
  'disputed',
}.contains(status);

class SpaceGoalsSection extends StatelessWidget {
  const SpaceGoalsSection({
    required this.session,
    required this.space,
    required this.actions,
    required this.childId,
    required this.adult,
    this.headerAction,
    super.key,
  });
  final FamilySession session;
  final FamilySpace space;
  final SpaceActions actions;
  final String childId;
  final bool adult;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final goals = space.goalsFor(childId);
    final enabled = _canAct(session, actions);
    final settings = space.settingsFor(childId);
    final child = session.children.where((c) => c['id'] == childId).firstOrNull;
    final available = child?['balanceMinor'] as int? ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpaceHeading(
          adult ? SpaceWorkContent.adultGoals : SpaceWorkContent.childGoals,
          body: adult ? SpaceWorkContent.goalsBody : SpaceUiCopy.goalTagline,
          action: adult
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: enabled ? () => _create(context) : null,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.all(4),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded),
                          Text(
                            SpaceContent.create,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ?headerAction,
                  ],
                ),
        ),
        if (!adult)
          SpacePanel(
            cloud: true,
            padding: 16,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const Text(SpaceUiCopy.goalAvailable),
                Text(
                  spaceMoney(available),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: MtBrandColors.blue),
                ),
              ],
            ),
          ),
        if (goals.isEmpty)
          const SpaceEmpty(
            title: SpaceUiCopy.noGoals,
            body: SpaceUiCopy.noGoalsBody,
            asset: SpaceAssets.goal,
          ),
        for (final goal in goals)
          SpacePanel(
            cloud: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      SpaceAssets.goal,
                      width: MediaQuery.textScalerOf(context).scale(1) > 1.15
                          ? 86
                          : 128,
                      height: 132,
                      excludeFromSemantics: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  spaceMoney(goal.savedMinor),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: MtBrandColors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SpaceUiCopy.ofAmount('', spaceMoney(goal.targetMinor)).trim(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: goal.targetMinor <= 0
                        ? 0
                        : (goal.savedMinor / goal.targetMinor).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: MtBrandColors.border,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  goal.savedMinor >= goal.targetMinor
                      ? SpaceWorkContent.goalReached
                      : SpaceWorkContent.moneyLine(
                          SpaceWorkContent.remaining,
                          spaceMoney(goal.targetMinor - goal.savedMinor),
                        ),
                ),
                if (goal.matchedMinor > 0) ...[
                  const SizedBox(height: 12),
                  _detail(
                    context,
                    SpaceWorkContent.matchingHistory,
                    spaceMoney(goal.matchedMinor),
                  ),
                ],
                const SizedBox(height: 20),
                if (!adult) ...[
                  FilledButton(
                    onPressed: enabled && available > 0
                        ? () => _move(context, goal, false)
                        : null,
                    child: const Text(SpaceUiCopy.goalDeposit),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    SpaceUiCopy.depositAvailable(spaceMoney(available)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: enabled && goal.savedMinor > 0
                          ? () => _move(context, goal, true)
                          : null,
                      child: const Text(SpaceUiCopy.goalWithdraw),
                    ),
                  ),
                ],
                if (adult) ...[
                  Text(
                    SpaceUiCopy.matching,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (settings?.matchingEnabled == true) ...[
                    Text(SpaceWorkContent.percent(settings!.matchingPercent)),
                    const SizedBox(height: 6),
                    Text(
                      SpaceWorkContent.moneyLine(
                        SpaceUiCopy.matchingCap,
                        spaceMoney(settings.matchingCapMinor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(SpaceWorkContent.matchingLifetime),
                    const SizedBox(height: 12),
                    if (goal.matchingStatus == 'available')
                      _detail(
                        context,
                        SpaceWorkContent.matchingAvailable,
                        spaceMoney(goal.matchingAvailableMinor ?? 0),
                      )
                    else
                      Text(
                        goal.matchingStatus == 'awaiting_funds'
                            ? SpaceWorkContent.matchingWaiting
                            : SpaceWorkContent.matchingNotEligible,
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed:
                          enabled &&
                              goal.matchingStatus == 'available' &&
                              (goal.matchingAvailableMinor ?? 0) > 0
                          ? () => _match(context, goal)
                          : null,
                      child: Text(SpaceContent.actionLabel('match')),
                    ),
                  ] else
                    const Text(SpaceWorkContent.matchingDisabled),
                ],
              ],
            ),
          ),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            SpaceUiCopy.goalBody,
            style: TextStyle(color: MtBrandColors.secondary),
          ),
        ),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    final values = await spaceForm(
      context,
      title: SpaceContent.newGoal,
      body: SpaceUiCopy.goalBody,
      fields: const [
        SpaceField('title', SpaceUiCopy.goalName),
        SpaceField(
          'targetMinor',
          SpaceContent.targetAmount,
          kind: SpaceFieldKind.money,
        ),
      ],
      submit: SpaceContent.create,
    );
    if (values != null && _canAct(session, actions)) {
      await actions.run({'type': 'goal.create', 'childId': childId, ...values});
    }
  }

  Future<void> _move(
    BuildContext context,
    SpaceGoal goal,
    bool withdraw,
  ) async {
    final child = session.children.where((c) => c['id'] == childId).firstOrNull;
    final available = withdraw
        ? goal.savedMinor
        : child?['balanceMinor'] as int? ?? 0;
    final max = available.clamp(
      0,
      space.capabilities?.maxAmountMinor ?? 10000000,
    );
    final values = await spaceForm(
      context,
      title: SpaceContent.actionLabel(withdraw ? 'withdraw' : 'deposit'),
      body: SpaceWorkContent.goalMoveBody,
      fields: [
        SpaceField(
          'amountMinor',
          SpaceContent.amount,
          kind: SpaceFieldKind.money,
          max: max,
          helper: SpaceUiCopy.availableAmount(spaceMoney(max)),
          maximumShortcut: true,
        ),
      ],
      submit: SpaceWorkContent.confirmGoalMove,
    );
    if (values != null && _canAct(session, actions)) {
      await actions.run({
        'type': 'goal.move',
        'childId': childId,
        'entityId': goal.id,
        'action': withdraw ? 'withdraw' : 'deposit',
        ...values,
      });
    }
  }

  Future<void> _match(BuildContext context, SpaceGoal goal) async {
    final values = await spaceForm(
      context,
      title: SpaceWorkContent.goalHelpTitle,
      body: SpaceUiCopy.matchingBody,
      fields: [
        SpaceField(
          'amountMinor',
          SpaceContent.amount,
          kind: SpaceFieldKind.money,
          max: goal.matchingAvailableMinor ?? 0,
          helper: SpaceUiCopy.availableAmount(
            spaceMoney(goal.matchingAvailableMinor ?? 0),
          ),
          maximumShortcut: true,
        ),
      ],
      submit: SpaceUiCopy.confirmMoney,
    );
    if (values != null && _canAct(session, actions)) {
      await actions.run({
        'type': 'goal.match',
        'childId': childId,
        'entityId': goal.id,
        ...values,
      });
    }
  }
}

class SpaceTasksSection extends StatelessWidget {
  const SpaceTasksSection({
    required this.session,
    required this.space,
    required this.actions,
    required this.childId,
    required this.adult,
    super.key,
  });
  final FamilySession session;
  final FamilySpace space;
  final SpaceActions actions;
  final String childId;
  final bool adult;

  @override
  Widget build(BuildContext context) {
    final tasks = space.tasksFor(childId);
    final enabled = _canAct(session, actions);
    final tasksEnabled = space.settingsFor(childId)?.tasksEnabled != false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SpaceHeading(SpaceContent.tasks, body: SpaceWorkContent.taskBody),
        if (!tasksEnabled)
          const SpacePanel(
            cloud: true,
            child: Text(SpaceWorkContent.disabledTasks),
          ),
        if (adult)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: FilledButton.icon(
              onPressed: enabled && tasksEnabled
                  ? () => _create(context)
                  : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text(SpaceUiCopy.newTask),
            ),
          ),
        if (tasks.isEmpty)
          SpaceEmpty(
            title: adult
                ? SpaceWorkContent.adultTasksEmpty
                : SpaceUiCopy.noTasks,
            body: adult
                ? SpaceWorkContent.adultTasksEmptyBody
                : SpaceUiCopy.noTasksBody,
          ),
        for (final task in tasks)
          SpacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _entityHeader(context, task.title, task.status),
                const SizedBox(height: 16),
                _detail(
                  context,
                  SpaceContent.reward,
                  spaceMoney(task.rewardMinor),
                ),
                const SizedBox(height: 8),
                Text(
                  task.status == 'approved'
                      ? SpaceWorkContent.taskPaidHint
                      : _open(task.status)
                      ? SpaceWorkContent.taskAcceptedHint
                      : SpaceWorkContent.taskRewardHint,
                  style: const TextStyle(color: MtBrandColors.secondary),
                ),
                if (_cancelReason(session, 'tasks', task.id)
                    case final reason?) ...[
                  const SizedBox(height: 16),
                  _detail(context, SpaceWorkContent.canceledBecause, reason),
                ],
                if (!adult && task.cancelRequested && _open(task.status)) ...[
                  const SizedBox(height: 16),
                  const Text(SpaceWorkContent.cancelRequest),
                ],
                if (task.status != 'approved' && task.status != 'canceled') ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!adult && task.status == 'offered')
                        _button(
                          SpaceContent.actionLabel('accept'),
                          enabled && tasksEnabled,
                          () => _confirmed(
                            context,
                            task,
                            'accept',
                            SpaceUiCopy.taskHint,
                          ),
                        ),
                      if (!adult &&
                          const {
                            'accepted',
                            'clarification',
                            'disputed',
                          }.contains(task.status))
                        _button(
                          SpaceContent.actionLabel('submit'),
                          enabled,
                          () => _confirmed(
                            context,
                            task,
                            'submit',
                            SpaceWorkContent.submitTaskBody,
                          ),
                        ),
                      if (!adult &&
                          _open(task.status) &&
                          task.status != 'disputed')
                        _button(
                          SpaceContent.actionLabel('dispute'),
                          enabled,
                          () => _confirmed(
                            context,
                            task,
                            'dispute',
                            SpaceUiCopy.disputeBody,
                          ),
                          secondary: true,
                        ),
                      if (!adult && task.cancelRequested && _open(task.status))
                        _button(
                          SpaceContent.actionLabel('agree_cancel'),
                          enabled,
                          () => _confirmed(
                            context,
                            task,
                            'agree_cancel',
                            SpaceUiCopy.cancelBody,
                          ),
                          secondary: true,
                        ),
                      if (adult && task.status == 'submitted')
                        _button(
                          SpaceContent.actionLabel('approve'),
                          enabled,
                          () => _confirmed(
                            context,
                            task,
                            'approve',
                            SpaceWorkContent.approveTaskBody,
                          ),
                        ),
                      if (adult &&
                          const {'submitted', 'disputed'}.contains(task.status))
                        _button(
                          SpaceContent.actionLabel('clarify'),
                          enabled,
                          () => _confirmed(
                            context,
                            task,
                            'clarify',
                            SpaceWorkContent.clarifyBody,
                          ),
                          secondary: true,
                        ),
                      if (adult)
                        _button(
                          SpaceWorkContent.taskCancel,
                          enabled,
                          () => _cancel(context, task),
                          secondary: true,
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

  Future<void> _create(BuildContext context) async {
    final values = await spaceForm(
      context,
      title: SpaceUiCopy.newTask,
      body: SpaceUiCopy.taskHint,
      fields: const [
        SpaceField('title', SpaceWorkContent.taskConditions),
        SpaceField(
          'rewardMinor',
          SpaceContent.reward,
          kind: SpaceFieldKind.money,
        ),
      ],
      submit: SpaceContent.create,
    );
    if (values != null && _canAct(session, actions)) {
      await actions.run({'type': 'task.create', 'childId': childId, ...values});
    }
  }

  Future<void> _confirmed(
    BuildContext context,
    SpaceTask task,
    String action,
    String body,
  ) async {
    if (await spaceConfirm(
          context,
          title: SpaceContent.actionLabel(action),
          body: body,
          action: SpaceContent.actionLabel(action),
        ) &&
        _canAct(session, actions)) {
      await actions.run({
        'type': 'task.action',
        'childId': childId,
        'entityId': task.id,
        'action': action,
      });
    }
  }

  Future<void> _cancel(BuildContext context, SpaceTask task) async {
    final values = await _reasonForm(context);
    if (values != null && _canAct(session, actions)) {
      await actions.run({
        'type': 'task.action',
        'childId': childId,
        'entityId': task.id,
        'action': 'cancel',
        ...values,
      });
    }
  }
}

class SpaceErrandsSection extends StatelessWidget {
  const SpaceErrandsSection({
    required this.session,
    required this.space,
    required this.actions,
    required this.childId,
    required this.adult,
    super.key,
  });
  final FamilySession session;
  final FamilySpace space;
  final SpaceActions actions;
  final String childId;
  final bool adult;

  @override
  Widget build(BuildContext context) {
    final errands = space.errandsFor(childId);
    final enabled = _canAct(session, actions);
    final errandsEnabled = space.settingsFor(childId)?.errandsEnabled != false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SpaceHeading(
          SpaceContent.errands,
          body: SpaceWorkContent.errandBody,
        ),
        if (!errandsEnabled)
          const SpacePanel(
            cloud: true,
            child: Text(SpaceWorkContent.disabledErrands),
          ),
        if (adult)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: FilledButton.icon(
              onPressed: enabled && errandsEnabled
                  ? () => _create(context)
                  : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text(SpaceContent.newErrand),
            ),
          ),
        if (errands.isEmpty)
          SpaceEmpty(
            title: adult
                ? SpaceWorkContent.adultErrandsEmpty
                : SpaceUiCopy.noErrands,
            body: adult
                ? SpaceWorkContent.adultErrandsEmptyBody
                : SpaceUiCopy.noErrandsBody,
            asset: SpaceAssets.allowance,
          ),
        for (final errand in errands)
          _card(context, errand, enabled, errandsEnabled),
      ],
    );
  }

  Widget _card(
    BuildContext context,
    SpaceErrand errand,
    bool enabled,
    bool errandsEnabled,
  ) {
    final terminal = const {'approved', 'canceled'}.contains(errand.status);
    final hasExpense = _expenseRecorded(session, errand);
    final needsReturn =
        errand.funding == 'funded' &&
        hasExpense &&
        errand.actualMinor < errand.budgetMinor &&
        !errand.returnConfirmed;
    return SpacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _entityHeader(context, errand.title, errand.status),
          const SizedBox(height: 16),
          _detail(context, SpaceContent.budget, spaceMoney(errand.budgetMinor)),
          const SizedBox(height: 10),
          _detail(
            context,
            SpaceWorkContent.rewardFixed,
            spaceMoney(errand.rewardMinor),
          ),
          const SizedBox(height: 16),
          Text(
            SpaceContent.statusLabel(errand.funding),
            style: const TextStyle(color: MtBrandColors.blue),
          ),
          if (hasExpense) ...[
            const Divider(height: 28),
            _detail(
              context,
              SpaceContent.actualAmount,
              spaceMoney(errand.actualMinor),
            ),
            if (errand.funding == 'funded') ...[
              const SizedBox(height: 10),
              _detail(
                context,
                SpaceContent.remainder,
                spaceMoney(errand.budgetMinor - errand.actualMinor),
              ),
            ],
            if (errand.returnConfirmed) ...[
              const SizedBox(height: 10),
              const Text(SpaceWorkContent.returned),
            ],
          ],
          if (needsReturn) ...[
            const SizedBox(height: 12),
            const Text(SpaceWorkContent.returnWaiting),
          ],
          if (_cancelReason(session, 'errands', errand.id)
              case final reason?) ...[
            const SizedBox(height: 16),
            _detail(context, SpaceWorkContent.canceledBecause, reason),
          ],
          if (errand.status == 'approved') ...[
            const SizedBox(height: 16),
            const Text(SpaceWorkContent.errandPaidHint),
          ],
          if (!terminal) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (adult &&
                    errand.status == 'offered' &&
                    errand.funding == 'awaiting_funds')
                  _button(
                    SpaceContent.actionLabel('fund'),
                    enabled,
                    () => _confirmed(
                      context,
                      errand,
                      'fund',
                      SpaceWorkContent.fundBody,
                    ),
                  ),
                if (!adult && errand.status == 'offered')
                  _button(
                    SpaceContent.actionLabel('accept'),
                    enabled &&
                        errandsEnabled &&
                        errand.funding != 'awaiting_funds',
                    () => _accept(context, errand),
                  ),
                if (!adult &&
                    const {
                      'accepted',
                      'clarification',
                      'disputed',
                    }.contains(errand.status))
                  _button(
                    SpaceUiCopy.submitExpense,
                    enabled,
                    () => _submit(context, errand, hasExpense),
                  ),
                if (!adult && needsReturn)
                  _button(
                    SpaceUiCopy.confirmReturn,
                    enabled,
                    () => _confirmed(
                      context,
                      errand,
                      'return',
                      SpaceUiCopy.returnBody,
                    ),
                    secondary: true,
                  ),
                if (!adult &&
                    _open(errand.status) &&
                    errand.status != 'disputed')
                  _button(
                    SpaceContent.actionLabel('dispute'),
                    enabled,
                    () => _confirmed(
                      context,
                      errand,
                      'dispute',
                      SpaceUiCopy.disputeBody,
                    ),
                    secondary: true,
                  ),
                if (adult && errand.status == 'submitted')
                  _button(
                    SpaceContent.actionLabel('approve'),
                    enabled && !needsReturn,
                    () => _confirmed(
                      context,
                      errand,
                      'approve',
                      SpaceWorkContent.approveErrandBody,
                    ),
                  ),
                if (adult &&
                    const {'submitted', 'disputed'}.contains(errand.status))
                  _button(
                    SpaceContent.actionLabel('clarify'),
                    enabled,
                    () => _confirmed(
                      context,
                      errand,
                      'clarify',
                      SpaceWorkContent.clarifyBody,
                    ),
                    secondary: true,
                  ),
                if (adult && errand.actualMinor == 0)
                  _button(
                    SpaceWorkContent.errandCancel,
                    enabled,
                    () => _cancel(context, errand),
                    secondary: true,
                  ),
                if (!adult &&
                    errand.cancelRequested &&
                    _open(errand.status) &&
                    errand.actualMinor == 0)
                  _button(
                    SpaceContent.actionLabel('agree_cancel'),
                    enabled,
                    () => _confirmed(
                      context,
                      errand,
                      'agree_cancel',
                      SpaceUiCopy.cancelBody,
                    ),
                    secondary: true,
                  ),
              ],
            ),
            if (adult && errand.actualMinor > 0) ...[
              const SizedBox(height: 12),
              const Text(
                SpaceWorkContent.expenseProtected,
                style: TextStyle(color: MtBrandColors.secondary),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final values = await spaceForm(
      context,
      title: SpaceContent.newErrand,
      body: SpaceUiCopy.errandHint,
      fields: const [
        SpaceField('title', SpaceWorkContent.taskConditions),
        SpaceField(
          'budgetMinor',
          SpaceContent.budget,
          kind: SpaceFieldKind.money,
        ),
        SpaceField(
          'rewardMinor',
          SpaceContent.reward,
          kind: SpaceFieldKind.money,
          allowZero: true,
        ),
        SpaceField(
          'funding',
          SpaceContent.funding,
          kind: SpaceFieldKind.choice,
          choices: {
            'funded': SpaceUiCopy.funded,
            'awaiting_funds': SpaceUiCopy.waitFunding,
            'reimburse': SpaceUiCopy.reimburse,
          },
        ),
      ],
      submit: SpaceContent.create,
    );
    if (values != null && _canAct(session, actions)) {
      await actions.run({
        'type': 'errand.create',
        'childId': childId,
        ...values,
      });
    }
  }

  Future<void> _accept(BuildContext context, SpaceErrand errand) async {
    final bool confirmed;
    if (errand.funding == 'reimburse') {
      confirmed = await showSpaceOwnMoneyConsent(context);
    } else {
      confirmed = await spaceConfirm(
        context,
        title: SpaceContent.actionLabel('accept'),
        body: SpaceWorkContent.acceptErrandBody,
        action: SpaceContent.actionLabel('accept'),
      );
    }
    if (confirmed && _canAct(session, actions)) {
      await actions.run({
        'type': 'errand.action',
        'childId': childId,
        'entityId': errand.id,
        'action': 'accept',
        if (errand.funding == 'reimburse') 'ownMoneyConsent': true,
      });
    }
  }

  Future<void> _submit(
    BuildContext context,
    SpaceErrand errand,
    bool hasExpense,
  ) async {
    final values = await spaceForm(
      context,
      title: SpaceUiCopy.submitExpense,
      body: hasExpense
          ? SpaceWorkContent.expenseLocked
          : '${SpaceWorkContent.expenseNotRecorded}\n${SpaceWorkContent.zeroExpenseHint}',
      fields: [
        SpaceField(
          'amountMinor',
          SpaceContent.actualAmount,
          kind: SpaceFieldKind.money,
          allowZero: true,
          max: errand.budgetMinor,
          initial: hasExpense ? errand.actualMinor : null,
        ),
      ],
      submit: SpaceContent.actionLabel('submit'),
    );
    if (values != null && _canAct(session, actions)) {
      await actions.run({
        'type': 'errand.action',
        'childId': childId,
        'entityId': errand.id,
        'action': 'submit',
        ...values,
      });
    }
  }

  Future<void> _confirmed(
    BuildContext context,
    SpaceErrand errand,
    String action,
    String body,
  ) async {
    if (await spaceConfirm(
          context,
          title: SpaceContent.actionLabel(action),
          body: body,
          action: SpaceContent.actionLabel(action),
        ) &&
        _canAct(session, actions)) {
      await actions.run({
        'type': 'errand.action',
        'childId': childId,
        'entityId': errand.id,
        'action': action,
      });
    }
  }

  Future<void> _cancel(BuildContext context, SpaceErrand errand) async {
    final values = await _reasonForm(context);
    if (values != null && _canAct(session, actions)) {
      await actions.run({
        'type': 'errand.action',
        'childId': childId,
        'entityId': errand.id,
        'action': 'cancel',
        ...values,
      });
    }
  }
}

/// Consent starts unchecked each time, and no command is sent on dismissal.
Future<bool> showSpaceOwnMoneyConsent(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => const _OwnMoneyConsentDialog(),
    ) ??
    false;

class _OwnMoneyConsentDialog extends StatefulWidget {
  const _OwnMoneyConsentDialog();
  @override
  State<_OwnMoneyConsentDialog> createState() => _OwnMoneyConsentDialogState();
}

class _OwnMoneyConsentDialogState extends State<_OwnMoneyConsentDialog> {
  bool _consent = false;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(SpaceUiCopy.ownConsentTitle),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(SpaceUiCopy.ownConsentBody),
          const SizedBox(height: 16),
          CheckboxListTile(
            key: const ValueKey('space-own-money-consent'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(SpaceUiCopy.ownConsent),
            value: _consent,
            onChanged: (value) => setState(() => _consent = value ?? false),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(SpaceContent.cancel),
      ),
      FilledButton(
        key: const ValueKey('space-own-money-confirm'),
        onPressed: _consent ? () => Navigator.pop(context, true) : null,
        child: const Text(SpaceWorkContent.consentConfirm),
      ),
    ],
  );
}

Future<JsonMap?> _reasonForm(BuildContext context) => spaceForm(
  context,
  title: SpaceWorkContent.cancelReasonTitle,
  body: SpaceWorkContent.cancelReasonBody,
  fields: const [SpaceField('reason', SpaceWorkContent.cancelReason)],
  submit: SpaceContent.actionLabel('cancel'),
);
Widget _button(
  String title,
  bool enabled,
  VoidCallback action, {
  bool secondary = false,
}) => secondary
    ? OutlinedButton(onPressed: enabled ? action : null, child: Text(title))
    : FilledButton(onPressed: enabled ? action : null, child: Text(title));
Widget _entityHeader(BuildContext context, String title, String status) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SpacePill(status),
      ],
    );
Widget _detail(BuildContext context, String label, String value) => Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Text(
        label,
        style: const TextStyle(color: MtBrandColors.secondary),
      ),
    ),
    const SizedBox(width: 16),
    Flexible(
      child: Text(
        value,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    ),
  ],
);
JsonMap? _rawEntity(FamilySession session, String collection, String id) {
  final data = session.snapshot?['familySpace'];
  final items = data is Map ? data[collection] : null;
  if (items is List) {
    for (final item in items) {
      if (item is JsonMap && item['id'] == id) return item;
    }
  }
  return null;
}

String? _cancelReason(FamilySession session, String collection, String id) {
  final value = _rawEntity(session, collection, id)?['cancelReason'];
  return value is String && value.trim().isNotEmpty ? value : null;
}

bool _expenseRecorded(FamilySession session, SpaceErrand errand) {
  final recorded = _rawEntity(
    session,
    'errands',
    errand.id,
  )?['expenseRecorded'];
  if (recorded is bool) return recorded;
  // Older snapshots did not expose the flag. A dispute alone does not prove
  // that a purchase happened; it may have started immediately after acceptance.
  return errand.actualMinor > 0 ||
      const {'submitted', 'approved'}.contains(errand.status);
}
