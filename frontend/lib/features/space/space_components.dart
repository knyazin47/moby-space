import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/family_session.dart';
import '../../core/config/space_content.dart';
import '../../core/config/space_ui_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/server/family_api.dart';
import '../../data/server/family_space.dart';
import '../../data/server/money_intent.dart';
import '../../data/server/family_ui_contract.dart';

abstract final class SpaceAssets {
  static const goal = 'assets/brand/family-space/goal-glass.webp';
  static const reward = 'assets/brand/family-space/reward-glass.webp';
  static const allowance =
      'assets/brand/family-space/rebrand-v3/wallet-glass.png';
  static const learning =
      'assets/brand/family-space/rebrand-v3/learning-glass.png';
}

class SpaceActions {
  const SpaceActions({
    required this.busy,
    this.protectiveBusy = false,
    required this.error,
    required this.pending,
    required this.run,
    required this.perform,
    required this.retry,
  });
  final bool busy, protectiveBusy;
  final String? error;
  final PendingMoneyIntent? pending;
  final Future<bool> Function(JsonMap command) run;
  final Future<bool> Function(Future<void> Function() operation) perform;
  final Future<void> Function() retry;
}

class SpaceSessionView extends ConsumerStatefulWidget {
  const SpaceSessionView({required this.builder, super.key});
  final Widget Function(BuildContext, FamilySession, FamilySpace, SpaceActions)
  builder;
  @override
  ConsumerState<SpaceSessionView> createState() => _SpaceSessionViewState();
}

class _SpaceSessionViewState extends ConsumerState<SpaceSessionView> {
  bool _busy = false;
  bool _protectiveBusy = false;
  String? _error;
  PendingMoneyIntent? _pending;
  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    try {
      final session = ref.read(familySessionProvider);
      if (session.phase != FamilySessionPhase.signedIn) {
        if (mounted) setState(() => _pending = null);
        return;
      }
      var pending = await session.pendingSpaceCommand();
      if (pending == null && session.role == 'child' && session.child != null) {
        pending = await session.moneyIntents.load(
          childId: session.child!['id'] as String,
          kind: MoneyIntentKind.purchase,
        );
      }
      if (mounted) setState(() => _pending = pending);
    } catch (_) {
      if (mounted) setState(() => _error = SpaceUiCopy.pendingConflict);
    }
  }

  Future<bool> _perform(Future<void> Function() operation) async {
    if (_busy || _protectiveBusy) return false;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
      return true;
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PendingMoneyIntentException
              ? SpaceUiCopy.pendingConflict
              : SpaceContent.errorMessage(
                  error is FamilyApiException ? error.code : 'request_failed',
                ),
        );
      }
      return false;
    } finally {
      await _loadPending();
      if (mounted) setState(() => _busy = false);
    }
  }

  // Protective requests must not wait for an unrelated money request/retry.
  // The session persists card.block in its own idempotent durable lane.
  Future<bool> _protect(Future<void> Function() operation) async {
    if (_protectiveBusy) return false;
    setState(() {
      _protectiveBusy = true;
      _error = null;
    });
    try {
      await operation();
      return true;
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = SpaceContent.errorMessage(
            error is FamilyApiException ? error.code : 'request_failed',
          ),
        );
      }
      return false;
    } finally {
      // Do not read the unrelated locked money lane while it is in flight.
      // Its executor refreshes pending when that request completes.
      if (mounted) setState(() => _protectiveBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(familySessionProvider);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final actions = SpaceActions(
          busy: _busy || _protectiveBusy,
          protectiveBusy: _protectiveBusy,
          error: _error,
          pending: _pending,
          run: (command) {
            if (command['type'] == 'card.block') {
              return _protect(
                () => session.blockCard(command['childId'] as String),
              );
            }
            return _perform(() async {
              if (_pending != null) throw const PendingMoneyIntentException();
              await session.submitSpaceCommand(command);
            });
          },
          perform: _perform,
          retry: () async {
            await _perform(() async {
              if (_pending?.kind == MoneyIntentKind.purchase) {
                await session.moneyIntents.retry(
                  childId: _pending!.childId,
                  kind: MoneyIntentKind.purchase,
                );
              } else {
                await session.retrySpaceCommand();
              }
            });
          },
        );
        return widget.builder(
          context,
          session,
          FamilySpace.fromSnapshot(session.snapshot),
          actions,
        );
      },
    );
  }
}

class SpaceNotices extends StatelessWidget {
  const SpaceNotices({required this.session, required this.actions, super.key});
  final FamilySession session;
  final SpaceActions actions;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!session.connected)
        const SpacePanel(child: Text(SpaceUiCopy.offline)),
      if (actions.error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            actions.error!,
            style: const TextStyle(color: MtBrandColors.red),
          ),
        ),
      if (actions.pending != null)
        SpacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                SpaceUiCopy.pendingTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(SpaceUiCopy.pendingBody),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: actions.busy ? null : actions.retry,
                child: const Text(SpaceUiCopy.retryPending),
              ),
            ],
          ),
        ),
      if (actions.busy)
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: LinearProgressIndicator(),
        ),
    ],
  );
}

class SpaceBody extends StatelessWidget {
  const SpaceBody({
    required this.children,
    this.top = 24,
    this.bottom = 24,
    super.key,
  });
  final List<Widget> children;
  final double bottom, top;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: ListView(
        padding: EdgeInsets.fromLTRB(24, top, 24, bottom),
        children: children,
      ),
    ),
  );
}

class SpaceHeading extends StatelessWidget {
  const SpaceHeading(
    this.title, {
    this.body,
    this.eyebrow,
    this.action,
    this.bottomSpacing = 24,
    super.key,
  });
  final String title;
  final String? body, eyebrow;
  final double bottomSpacing;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: bottomSpacing),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: MtBrandColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
            ),
            if (action != null) ...[const SizedBox(width: 8), action!],
          ],
        ),
        if (body != null) ...[
          const SizedBox(height: 12),
          Text(
            body!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: MtBrandColors.secondary),
          ),
        ],
      ],
    ),
  );
}

class SpacePanel extends StatelessWidget {
  const SpacePanel({
    required this.child,
    this.cloud = false,
    this.padding = 20,
    super.key,
  });
  final Widget child;
  final bool cloud;
  final double padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cloud ? MtBrandColors.cloud : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cloud ? MtBrandColors.cloud : MtBrandColors.border,
        ),
      ),
      child: child,
    ),
  );
}

class SpaceHero extends StatelessWidget {
  const SpaceHero({
    required this.title,
    required this.amount,
    this.asset = SpaceAssets.allowance,
    this.details = const [],
    this.action,
    this.compact = false,
    super.key,
  });
  final String title, amount, asset;
  final List<(String, String)> details;
  final Widget? action;
  final bool compact;
  @override
  Widget build(BuildContext context) => SpacePanel(
    cloud: true,
    padding: compact ? 16 : 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        amount,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 32, color: MtBrandColors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.textScalerOf(context).scale(16) <= 18.4 &&
                  constraints.maxWidth >= 240) ...[
                const SizedBox(width: 8),
                Image.asset(
                  asset,
                  width: math.min(
                    compact ? 80 : 112,
                    constraints.maxWidth * .34,
                  ),
                  height: compact ? 72 : 128,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ],
            ],
          ),
        ),
        if (details.isNotEmpty) ...[
          Divider(height: compact ? 16 : 24),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              for (final item in details)
                if (compact)
                  Text(
                    '${item.$1}: ${item.$2}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
            ],
          ),
        ],
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

class SpaceLink extends StatelessWidget {
  const SpaceLink({
    required this.title,
    this.subtitle,
    this.icon = Icons.chevron_right_rounded,
    this.onTap,
    this.trailing,
    this.dense = false,
    super.key,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool dense;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 10 : 14),
        child: Row(
          children: [
            Container(
              width: dense ? 40 : 44,
              height: dense ? 40 : 44,
              decoration: BoxDecoration(
                color: MtBrandColors.cloud,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: MtBrandColors.blue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: MtBrandColors.secondary,
                        fontSize: dense ? 13 : 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: MtBrandColors.blue,
                ),
          ],
        ),
      ),
    ),
  );
}

class SpaceEmpty extends StatelessWidget {
  const SpaceEmpty({
    required this.title,
    required this.body,
    this.asset = SpaceAssets.reward,
    this.action,
    super.key,
  });
  final String title, body, asset;
  final Widget? action;
  @override
  Widget build(BuildContext context) => SpacePanel(
    cloud: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          asset,
          height: 144,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(body, style: const TextStyle(color: MtBrandColors.secondary)),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    ),
  );
}

class SpacePill extends StatelessWidget {
  const SpacePill(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: MtBrandColors.cloud,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      SpaceContent.statusLabel(status),
      style: const TextStyle(color: MtBrandColors.blue, fontSize: 12),
    ),
  );
}

enum SpaceFieldKind { text, money, integer, choice, toggle, date }

class SpaceField {
  const SpaceField(
    this.name,
    this.label, {
    this.kind = SpaceFieldKind.text,
    this.initial,
    this.choices = const {},
    this.allowZero = false,
    this.max = 10000000,
    this.min = 0,
    this.helper,
    this.maximumShortcut = false,
  });
  final String name, label;
  final SpaceFieldKind kind;
  final Object? initial;
  final Map<String, String> choices;
  final bool allowZero;
  final int max, min;
  final String? helper;
  final bool maximumShortcut;
}

Future<JsonMap?> spaceForm(
  BuildContext context, {
  required String title,
  String? body,
  required List<SpaceField> fields,
  String submit = SpaceUiCopy.save,
}) => showDialog<JsonMap>(
  context: context,
  builder: (context) => _SpaceFormDialog(
    title: title,
    body: body,
    fields: fields,
    submit: submit,
  ),
);

class _SpaceFormDialog extends StatefulWidget {
  const _SpaceFormDialog({
    required this.title,
    this.body,
    required this.fields,
    required this.submit,
  });
  final String title, submit;
  final String? body;
  final List<SpaceField> fields;
  @override
  State<_SpaceFormDialog> createState() => _SpaceFormDialogState();
}

class _SpaceFormDialogState extends State<_SpaceFormDialog> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _values = <String, dynamic>{};
  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      if (f.kind == SpaceFieldKind.toggle) {
        _values[f.name] = f.initial == true;
      } else if (f.kind == SpaceFieldKind.choice) {
        _values[f.name] = f.initial ?? f.choices.keys.first;
      } else {
        _controllers[f.name] = TextEditingController(
          text: f.initial == null
              ? ''
              : f.kind == SpaceFieldKind.money
              ? ((f.initial as int) / 100).toStringAsFixed(2)
              : f.initial.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: buildMtBrandTheme(),
    child: AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.body != null) ...[
                  Text(
                    widget.body!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                ],
                for (final field in widget.fields) ...[
                  _field(field),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(SpaceUiCopy.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.submit)),
      ],
    ),
  );
  Widget _field(SpaceField f) {
    if (f.kind == SpaceFieldKind.toggle) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(f.label),
        value: _values[f.name] as bool,
        onChanged: (v) => setState(() => _values[f.name] = v),
      );
    }
    if (f.kind == SpaceFieldKind.choice) {
      return DropdownButtonFormField<String>(
        initialValue: _values[f.name] as String,
        isExpanded: true,
        decoration: InputDecoration(labelText: f.label),
        items: [
          for (final e in f.choices.entries)
            DropdownMenuItem(value: e.key, child: Text(e.value, maxLines: 2)),
        ],
        onChanged: (v) => _values[f.name] = v,
      );
    }
    final numeric =
        f.kind == SpaceFieldKind.money || f.kind == SpaceFieldKind.integer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(f.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('space-field-${f.name}'),
          controller: _controllers[f.name],
          readOnly: f.kind == SpaceFieldKind.date,
          maxLength: numeric
              ? 12
              : f.kind == SpaceFieldKind.date
              ? 10
              : 100,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: numeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
              : null,
          decoration: InputDecoration(
            counterText: '',
            helperText: f.helper,
            helperMaxLines: 3,
            errorMaxLines: 3,
            suffixText: f.kind == SpaceFieldKind.money ? 'BYN' : null,
            suffixIcon: f.kind == SpaceFieldKind.date
                ? const Icon(Icons.calendar_month_outlined)
                : null,
          ),
          onTap: f.kind != SpaceFieldKind.date
              ? null
              : () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(_controllers[f.name]!.text) ?? now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 3),
                  );
                  if (d != null) {
                    _controllers[f.name]!.text =
                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  }
                },
          validator: (value) {
            final v = (value ?? '').trim();
            if (v.isEmpty) {
              return SpaceUiCopy.fieldRequired;
            }
            if (f.kind == SpaceFieldKind.date && DateTime.tryParse(v) == null) {
              return SpaceUiCopy.fieldRequired;
            }
            if (numeric) {
              final amount = f.kind == SpaceFieldKind.money
                  ? spaceParseMinor(v)
                  : int.tryParse(v);
              if (amount == null ||
                  amount < (f.allowZero ? f.min : math.max(1, f.min)) ||
                  amount > f.max) {
                return f.kind == SpaceFieldKind.money
                    ? (f.helper != null && amount != null && amount > f.max
                          ? SpaceUiCopy.amountRange(spaceMoney(f.max))
                          : SpaceUiCopy.invalidAmount)
                    : SpaceUiCopy.invalidNumber;
              }
            }
            return null;
          },
        ),
        if (f.kind == SpaceFieldKind.money && f.maximumShortcut)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: ValueKey('space-max-${f.name}'),
              onPressed: f.max <= 0
                  ? null
                  : () {
                      _controllers[f.name]!.text = (f.max / 100)
                          .toStringAsFixed(2)
                          .replaceAll('.', ',');
                    },
              child: const Text(SpaceUiCopy.maximum),
            ),
          ),
      ],
    );
  }

  void _submit() {
    if (!_form.currentState!.validate()) {
      return;
    }
    for (final f in widget.fields) {
      if (_controllers.containsKey(f.name)) {
        final text = _controllers[f.name]!.text.trim();
        _values[f.name] = switch (f.kind) {
          SpaceFieldKind.money => spaceParseMinor(text),
          SpaceFieldKind.integer => int.parse(text),
          _ => text,
        };
      }
    }
    Navigator.pop(context, Map<String, dynamic>.from(_values));
  }
}

int? spaceParseMinor(String text) {
  final value = text.replaceAll(',', '.');
  if (!RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(value)) {
    return null;
  }
  final parts = value.split('.');
  return int.parse(parts.first) * 100 +
      (parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0);
}

Future<bool> spaceConfirm(
  BuildContext context, {
  required String title,
  required String body,
  String action = SpaceUiCopy.continueLabel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: buildMtBrandTheme(),
        child: AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(SpaceUiCopy.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ),
    ) ??
    false;
String spaceMoney(int value) => formatFamilyMoney(value);

class SpaceProfileButton extends StatelessWidget {
  const SpaceProfileButton({
    required this.name,
    required this.onPressed,
    super.key,
  });
  final String name;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: SpaceContent.profile,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: MtBrandColors.cloud,
      minimumSize: const Size(48, 48),
    ),
    icon: Text(
      name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: MtBrandColors.blue,
      ),
    ),
  );
}
