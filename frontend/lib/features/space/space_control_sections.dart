import 'package:flutter/material.dart';

import '../../app/family_session.dart';
import '../../core/config/space_content.dart';
import '../../core/config/space_control_content.dart';
import '../../core/config/space_policy_presets.dart';
import '../../core/config/space_ui_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/server/family_api.dart';
import '../../data/server/family_space.dart';
import '../../data/server/family_ui_contract.dart';
import 'space_components.dart';

bool _enabled(FamilySession session, SpaceActions actions) =>
    session.connected && !actions.busy && actions.pending == null;

Widget _button(String label, VoidCallback? action) => ConstrainedBox(
  constraints: const BoxConstraints(minWidth: double.infinity, minHeight: 52),
  child: FilledButton(onPressed: action, child: Text(label)),
);

JsonMap _command(String type, String childId, [JsonMap fields = const {}]) => {
  'type': type,
  'childId': childId,
  ...fields,
};

String _today() => DateTime.now()
    .toUtc()
    .add(const Duration(hours: 3))
    .toIso8601String()
    .substring(0, 10);

class SpaceSchedulesSection extends StatelessWidget {
  const SpaceSchedulesSection({
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

  Future<void> _edit(BuildContext context, [SpaceAllowance? schedule]) async {
    final values = await spaceForm(
      context,
      title: schedule == null
          ? SpaceUiCopy.createSchedule
          : SpaceControlContent.editSchedule,
      body: '${SpaceUiCopy.scheduleHint}\n\n${SpaceUiCopy.retryHint}',
      fields: [
        SpaceField(
          'title',
          SpaceControlContent.scheduleTitle,
          initial: schedule?.title,
        ),
        SpaceField(
          'amountMinor',
          SpaceContent.amount,
          kind: SpaceFieldKind.money,
          initial: schedule?.amountMinor,
        ),
        SpaceField(
          'frequency',
          SpaceContent.frequency,
          kind: SpaceFieldKind.choice,
          initial: schedule?.frequency ?? 'weekly',
          choices: SpaceContent.frequencyLabels,
        ),
        SpaceField(
          'nextDate',
          SpaceControlContent.scheduleStart,
          kind: SpaceFieldKind.date,
          initial:
              schedule != null && schedule.nextDate.compareTo(_today()) >= 0
              ? schedule.nextDate
              : _today(),
        ),
        SpaceField(
          'retryLimit',
          SpaceContent.retryLimit,
          kind: SpaceFieldKind.integer,
          initial: schedule?.retryLimit ?? 0,
          allowZero: true,
          max: 3,
        ),
      ],
    );
    if (values == null || !context.mounted) return;
    if ((values['nextDate'] as String).compareTo(_today()) < 0) {
      await spaceConfirm(
        context,
        title: SpaceContent.dateInvalid,
        body: SpaceUiCopy.firstDate,
        action: SpaceUiCopy.done,
      );
      return;
    }
    values['weekdays'] = <int>[];
    values['monthDay'] = 0;
    if (values['frequency'] == 'weekly') {
      final days = await showDialog<List<int>>(
        context: context,
        builder: (_) => _WeekdayDialog(
          initial: schedule?.frequency == 'weekly'
              ? schedule!.weekdays
              : const [],
        ),
      );
      if (days == null) return;
      values['weekdays'] = days;
    } else if (values['frequency'] == 'monthly') {
      if (!context.mounted) return;
      final day = await spaceForm(
        context,
        title: SpaceContent.monthDay,
        body: SpaceControlContent.monthlyHint,
        fields: [
          SpaceField(
            'monthDay',
            SpaceContent.monthDay,
            kind: SpaceFieldKind.integer,
            initial: schedule?.frequency == 'monthly' ? schedule!.monthDay : 1,
            max: 31,
          ),
        ],
      );
      if (day == null) return;
      values['monthDay'] = day['monthDay'];
    }
    if (!context.mounted) return;
    final confirmed = await _schedulePreview(context, values, schedule);
    if (confirmed) {
      await actions.run(
        _command(
          schedule == null ? 'allowance.create' : 'allowance.update',
          childId,
          {...values, if (schedule != null) 'entityId': schedule.id},
        ),
      );
    }
  }

  Future<void> _installment(
    BuildContext context,
    SpaceInstallment item,
    String action,
  ) async {
    if (await spaceConfirm(
      context,
      title:
          '${SpaceContent.actionLabel(action)} · ${spaceMoney(item.amountMinor)}',
      body: action == 'settle'
          ? SpaceControlContent.installmentSettle
          : SpaceControlContent.installmentCancel,
      action: SpaceContent.actionLabel(action),
    )) {
      await actions.run(
        _command('allowance.action', childId, {
          'entityId': item.id,
          'action': action,
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules = space.allowancesFor(childId);
    final installments = space.installmentsFor(childId);
    final enabled = _enabled(session, actions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SpaceHeading(
          SpaceContent.allowances,
          body: SpaceUiCopy.scheduleHint,
        ),
        if (adult) ...[
          _button(
            SpaceUiCopy.createSchedule,
            enabled ? () => _edit(context) : null,
          ),
          const SizedBox(height: 24),
        ],
        if (schedules.isEmpty)
          const SpaceEmpty(
            title: SpaceUiCopy.noSchedules,
            body: SpaceUiCopy.noSchedulesBody,
            asset: SpaceAssets.allowance,
          ),
        for (final item in schedules)
          SpacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  spaceMoney(item.amountMinor),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  [
                    SpaceContent.frequencyLabel(item.frequency),
                    if (item.frequency == 'weekly')
                      item.weekdays
                          .map(
                            (day) => day >= 0 && day < 7
                                ? SpaceContent.weekdayLabels[day]
                                : '',
                          )
                          .join(', '),
                    if (item.frequency == 'monthly')
                      SpaceControlContent.monthDay(item.monthDay),
                  ].join(' · '),
                ),
                const SizedBox(height: 8),
                Text(SpaceControlContent.nextTransfer(item.nextDate)),
                const SizedBox(height: 8),
                Text(SpaceControlContent.attempts(item.retryLimit)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SpacePill(item.active ? 'active' : 'paused'),
                ),
                if (adult) ...[
                  const SizedBox(height: 16),
                  _button(
                    SpaceControlContent.editSchedule,
                    enabled ? () => _edit(context, item) : null,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: enabled
                        ? () => actions.run(
                            _command('allowance.action', childId, {
                              'entityId': item.id,
                              'action': item.active ? 'pause' : 'resume',
                            }),
                          )
                        : null,
                    child: Text(
                      SpaceContent.actionLabel(
                        item.active ? 'pause' : 'resume',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8),
        const SpaceHeading(SpaceContent.installments),
        if (installments.isEmpty)
          const Text(SpaceControlContent.noInstallments),
        for (final item in installments)
          SpacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${SpaceControlContent.dated(item.dueDate)} · ${spaceMoney(item.amountMinor)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SpacePill(item.status),
                ),
                if (adult &&
                    {'insufficient', 'missed'}.contains(item.status)) ...[
                  const SizedBox(height: 16),
                  _button(
                    SpaceContent.actionLabel('settle'),
                    enabled
                        ? () => _installment(context, item, 'settle')
                        : null,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: enabled
                        ? () => _installment(context, item, 'cancel')
                        : null,
                    child: Text(SpaceContent.actionLabel('cancel')),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _WeekdayDialog extends StatefulWidget {
  const _WeekdayDialog({required this.initial});
  final List<int> initial;
  @override
  State<_WeekdayDialog> createState() => _WeekdayDialogState();
}

class _WeekdayDialogState extends State<_WeekdayDialog> {
  late final Set<int> _days = widget.initial
      .where((day) => day >= 0 && day <= 6)
      .toSet();
  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    title: const Text(SpaceControlContent.chooseWeekday),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(SpaceControlContent.weeklyDays),
          const SizedBox(height: 12),
          for (final day in [1, 2, 3, 4, 5, 6, 0])
            CheckboxListTile(
              key: ValueKey('schedule-weekday-$day'),
              contentPadding: EdgeInsets.zero,
              title: Text(SpaceControlContent.weekdayNames[day]),
              value: _days.contains(day),
              onChanged: (selected) => setState(() {
                if (selected == true) {
                  _days.add(day);
                } else {
                  _days.remove(day);
                }
              }),
            ),
          if (_days.isEmpty)
            const Text(SpaceControlContent.chooseAtLeastOneDay),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(SpaceUiCopy.cancel),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: FilledButton(
          key: const ValueKey('schedule-weekdays-save'),
          onPressed: _days.isEmpty
              ? null
              : () => Navigator.pop(context, _days.toList()..sort()),
          child: const Text(SpaceUiCopy.save),
        ),
      ),
    ],
  );
}

Future<bool> _schedulePreview(
  BuildContext context,
  JsonMap values,
  SpaceAllowance? previous,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const ValueKey('schedule-preview'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text(SpaceControlContent.reviewSchedule),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                values['title'] as String,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(spaceMoney(values['amountMinor'] as int)),
              const SizedBox(height: 12),
              Text(SpaceContent.frequencyLabel(values['frequency'] as String)),
              if (values['frequency'] == 'weekly') ...[
                const SizedBox(height: 8),
                Text(
                  (values['weekdays'] as List<int>)
                      .map((day) => SpaceControlContent.weekdayNames[day])
                      .join(', '),
                ),
              ],
              if (values['frequency'] == 'monthly') ...[
                const SizedBox(height: 8),
                Text(SpaceControlContent.monthDay(values['monthDay'] as int)),
              ],
              const SizedBox(height: 12),
              Text(
                '${SpaceControlContent.scheduleStart}: ${SpaceControlContent.dated(values['nextDate'] as String)}',
              ),
              const SizedBox(height: 8),
              const Text(SpaceControlContent.scheduleStartHint),
              const SizedBox(height: 12),
              Text(SpaceControlContent.attempts(values['retryLimit'] as int)),
              const SizedBox(height: 12),
              const Text(SpaceUiCopy.retryHint),
              if (previous != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SpacePill(previous.active ? 'active' : 'paused'),
                ),
                const SizedBox(height: 16),
                const Text(SpaceControlContent.schedulePreviewBody),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(SpaceUiCopy.cancel),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: FilledButton(
              key: const ValueKey('schedule-preview-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(SpaceControlContent.confirmSchedule),
            ),
          ),
        ],
      ),
    ) ??
    false;

JsonMap? _policy(FamilySession session, String childId) {
  for (final child in session.children) {
    if (child['id'] != childId) continue;
    final raw = child['policy'];
    if (raw is! Map) return null;
    final policy = Map<String, dynamic>.from(raw);
    if ([
          'payments',
          'transfers',
          'internet',
        ].any((key) => policy[key] is! bool) ||
        [
          'dailyLimit',
          'monthlyLimit',
          'approvalThreshold',
        ].any((key) => policy[key] is! int)) {
      return null;
    }
    if (policy['categories'] is! Map ||
        (policy['categories'] as Map).values.any((value) => value is! bool)) {
      return null;
    }
    return policy;
  }
  return null;
}

Future<JsonMap?> _editPolicy(
  BuildContext context,
  JsonMap policy, {
  bool request = false,
}) async {
  final categories = Map<String, dynamic>.from(policy['categories'] as Map);
  final result = await spaceForm(
    context,
    title: request ? SpaceUiCopy.requestPolicy : SpaceControlContent.editPolicy,
    body: request ? SpaceUiCopy.policyHint : SpaceUiCopy.settingsHint,
    fields: [
      if (request) const SpaceField('title', SpaceContent.requestTitle),
      for (final entry in const {
        'payments': SpaceUiCopy.payments,
        'internet': SpaceUiCopy.internet,
      }.entries)
        SpaceField(
          entry.key,
          entry.value,
          kind: SpaceFieldKind.toggle,
          initial: policy[entry.key],
        ),
      SpaceField(
        'dailyLimit',
        SpaceUiCopy.dailyLimit,
        kind: SpaceFieldKind.money,
        initial: policy['dailyLimit'],
        allowZero: true,
      ),
      SpaceField(
        'monthlyLimit',
        SpaceUiCopy.monthlyLimit,
        kind: SpaceFieldKind.money,
        initial: policy['monthlyLimit'],
        allowZero: true,
        max: 100000000,
      ),
      SpaceField(
        'approvalThreshold',
        SpaceUiCopy.approval,
        kind: SpaceFieldKind.money,
        initial: policy['approvalThreshold'],
        allowZero: true,
      ),
      for (final entry in familyCategoryLabels.entries)
        SpaceField(
          'category-${entry.key}',
          entry.value,
          kind: SpaceFieldKind.toggle,
          initial: categories[entry.key] == true,
        ),
    ],
  );
  if (result == null || !context.mounted) return null;
  if ((result['monthlyLimit'] as int) < (result['dailyLimit'] as int)) {
    await spaceConfirm(
      context,
      title: SpaceControlContent.monthTooSmall,
      body: SpaceUiCopy.dailyLimit,
      action: SpaceUiCopy.done,
    );
    return null;
  }
  final full = <String, dynamic>{
    for (final key in [
      'payments',
      'internet',
      'dailyLimit',
      'monthlyLimit',
      'approvalThreshold',
    ])
      key: result[key],
    'transfers': policy['transfers'],
    'categories': {
      for (final key in familyCategoryLabels.keys) key: result['category-$key'],
    },
  };
  return request ? {'title': result['title'], 'policy': full} : full;
}

Widget _policySummary(BuildContext context, JsonMap policy) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (final entry in const {
      'dailyLimit': SpaceUiCopy.dailyLimit,
      'monthlyLimit': SpaceUiCopy.monthlyLimit,
      'approvalThreshold': SpaceUiCopy.approval,
    }.entries)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('${entry.value}: ${spaceMoney(policy[entry.key] as int)}'),
      ),
    for (final entry in const {
      'payments': SpaceUiCopy.payments,
      'internet': SpaceUiCopy.internet,
    }.entries)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          '${entry.value}: ${policy[entry.key] == true ? SpaceControlContent.allowed : SpaceControlContent.forbidden}',
        ),
      ),
    Text(
      SpaceControlContent.categories,
      style: Theme.of(context).textTheme.titleMedium,
    ),
    const SizedBox(height: 12),
    for (final entry in familyCategoryLabels.entries)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          '${entry.value}: ${(policy['categories'] as Map?)?[entry.key] == true ? SpaceControlContent.allowed : SpaceControlContent.forbidden}',
        ),
      ),
  ],
);

Future<bool> _confirmPolicy(
  BuildContext context,
  JsonMap policy, {
  String title = SpaceControlContent.policyPreview,
  String body = SpaceControlContent.policyPreviewBody,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const ValueKey('policy-preview'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(body),
              const SizedBox(height: 24),
              _policySummary(context, policy),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(SpaceUiCopy.cancel),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: FilledButton(
              key: const ValueKey('policy-preview-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(SpaceControlContent.confirmPolicy),
            ),
          ),
        ],
      ),
    ) ??
    false;

Future<SpacePolicyPreset?> _choosePolicyPreset(BuildContext context) =>
    showDialog<SpacePolicyPreset>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text(SpaceControlContent.policyProfiles),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(SpaceControlContent.policyProfilesBody),
              const SizedBox(height: 20),
              for (final preset in SpacePolicyPresets.values) ...[
                OutlinedButton(
                  key: ValueKey('policy-preset-${preset.id.name}'),
                  onPressed: () => Navigator.pop(context, preset),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          preset.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(preset.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(SpaceUiCopy.cancel),
          ),
        ],
      ),
    );

Future<void> _policyRequest(
  BuildContext context,
  FamilySession session,
  SpaceActions actions,
  String childId,
) async {
  final policy = _policy(session, childId);
  if (policy == null) return;
  final fields = await _editPolicy(context, policy, request: true);
  if (fields != null) {
    await actions.run(
      _command('request.create', childId, {'kind': 'policy', ...fields}),
    );
  }
}

class SpaceSettingsSection extends StatelessWidget {
  const SpaceSettingsSection({
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

  Future<void> _savePolicy(JsonMap policy) => session.command(
    'PATCH',
    '/v1/children/${Uri.encodeComponent(childId)}/policy',
    policy,
  );

  Future<void> _preset(BuildContext context, JsonMap policy) async {
    final preset = await _choosePolicyPreset(context);
    if (preset == null || !context.mounted) return;
    final proposed = preset.preview(policy);
    if (await _confirmPolicy(
      context,
      proposed,
      title: preset.title,
      body: '${preset.description}\n\n${SpaceControlContent.presetPreviewBody}',
    )) {
      await actions.perform(() async {
        await _savePolicy(proposed);
      });
    }
  }

  Future<void> _settings(BuildContext context, SpaceSettings settings) async {
    final result = await spaceForm(
      context,
      title: SpaceControlContent.editSettings,
      body:
          '${SpaceControlContent.matchingLifetime}\n\n${SpaceControlContent.notificationsPreference}',
      fields: [
        SpaceField(
          'matchingEnabled',
          SpaceUiCopy.matchingEnabled,
          kind: SpaceFieldKind.toggle,
          initial: settings.matchingEnabled,
        ),
        SpaceField(
          'matchingPercent',
          SpaceUiCopy.matchingPercent,
          kind: SpaceFieldKind.integer,
          initial: settings.matchingPercent,
          allowZero: true,
          max: 100,
        ),
        SpaceField(
          'matchingCapMinor',
          SpaceUiCopy.matchingCap,
          kind: SpaceFieldKind.money,
          initial: settings.matchingCapMinor,
          allowZero: true,
        ),
        for (final entry in const {
          'tasksEnabled': SpaceUiCopy.tasksEnabled,
          'errandsEnabled': SpaceUiCopy.errandsEnabled,
          'learningEnabled': SpaceUiCopy.learningEnabled,
          'notifications': SpaceUiCopy.notifyEnabled,
        }.entries)
          SpaceField(
            entry.key,
            entry.value,
            kind: SpaceFieldKind.toggle,
            initial: settings.toJson()[entry.key],
          ),
      ],
    );
    if (result != null) {
      await actions.run(
        _command('settings.update', childId, {'settings': result}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final policy = _policy(session, childId);
    final settings = space.settingsFor(childId);
    final enabled = _enabled(session, actions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpaceHeading(
          adult ? SpaceContent.settings : SpaceUiCopy.familyRules,
          body: adult ? SpaceUiCopy.settingsHint : SpaceUiCopy.rulesBody,
        ),
        if (policy == null)
          const SpacePanel(child: Text(SpaceControlContent.rulesUnavailable))
        else
          SpacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _policySummary(context, policy),
                const SizedBox(height: 12),
                _button(
                  adult
                      ? SpaceControlContent.editPolicy
                      : SpaceUiCopy.requestPolicy,
                  !enabled
                      ? null
                      : () async {
                          if (!adult) {
                            await _policyRequest(
                              context,
                              session,
                              actions,
                              childId,
                            );
                            return;
                          }
                          final updated = await _editPolicy(context, policy);
                          if (updated != null &&
                              context.mounted &&
                              await _confirmPolicy(context, updated)) {
                            await actions.perform(() async {
                              await _savePolicy(updated);
                            });
                          }
                        },
                ),
                if (adult) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const ValueKey('choose-policy-preset'),
                    onPressed: enabled ? () => _preset(context, policy) : null,
                    child: const Text(SpaceControlContent.chooseProfile),
                  ),
                ],
              ],
            ),
          ),
        if (settings != null)
          SpacePanel(
            cloud: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  SpaceContent.matching,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  settings.matchingEnabled
                      ? '${SpaceUiCopy.matchingPercent}: ${SpaceUiCopy.percent(settings.matchingPercent)}'
                      : SpaceContent.statusLabel('disabled'),
                ),
                const SizedBox(height: 8),
                Text(
                  '${SpaceUiCopy.matchingCap}: ${spaceMoney(settings.matchingCapMinor)}',
                ),
                const SizedBox(height: 12),
                const Text(SpaceControlContent.matchingLifetime),
                const Divider(height: 32),
                for (final entry in const {
                  'tasksEnabled': SpaceUiCopy.tasksEnabled,
                  'errandsEnabled': SpaceUiCopy.errandsEnabled,
                  'learningEnabled': SpaceUiCopy.learningEnabled,
                  'notifications': SpaceUiCopy.notifyEnabled,
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${entry.value}: ${settings.toJson()[entry.key] == true ? SpaceControlContent.allowed : SpaceControlContent.forbidden}',
                    ),
                  ),
                const Text(SpaceControlContent.notificationsPreference),
                if (adult) ...[
                  const SizedBox(height: 20),
                  _button(
                    SpaceControlContent.editSettings,
                    enabled ? () => _settings(context, settings) : null,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// A fresh dialog never preselects an answer, including a previously reviewed
/// topic. Only the server decides whether this answer completes the lesson.
Future<int?> spaceLessonAnswer(
  BuildContext context,
  SpaceLesson lesson, {
  bool readOnly = false,
}) => showDialog<int>(
  context: context,
  builder: (_) => _LessonDialog(lesson: lesson, readOnly: readOnly),
);

class _LessonDialog extends StatefulWidget {
  const _LessonDialog({required this.lesson, required this.readOnly});
  final SpaceLesson lesson;
  final bool readOnly;
  @override
  State<_LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<_LessonDialog> {
  int? _answer;
  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    title: Text(widget.lesson.title),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.lesson.body),
          const SizedBox(height: 24),
          if (widget.lesson.question == null || widget.lesson.options.isEmpty)
            const Text(SpaceControlContent.lessonQuestionUnavailable)
          else ...[
            Text(
              widget.lesson.question!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (widget.readOnly)
              const Text(SpaceControlContent.lessonReadOnly)
            else
              RadioGroup<int>(
                groupValue: _answer,
                onChanged: (value) => setState(() => _answer = value),
                child: Column(
                  children: [
                    for (var i = 0; i < widget.lesson.options.length; i++)
                      RadioListTile<int>(
                        key: ValueKey('lesson-answer-$i'),
                        value: i,
                        title: Text(widget.lesson.options[i]),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(SpaceContent.close),
      ),
      if (!widget.readOnly)
        FilledButton(
          onPressed: _answer == null
              ? null
              : () => Navigator.pop(context, _answer),
          child: const Text(SpaceUiCopy.lessonSubmit),
        ),
    ],
  );
}

class SpaceLearningSection extends StatelessWidget {
  const SpaceLearningSection({
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

  Future<void> _openLesson(BuildContext context, SpaceLesson lesson) async {
    if (!_enabled(session, actions)) return;
    final answer = await spaceLessonAnswer(context, lesson, readOnly: adult);
    if (answer != null && !adult && _enabled(session, actions)) {
      await actions.run(
        _command('lesson.complete', childId, {
          'entityId': lesson.id,
          'answerIndex': answer,
        }),
      );
    }
  }

  IconData _skillIcon(String skill) => switch (skill) {
    'saving' => Icons.savings_outlined,
    'safety' => Icons.verified_user_outlined,
    'budgeting' || 'budget' => Icons.receipt_long_outlined,
    _ => Icons.menu_book_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final lessons = space.lessons;
    final completed = lessons
        .where((lesson) => space.lessonCompleted(childId, lesson.id))
        .length;
    final pending = lessons
        .where((lesson) => !space.lessonCompleted(childId, lesson.id))
        .toList();
    final featured = pending.isEmpty ? null : pending.first;
    final remaining = lessons.where((lesson) => lesson.id != featured?.id);
    final enabled = _enabled(session, actions);
    final progress = lessons.isEmpty ? 0.0 : completed / lessons.length;
    final spacious = MediaQuery.textScalerOf(context).scale(16) > 19.2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpaceHeading(
          adult
              ? SpaceControlContent.adultLearningTitle
              : SpaceControlContent.childLearningTitle,
          body: SpaceControlContent.learningBody,
          bottomSpacing: 16,
          action: headerAction,
        ),
        if (lessons.isEmpty)
          const SpaceEmpty(
            title: SpaceContent.emptyLessons,
            body: SpaceControlContent.lessonsUnavailable,
            asset: SpaceAssets.learning,
          )
        else ...[
          SpacePanel(
            padding: 16,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: MtBrandColors.cloud,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: MtBrandColors.blue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text(
                            adult
                                ? SpaceControlContent.childProgress
                                : SpaceControlContent.yourProgress,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            SpaceControlContent.topicProgress(
                              completed,
                              lessons.length,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: MtBrandColors.secondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: MtBrandColors.border,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            SpaceControlContent.progressPercent(progress),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (featured != null)
            SpacePanel(
              cloud: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: spacious ? 4 : 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              SpaceContent.skillLabel(featured.skill),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: MtBrandColors.secondary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              featured.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: spacious ? 1 : 2,
                        child: Image.asset(
                          SpaceAssets.learning,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    featured.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MtBrandColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: ValueKey('lesson-open-${featured.id}'),
                    onPressed: enabled
                        ? () => _openLesson(context, featured)
                        : null,
                    child: Text(
                      adult
                          ? SpaceControlContent.readTopic
                          : SpaceControlContent.beginLesson,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                SpaceControlContent.allTopicsCompleted,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          if (remaining.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              featured == null
                  ? SpaceControlContent.completedTopics
                  : SpaceControlContent.otherTopics,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            for (final (index, lesson) in remaining.indexed) ...[
              if (index > 0) const Divider(height: 1),
              SpaceLink(
                dense: true,
                key: ValueKey('lesson-open-${lesson.id}'),
                title: lesson.title,
                subtitle: space.lessonCompleted(childId, lesson.id)
                    ? SpaceUiCopy.reviewed
                    : SpaceContent.skillLabel(lesson.skill),
                icon: space.lessonCompleted(childId, lesson.id)
                    ? Icons.check_circle_outline_rounded
                    : _skillIcon(lesson.skill),
                onTap: enabled ? () => _openLesson(context, lesson) : null,
              ),
            ],
          ],
        ],
      ],
    );
  }
}

class SpaceRequestsSection extends StatelessWidget {
  const SpaceRequestsSection({
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

  Future<void> _create(BuildContext context, String kind) async {
    if (kind == 'policy') {
      await _policyRequest(context, session, actions, childId);
      return;
    }
    final fields = await spaceForm(
      context,
      title: kind == 'money' ? SpaceUiCopy.askMoney : SpaceUiCopy.requestHelp,
      body: kind == 'money'
          ? SpaceUiCopy.askMoneyBody
          : SpaceUiCopy.supportBody,
      fields: [
        const SpaceField('title', SpaceContent.requestTitle),
        if (kind == 'money')
          const SpaceField(
            'amountMinor',
            SpaceContent.amount,
            kind: SpaceFieldKind.money,
          ),
      ],
      submit: SpaceContent.create,
    );
    if (fields != null) {
      await actions.run(
        _command('request.create', childId, {'kind': kind, ...fields}),
      );
    }
  }

  Future<void> _decide(
    BuildContext context,
    SpaceRequest request,
    bool approve,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          approve
              ? SpaceControlContent.requestApprove
              : SpaceControlContent.requestReject,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                request.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                !approve
                    ? SpaceControlContent.rejectRequest
                    : request.kind == 'money'
                    ? SpaceControlContent.approveMoney(
                        spaceMoney(request.amountMinor),
                      )
                    : request.kind == 'policy'
                    ? SpaceControlContent.approvePolicy
                    : SpaceControlContent.approveHelp,
              ),
              if (request.policy != null) ...[
                const SizedBox(height: 20),
                _policySummary(context, request.policy!.toJson()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(SpaceUiCopy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              approve
                  ? SpaceContent.confirm
                  : SpaceContent.actionLabel('decline'),
            ),
          ),
        ],
      ),
    );
    if (accepted == true) {
      await actions.run(
        _command('request.decide', childId, {
          'entityId': request.id,
          'approve': approve,
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = space.requestsFor(childId);
    final enabled = _enabled(session, actions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SpaceHeading(
          SpaceContent.requests,
          body: SpaceControlContent.requestsHint,
        ),
        if (!adult) ...[
          _button(
            SpaceUiCopy.askMoney,
            enabled ? () => _create(context, 'money') : null,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: enabled ? () => _create(context, 'help') : null,
            child: const Text(SpaceUiCopy.requestHelp),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: enabled && _policy(session, childId) != null
                ? () => _create(context, 'policy')
                : null,
            child: const Text(SpaceUiCopy.requestPolicy),
          ),
          const SizedBox(height: 24),
        ],
        if (requests.isEmpty)
          const SpaceEmpty(
            title: SpaceUiCopy.noRequests,
            body: SpaceControlContent.noRequestsBody,
            asset: SpaceAssets.allowance,
          ),
        for (final request in requests)
          SpacePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  request.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (request.kind == 'money') ...[
                  Text(
                    spaceMoney(request.amountMinor),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                ],
                if (request.policy != null) ...[
                  _policySummary(context, request.policy!.toJson()),
                  const SizedBox(height: 12),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: SpacePill(request.status),
                ),
                if (adult && request.status == 'pending') ...[
                  const SizedBox(height: 20),
                  _button(
                    SpaceContent.confirm,
                    enabled ? () => _decide(context, request, true) : null,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: enabled
                        ? () => _decide(context, request, false)
                        : null,
                    child: Text(SpaceContent.actionLabel('decline')),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
