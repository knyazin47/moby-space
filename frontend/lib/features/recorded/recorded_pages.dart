import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/family_session.dart';
import '../../core/config/recorded_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/native_progress.dart';
import '../../core/ui/recorded_cards.dart';
import '../../core/ui/source_assets.dart';

final _preferencesProvider = NotifierProvider<_Preferences, _PreferenceState>(
  _Preferences.new,
);

class _PreferenceState {
  const _PreferenceState({
    this.email = RecordedContent.initialEmail,
    this.biometric = RecordedContent.initialBiometric,
    this.screenshot = RecordedContent.initialScreenshot,
    this.fields = RecordedContent.profileFields,
  });
  final String email;
  final bool biometric;
  final bool screenshot;
  final List<RecordedField> fields;
}

class _Preferences extends Notifier<_PreferenceState> {
  @override
  _PreferenceState build() {
    ref.watch(demoSessionProvider);
    return const _PreferenceState();
  }

  void update({
    String? email,
    bool? biometric,
    bool? screenshot,
    List<RecordedField>? fields,
  }) {
    state = _PreferenceState(
      email: email ?? state.email,
      biometric: biometric ?? state.biometric,
      screenshot: screenshot ?? state.screenshot,
      fields: fields == null ? state.fields : List.unmodifiable(fields),
    );
  }
}

void _message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

Future<void> _notice(BuildContext context, String title, String text) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(RecordedContent.close),
          ),
        ],
      ),
    );

void _emailPage(BuildContext context) => Navigator.of(
  context,
).push<void>(MaterialPageRoute(builder: (_) => const _EmailPage()));

class RecordedSettingsPage extends ConsumerWidget {
  const RecordedSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = watchBankSnapshot(ref).profile;
    final preferences = ref.watch(_preferencesProvider);
    return MobyPage(
      title: RecordedContent.settings,
      actions: [
        IconButton(
          tooltip: RecordedContent.notifications,
          onPressed: () => context.push('/notifications'),
          icon: const SourceIcon('ic_notification_common'),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MobyColors.brand,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      profile.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    profile.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.phone,
                    style: const TextStyle(color: MobyColors.legacySecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    preferences.email,
                    style: const TextStyle(color: MobyColors.legacySecondary),
                  ),
                  SizedBox(
                    height: (constraints.maxHeight - 610).clamp(36.0, 120.0),
                  ),
                  _SettingsRow(
                    RecordedContent.transferByPhone,
                    onTap: () =>
                        context.push(RecordedContent.transferSettingsRoute),
                  ),
                  _SettingsSwitch(
                    RecordedContent.biometric,
                    value: preferences.biometric,
                    onChanged: (value) {
                      ref
                          .read(_preferencesProvider.notifier)
                          .update(biometric: value);
                      _message(context, RecordedContent.localSetting);
                    },
                  ),
                  // The requested replica is light-only, even when the system is dark.
                  _SettingsSwitch(
                    RecordedContent.darkTheme,
                    value: false,
                    onChanged: (_) =>
                        _message(context, RecordedContent.lightOnly),
                  ),
                  _SettingsRow(
                    RecordedContent.changeCode,
                    onTap: () => _notice(
                      context,
                      RecordedContent.changeCode,
                      RecordedContent.codeNotice,
                    ),
                  ),
                  _SettingsRow(
                    RecordedContent.changeEmail,
                    onTap: () => _emailPage(context),
                  ),
                  _SettingsSwitch(
                    RecordedContent.screenshot,
                    value: preferences.screenshot,
                    onChanged: (value) {
                      ref
                          .read(_preferencesProvider.notifier)
                          .update(screenshot: value);
                      _message(context, RecordedContent.localSetting);
                    },
                  ),
                  _SettingsRow(
                    RecordedContent.logout,
                    danger: true,
                    arrow: false,
                    onTap: () async {
                      final reset = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text(RecordedContent.logoutQuestion),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(RecordedContent.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(RecordedContent.logout),
                            ),
                          ],
                        ),
                      );
                      if (reset != true || !context.mounted) return;
                      if (familyApiEnabled) {
                        try {
                          await ref.read(familySessionProvider).logout();
                          if (context.mounted) context.go('/welcome');
                        } catch (_) {
                          if (context.mounted) {
                            _message(
                              context,
                              'Не удалось выйти. Проверьте соединение и повторите.',
                            );
                          }
                        }
                        return;
                      }
                      ref.read(bankRepositoryProvider).reset();
                      ref.read(demoSessionProvider.notifier).restart();
                      context.go('/home');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(
    this.label, {
    required this.onTap,
    this.danger = false,
    this.arrow = true,
  });
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool arrow;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 42),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17,
                color: danger ? MobyColors.danger : MobyColors.legacyText,
              ),
            ),
          ),
          if (arrow) const SourceIcon('ic_arrow_right', size: 16),
        ],
      ),
    ),
  );
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch(
    this.label, {
    required this.value,
    required this.onChanged,
    this.compact = false,
  });
  final String label;
  final bool compact;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
    children: [
      if (!compact)
        Expanded(child: Text(label, style: const TextStyle(fontSize: 17))),
      SizedBox(
        height: 42,
        child: Transform.scale(
          scale: .8,
          alignment: Alignment.centerRight,
          child: Theme(
            data: ThemeData(
              useMaterial3: false,
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: MobyColors.brand,
              activeTrackColor: MobyColors.brand.withValues(alpha: .25),
              inactiveThumbColor: const Color(0xFFFAF9FD),
              inactiveTrackColor: const Color(0xFFE1E0EB),
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

ButtonStyle _recordedButtonStyle({double height = 44}) =>
    FilledButton.styleFrom(
      minimumSize: Size.fromHeight(height),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );

class _RecordedHint extends StatelessWidget {
  const _RecordedHint(this.text, {this.radius = 4});
  final String text;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F3FD),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        height: 1.25,
        fontWeight: FontWeight.w500,
        color: MobyColors.legacySecondary,
      ),
    ),
  );
}

class _EmailPage extends ConsumerStatefulWidget {
  const _EmailPage();
  @override
  ConsumerState<_EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<_EmailPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email;
  @override
  void initState() {
    super.initState();
    final saved = ref.read(_preferencesProvider).email;
    _email = TextEditingController(
      text: saved == RecordedContent.initialEmail ? '' : saved,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: RecordedContent.emailTitle,
    child: Form(
      key: _form,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const _RecordedHint(RecordedContent.emailInfo),
                const SizedBox(height: 24),
                const Text(
                  RecordedContent.email,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const ValueKey('recorded-email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: RecordedContent.emailPlaceholder,
                    constraints: BoxConstraints(minHeight: 44),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                  validator: (value) =>
                      RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(value?.trim() ?? '')
                      ? null
                      : RecordedContent.emailInvalid,
                ),
                const SizedBox(height: 8),
                const Text(
                  RecordedContent.emailHint,
                  style: TextStyle(
                    fontSize: 13,
                    color: MobyColors.legacySecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              style: _recordedButtonStyle().copyWith(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.disabled)
                      ? const Color(0xFFECEBF3)
                      : MobyColors.brand,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.disabled)
                      ? const Color(0xFFB8B9C7)
                      : Colors.white,
                ),
              ),
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                ref
                    .read(_preferencesProvider.notifier)
                    .update(email: _email.text.trim());
                _message(context, RecordedContent.emailSaved);
                Navigator.pop(context);
              },
              child: const Text(RecordedContent.save),
            ),
          ),
        ],
      ),
    ),
  );
}

class RecordedProfilePage extends ConsumerWidget {
  const RecordedProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = watchBankSnapshot(ref).profile;
    final fields = ref.watch(_preferencesProvider).fields;
    return MobyPage(
      title: RecordedContent.profile,
      child: _RecordedLoading(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ProfileField(RecordedContent.fullName, profile.fullName),
                  _ProfileField(fields[0].label, fields[0].value),
                  _ProfileField(RecordedContent.phone, profile.phone),
                  for (final field in fields.skip(1))
                    _ProfileField(field.label, field.value),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                style: _recordedButtonStyle(height: 48),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const _ProfileEditPage()),
                ),
                child: const Text(RecordedContent.update),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 17)),
      ],
    ),
  );
}

class _ProfileEditPage extends ConsumerStatefulWidget {
  const _ProfileEditPage();
  @override
  ConsumerState<_ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<_ProfileEditPage> {
  late final List<TextEditingController> _controllers;
  @override
  void initState() {
    super.initState();
    _controllers = [
      for (final field in ref.read(_preferencesProvider).fields)
        TextEditingController(text: field.value),
    ];
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: RecordedContent.update,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(RecordedContent.localSetting),
        const SizedBox(height: 24),
        for (var i = 0; i < _controllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextField(
              controller: _controllers[i],
              maxLines: null,
              decoration: InputDecoration(
                labelText: RecordedContent.profileFields[i].label,
              ),
            ),
          ),
        FilledButton(
          onPressed: () {
            ref
                .read(_preferencesProvider.notifier)
                .update(
                  fields: [
                    for (var i = 0; i < _controllers.length; i++)
                      RecordedField(
                        RecordedContent.profileFields[i].label,
                        _controllers[i].text.trim().isEmpty
                            ? RecordedContent.profileFields[i].value
                            : _controllers[i].text.trim(),
                      ),
                  ],
                );
            Navigator.pop(context);
          },
          child: const Text(RecordedContent.save),
        ),
      ],
    ),
  );
}

class RecordedDocumentsPage extends StatelessWidget {
  const RecordedDocumentsPage({super.key});
  @override
  Widget build(BuildContext context) => const MobyPage(
    title: RecordedContent.documents,
    child: _RecordedLoading(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SourceIcon(
              'ic_crossed_agreements',
              size: 48,
              color: MobyColors.legacySecondary,
            ),
            SizedBox(height: 16),
            Text(
              RecordedContent.noDocuments,
              style: TextStyle(fontSize: 17, color: MobyColors.legacySecondary),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The recording shows a single notification card, not a tabbed inbox.
class RecordedNotificationsPage extends StatelessWidget {
  const RecordedNotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    const notice = RecordedContent.demoNotice;
    return MobyPage(
      title: RecordedContent.notifications,
      child: _RecordedLoading(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: MobyColors.rowBorder),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _notice(context, notice.title, notice.body),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        notice.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        notice.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: MobyColors.legacySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordedCurrencyPage extends StatefulWidget {
  const RecordedCurrencyPage({super.key});
  @override
  State<RecordedCurrencyPage> createState() => _RecordedCurrencyPageState();
}

class _RecordedCurrencyPageState extends State<RecordedCurrencyPage> {
  var _tab = 0;
  var _conversion = false;
  var _loading = false;
  var _buyCode = RecordedContent.initialBuyCurrency;
  var _sellCode = RecordedContent.initialSellCurrency;
  final _amount = TextEditingController(
    text: RecordedContent.initialConversionAmount,
  );
  final _tabKeys = List.generate(
    RecordedContent.tabs.length,
    (_) => GlobalKey(),
  );
  final _visible = <String>{
    for (final rate in RecordedContent.rates) rate.code,
  };
  Timer? _timer;
  late final TapGestureRecognizer _ratesLink;
  @override
  void initState() {
    super.initState();
    _ratesLink = TapGestureRecognizer()
      ..onTap = () => _notice(
        context,
        RecordedContent.ratesSiteLabel,
        RecordedContent.ratesSiteNotice,
      );
  }

  @override
  void dispose() {
    _ratesLink.dispose();
    _timer?.cancel();
    _amount.dispose();
    super.dispose();
  }

  void _selectTab(int value) {
    if (_tab == value) return;
    _timer?.cancel();
    setState(() {
      _tab = value;
      _loading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final selectedContext = _tabKeys[value].currentContext;
      if (selectedContext != null) {
        Scrollable.ensureVisible(
          selectedContext,
          alignment: .5,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
    _timer = Timer(RecordedContent.loadingDuration, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  double _price(String code) {
    if (code == 'BYN') return 1;
    final rate = RecordedContent.rates.firstWhere((rate) => rate.code == code);
    return rate.central / rate.units;
  }

  String get _converted {
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (amount == null ||
        !amount.isFinite ||
        amount < 0 ||
        amount > RecordedContent.maximumAmount) {
      return '';
    }
    return (amount * _price(_buyCode) / _price(_sellCode)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final kind = RecordedContent.tabs[_tab].kind;
    return MobyPage(
      title: RecordedContent.currency,
      child: Column(
        children: [
          const SizedBox(height: 13),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (var i = 0; i < RecordedContent.tabs.length; i++)
                  InkWell(
                    key: _tabKeys[i],
                    onTap: () => _selectTab(i),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _tab == i
                                ? MobyColors.danger
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      child: Text(
                        RecordedContent.tabs[i].label,
                        style: TextStyle(
                          fontSize: 20,
                          color: _tab == i
                              ? MobyColors.legacyText
                              : MobyColors.legacySecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: NativeProgress())
                : ListView(
                    children: [
                      if (kind == RecordedCurrencyKind.exchange)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                selectedColor: MobyColors.brand,
                                backgroundColor: const Color(0xFFEFF5FB),
                                side: BorderSide.none,
                                shape: const StadiumBorder(),
                                visualDensity: VisualDensity.compact,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: !_conversion
                                      ? Colors.white
                                      : MobyColors.brand,
                                ),
                                label: const Text(RecordedContent.exchange),
                                selected: !_conversion,
                                onSelected: (_) =>
                                    setState(() => _conversion = false),
                                showCheckmark: false,
                              ),
                              ChoiceChip(
                                selectedColor: MobyColors.brand,
                                backgroundColor: const Color(0xFFEFF5FB),
                                side: BorderSide.none,
                                shape: const StadiumBorder(),
                                visualDensity: VisualDensity.compact,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: _conversion
                                      ? Colors.white
                                      : MobyColors.brand,
                                ),
                                label: const Text(RecordedContent.conversion),
                                selected: _conversion,
                                onSelected: (_) =>
                                    setState(() => _conversion = true),
                                showCheckmark: false,
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: kind == RecordedCurrencyKind.exchange ? 6 : 16,
                      ),
                      Container(
                        color: const Color(0xFFF4F3FD),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  flex: 4,
                                  child: Text(
                                    RecordedContent.currencyLabel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: MobyColors.legacySecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    kind == RecordedCurrencyKind.centralBank
                                        ? RecordedContent.demoRate
                                        : RecordedContent.buy,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: MobyColors.legacySecondary,
                                    ),
                                  ),
                                ),
                                if (kind != RecordedCurrencyKind.centralBank)
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      RecordedContent.sell,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: MobyColors.legacySecondary,
                                      ),
                                    ),
                                  ),
                                if (kind == RecordedCurrencyKind.centralBank)
                                  const Expanded(flex: 3, child: SizedBox()),
                              ],
                            ),
                            for (final rate in RecordedContent.rates.where(
                              (rate) =>
                                  kind != RecordedCurrencyKind.centralBank ||
                                  _visible.contains(rate.code),
                            ))
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 48.3,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Row(
                                          children: [
                                            if (rate.asset != null)
                                              SourceIcon(rate.asset!, size: 24)
                                            else
                                              const SizedBox(width: 24),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                '${rate.units} ${rate.code}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${(kind == RecordedCurrencyKind.centralBank ? rate.central : rate.buy).toStringAsFixed(4)} BYN',
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (kind !=
                                          RecordedCurrencyKind.centralBank)
                                        Expanded(
                                          flex: 3,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '${rate.sell.toStringAsFixed(4)} BYN',
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (kind ==
                                          RecordedCurrencyKind.centralBank)
                                        const Expanded(
                                          flex: 3,
                                          child: SizedBox(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (kind == RecordedCurrencyKind.centralBank)
                              TextButton(
                                onPressed: _selectCurrencies,
                                child: const Text(
                                  RecordedContent.chooseCurrencies,
                                ),
                              ),
                            if (kind != RecordedCurrencyKind.centralBank)
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text(
                                    RecordedContent.demoRates,
                                    style: TextStyle(
                                      color: MobyColors.legacySecondary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (kind == RecordedCurrencyKind.exchange)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: RecordedContent.ratesInfo),
                                TextSpan(
                                  text: RecordedContent.ratesSiteLabel,
                                  style: const TextStyle(
                                    color: MobyColors.brand,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _ratesLink,
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: MobyColors.legacySecondary,
                            ),
                          ),
                        ),
                      if (kind == RecordedCurrencyKind.bank ||
                          _conversion && kind == RecordedCurrencyKind.exchange)
                        _converter(),
                    ],
                  ),
          ),
          if (!_loading && kind == RecordedCurrencyKind.exchange)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                style: _recordedButtonStyle(height: 48),
                onPressed: () => _notice(
                  context,
                  RecordedContent.exchangeAction,
                  RecordedContent.exchangeNotice,
                ),
                child: const Text(RecordedContent.exchangeAction),
              ),
            ),
        ],
      ),
    );
  }

  Widget _converter() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(RecordedContent.converter, style: TextStyle(fontSize: 20)),
        const SizedBox(height: 14),
        const Text(
          RecordedContent.buying,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('recorded-currency-amount'),
                controller: _amount,
                style: const TextStyle(
                  fontSize: 15,
                  color: MobyColors.legacySecondary,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  constraints: const BoxConstraints(minHeight: 44),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  errorMaxLines: 3,
                  errorText: _amount.text.isNotEmpty && _converted.isEmpty
                      ? RecordedContent.amountInvalid
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            _currencySelector(
              _buyCode,
              (value) => setState(() => _buyCode = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          RecordedContent.selling,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(
                  isDense: true,
                  constraints: BoxConstraints(minHeight: 44),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                child: Text(
                  _converted.isEmpty ? RecordedContent.zeroAmount : _converted,
                  style: const TextStyle(
                    fontSize: 15,
                    color: MobyColors.legacySecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _currencySelector(
              _sellCode,
              (value) => setState(() => _sellCode = value),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _currencySelector(String code, ValueChanged<String> changed) =>
      Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.only(left: 16, right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: MobyColors.rowBorder),
          borderRadius: BorderRadius.circular(24),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: code,
            isDense: true,
            icon: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SourceIcon('ic_currency_spinner_arrow_down', size: 12),
            ),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: MobyColors.legacyText,
            ),
            items: [
              for (final item in RecordedContent.converterCurrencies)
                DropdownMenuItem(value: item, child: Text(item)),
            ],
            onChanged: (value) {
              if (value != null) changed(value);
            },
          ),
        ),
      );
  void _selectCurrencies() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final rate in RecordedContent.rates)
              CheckboxListTile(
                title: Text(rate.code),
                value: _visible.contains(rate.code),
                onChanged: (selected) {
                  if (selected == false && _visible.length == 1) return;
                  setState(() {
                    if (selected == true) {
                      _visible.add(rate.code);
                    } else {
                      _visible.remove(rate.code);
                    }
                  });
                  setSheetState(() {});
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class RecordedAboutPage extends StatelessWidget {
  const RecordedAboutPage({super.key});
  @override
  Widget build(BuildContext context) => MobyPage(
    title: RecordedContent.about,
    child: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                RecordedContent.bankName,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(RecordedContent.bankAddress),
              const SizedBox(height: 16),
              const Text(RecordedContent.bankRequisites),
              const SizedBox(height: 16),
              for (final contact in RecordedContent.bankContacts)
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: contact.value));
                    if (context.mounted) {
                      _message(context, RecordedContent.copied);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: contact == RecordedContent.bankContacts.first
                          ? 16
                          : 0,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${contact.label} '),
                          TextSpan(
                            text: contact.value,
                            style: const TextStyle(color: MobyColors.brand),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (final title in [RecordedContent.offer, RecordedContent.privacy])
          InkWell(
            onTap: () => _notice(
              context,
              RecordedContent.localDocumentTitle,
              RecordedContent.localDocumentBody,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(child: Text(title)),
                  const SourceIcon('ic_arrow_right', size: 16),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

class RecordedTransferSettingsPage extends ConsumerStatefulWidget {
  const RecordedTransferSettingsPage({super.key});
  @override
  ConsumerState<RecordedTransferSettingsPage> createState() =>
      _RecordedTransferSettingsState();
}

class _RecordedTransferSettingsState
    extends ConsumerState<RecordedTransferSettingsPage> {
  Timer? _timer;
  bool _loading = false;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _open(String method) {
    if (_loading) return;
    final saved = ref.read(_transferPreferencesProvider)[method];
    if (method != 'ips' || saved == null || saved.loaded) {
      context.push('/settings/transfer/$method');
      return;
    }
    // The observed request overlays the parent menu, before the IPS route opens.
    setState(() => _loading = true);
    _timer = Timer(RecordedContent.ipsParentLoadingDuration, () {
      if (!mounted) return;
      ref
          .read(_transferPreferencesProvider.notifier)
          .save(
            method,
            _TransferPreference(
              enabled: saved.enabled,
              card: saved.card,
              agreement: saved.agreement,
              loaded: true,
              introPending: true,
            ),
          );
      setState(() => _loading = false);
      context.push('/settings/transfer/$method');
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      MobyPage(
        title: RecordedContent.transferByPhone,
        titleMaxLines: 2,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final method in RecordedContent.transferMethods.where(
              (method) => method.id == 'moby' || method.id == 'ips',
            ))
              _TransferSettingsRow(method.title, onTap: () => _open(method.id)),
            _TransferSettingsRow(
              RecordedContent.eripTitle,
              onTap: () => _open('erip'),
            ),
            _TransferSettingsRow(
              RecordedContent.transferMethods.last.title,
              onTap: () => _open('visa'),
            ),
          ],
        ),
      ),
      if (_loading)
        const Positioned.fill(
          child: AbsorbPointer(
            child: ColoredBox(
              color: Color(0x55FFFFFF),
              child: Center(
                key: ValueKey('recorded-ips-parent-loading'),
                child: NativeProgress(),
              ),
            ),
          ),
        ),
    ],
  );
}

class _TransferSettingsRow extends StatelessWidget {
  const _TransferSettingsRow(this.title, {required this.onTap});
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: _SettingsRow(title, onTap: onTap),
  );
}

class _TransferPreference {
  const _TransferPreference({
    required this.enabled,
    this.card = 0,
    this.agreement = false,
    this.loaded = false,
    this.introPending = false,
  });
  final bool enabled;
  final int card;
  final bool agreement;
  final bool loaded;
  final bool introPending;
}

final _transferPreferencesProvider =
    NotifierProvider<_TransferPreferences, Map<String, _TransferPreference>>(
      _TransferPreferences.new,
    );

class _TransferPreferences extends Notifier<Map<String, _TransferPreference>> {
  @override
  Map<String, _TransferPreference> build() {
    ref.watch(demoSessionProvider);
    return Map.unmodifiable({
      for (final method in RecordedContent.transferMethods)
        method.id: _TransferPreference(enabled: method.alwaysEnabled),
    });
  }

  void save(String method, _TransferPreference value) {
    state = Map.unmodifiable({...state, method: value});
  }
}

/// Local settings simulation. No bank binding, consent submission or device API.
class RecordedTransferMethodPage extends ConsumerStatefulWidget {
  const RecordedTransferMethodPage({super.key, required this.method});
  final String method;
  @override
  ConsumerState<RecordedTransferMethodPage> createState() =>
      _RecordedTransferMethodPageState();
}

class _RecordedTransferMethodPageState
    extends ConsumerState<RecordedTransferMethodPage> {
  Timer? _timer;
  bool _loading = false;
  bool _ipsIntro = false;
  bool _enabled = false;
  bool _agreement = false;
  int _selectedCard = 0;
  _TransferPreference? _saved;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RecordedTransferMethodPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.method != widget.method) _load();
  }

  void _load() {
    _timer?.cancel();
    final saved = ref.read(_transferPreferencesProvider)[widget.method];
    _saved = saved;
    _enabled = saved?.enabled ?? false;
    _agreement = saved?.agreement ?? false;
    _selectedCard = saved?.card ?? 0;
    _loading = saved != null && !saved.loaded;
    _ipsIntro = widget.method == 'ips' && (saved?.introPending ?? false);
    if (_ipsIntro) _finishIntro();
    if (_loading) {
      _timer = Timer(RecordedContent.loadingDuration, () {
        if (!mounted) return;
        final value = _TransferPreference(
          enabled: saved!.enabled,
          agreement: saved.agreement,
          card: saved.card,
          loaded: true,
        );
        ref
            .read(_transferPreferencesProvider.notifier)
            .save(widget.method, value);
        setState(() {
          _saved = value;
          _loading = false;
        });
      });
    }
  }

  void _finishIntro() {
    _timer = Timer(RecordedContent.ipsTransientDuration, () {
      if (!mounted) return;
      final value = _TransferPreference(
        enabled: _enabled,
        agreement: _agreement,
        card: _selectedCard,
        loaded: true,
      );
      ref
          .read(_transferPreferencesProvider.notifier)
          .save(widget.method, value);
      setState(() {
        _ipsIntro = false;
        _saved = value;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _save() {
    final saved = _TransferPreference(
      enabled: _enabled,
      agreement: _agreement,
      card: _selectedCard,
      loaded: true,
    );
    ref.read(_transferPreferencesProvider.notifier).save(widget.method, saved);
    setState(() => _saved = saved);
    _message(context, RecordedContent.transferLocalSaved);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.method == 'erip') {
      return MobyPage(
        title: RecordedContent.eripTitle,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final method in RecordedContent.transferMethods.where(
              (method) => method.id.startsWith('erip-'),
            ))
              _TransferSettingsRow(
                method.title,
                onTap: () => context.push('/settings/transfer/${method.id}'),
              ),
          ],
        ),
      );
    }
    final methods = RecordedContent.transferMethods.where(
      (method) => method.id == widget.method,
    );
    if (methods.isEmpty) return const RecordedTransferSettingsPage();
    final method = methods.first;
    final snapshot = watchBankSnapshot(ref);
    final cards = snapshot.cards;
    final cardIndex = cards.isEmpty
        ? 0
        : _selectedCard.clamp(0, cards.length - 1);
    final changed =
        _saved?.enabled != _enabled ||
        _saved?.agreement != _agreement ||
        _saved?.card != cardIndex;
    final canSave =
        !_loading &&
        !_ipsIntro &&
        changed &&
        (!_enabled ||
            cards.isNotEmpty && (!method.requiresConsent || _agreement));
    final showProduct = _enabled || _ipsIntro;
    final consent = method.id == 'ips'
        ? RecordedContent.ipsConsent
        : RecordedContent.transferConsent;

    Widget consentRow() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _notice(
                context,
                RecordedContent.localDocumentTitle,
                RecordedContent.localDocumentBody,
              ),
              child: Text(
                consent,
                style: const TextStyle(
                  fontSize: 13,
                  color: MobyColors.legacySecondary,
                  height: 1.25,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SettingsSwitch(
            '',
            value: _ipsIntro || _agreement,
            onChanged: (value) => setState(() => _agreement = value),
            compact: true,
          ),
        ],
      ),
    );

    Widget product() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (method.id.startsWith('erip-') || method.id == 'visa')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ProfileField(RecordedContent.phone, snapshot.profile.phone),
          ),
        if (method.id == 'visa')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ProfileField(
              RecordedContent.visaNickname,
              snapshot.profile.firstName,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            method.id == 'ips'
                ? RecordedContent.transferProduct
                : RecordedContent.cardForTransfer,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          SizedBox(
            height: (MediaQuery.sizeOf(context).width - 40) / 2 + 36,
            child: const Center(child: NativeProgress()),
          )
        else if (cards.isNotEmpty)
          RecordedOwnCardPager(
            snapshot: snapshot,
            selectedAccountId: cards[cardIndex].accountId,
            onSelected: (id) => setState(
              () => _selectedCard = cards.indexWhere(
                (card) => card.accountId == id,
              ),
            ),
            onOpenPicker: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (sheetContext) => SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (var index = 0; index < cards.length; index++)
                      ListTile(
                        title: Text(cards[index].title),
                        subtitle: Text(cards[index].maskedNumber),
                        selected: index == cardIndex,
                        onTap: () {
                          setState(() => _selectedCard = index);
                          Navigator.pop(sheetContext);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (method.requiresConsent && method.id != 'ips') consentRow(),
      ],
    );

    // Visa's source loading screen covers the toolbar as well as the body.
    if (_loading && method.id == 'visa') {
      return const Scaffold(body: Center(child: NativeProgress()));
    }
    return MobyPage(
      title: method.title,
      titleMaxLines: method.id == 'erip-account' ? 2 : 1,
      actions: [
        if (method.id.startsWith('erip-'))
          IconButton(
            onPressed: () => _notice(context, method.title, method.description),
            icon: const SourceIcon('ic_info'),
          ),
      ],
      child: _loading && !method.alwaysEnabled
          ? const Center(child: NativeProgress())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: method.id == 'ips' ? 0 : 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _RecordedHint(
                          method.description,
                          radius: method.id.startsWith('erip-') ? 16 : 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!method.alwaysEnabled)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _SettingsSwitch(
                            method.switchLabel,
                            value: _enabled,
                            onChanged: (value) =>
                                setState(() => _enabled = value),
                          ),
                        ),
                      if (showProduct) ...[
                        if (!method.alwaysEnabled) const SizedBox(height: 24),
                        IgnorePointer(
                          ignoring: _ipsIntro,
                          child: Opacity(
                            opacity: _ipsIntro ? .45 : 1,
                            child: product(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showProduct && method.id == 'ips')
                  IgnorePointer(
                    ignoring: _ipsIntro,
                    child: Opacity(
                      opacity: _ipsIntro ? .45 : 1,
                      child: consentRow(),
                    ),
                  ),
                if (showProduct || changed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: IgnorePointer(
                      ignoring: _ipsIntro,
                      child: Opacity(
                        opacity: _ipsIntro ? .6 : 1,
                        child: FilledButton(
                          style: _recordedButtonStyle(),
                          onPressed: canSave || _ipsIntro ? _save : null,
                          child: const Text(RecordedContent.save),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// The source shows a body loader before these three result screens.
/// Delay is a central, deterministic demo setting; no request is performed.
class _RecordedLoading extends StatefulWidget {
  const _RecordedLoading({required this.child});
  final Widget child;
  @override
  State<_RecordedLoading> createState() => _RecordedLoadingState();
}

class _RecordedLoadingState extends State<_RecordedLoading> {
  late final Timer _timer;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _timer = Timer(RecordedContent.loadingDuration, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _loading ? const Center(child: NativeProgress()) : widget.child;
}
