import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/recorded_forms_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/native_progress.dart';
import '../../core/ui/source_assets.dart';

class RecordedSalaryFormPage extends StatefulWidget {
  const RecordedSalaryFormPage({super.key, this.onContinue, this.onScanQr});
  final VoidCallback? onContinue;
  final VoidCallback? onScanQr;

  @override
  State<RecordedSalaryFormPage> createState() => _RecordedSalaryFormPageState();
}

class _RecordedSalaryFormPageState extends State<RecordedSalaryFormPage> {
  String? _employer;

  @override
  Widget build(BuildContext context) => MobyPage(
    title: RecordedFormsContent.salaryTitle,
    titleMaxLines: 2,
    actions: [
      IconButton(
        tooltip: RecordedFormsContent.scanQr,
        onPressed: widget.onScanQr,
        icon: const SourceIcon('ic_qr_code_scan', color: MobyColors.brand),
      ),
    ],
    child: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  RecordedFormsContent.salaryDescription,
                  style: TextStyle(
                    fontSize: 15,
                    color: MobyColors.legacySecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel(RecordedFormsContent.employerLabel),
              const SizedBox(height: 8),
              Material(
                color: MobyColors.surface,
                shape: const StadiumBorder(
                  side: BorderSide(color: MobyColors.rowBorder),
                ),
                child: InkWell(
                  key: const ValueKey('recorded-employer-select'),
                  customBorder: const StadiumBorder(),
                  onTap: _chooseEmployer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _employer ?? RecordedFormsContent.employerHint,
                            style: TextStyle(
                              fontSize: 15,
                              color: _employer == null
                                  ? MobyColors.legacySecondary
                                  : MobyColors.legacyText,
                            ),
                          ),
                        ),
                        const SourceIcon('ic_arrow_right', size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                RecordedFormsContent.salaryConsent,
                style: TextStyle(
                  fontSize: 12,
                  color: MobyColors.legacySecondary,
                ),
              ),
            ],
          ),
        ),
        _BottomNext(onPressed: _employer == null ? null : widget.onContinue),
      ],
    ),
  );

  Future<void> _chooseEmployer() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: MobyColors.surface,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            for (final employer in RecordedFormsContent.employers)
              ListTile(
                title: Text(employer),
                onTap: () => Navigator.of(sheetContext).pop(employer),
              ),
          ],
        ),
      ),
    );
    if (mounted && selected != null) setState(() => _employer = selected);
  }
}

class RecordedCreditFormPage extends StatefulWidget {
  const RecordedCreditFormPage({super.key, this.onContinue});
  final VoidCallback? onContinue;

  @override
  State<RecordedCreditFormPage> createState() => _RecordedCreditFormPageState();
}

class _RecordedCreditFormPageState extends State<RecordedCreditFormPage> {
  final _amount = TextEditingController(
    text: RecordedFormsContent.initialAmount,
  );
  final _term = TextEditingController(text: RecordedFormsContent.initialTerm);
  Timer? _calculation;
  double? _monthlyPayment;

  @override
  void initState() {
    super.initState();
    _amount.addListener(_scheduleCalculation);
    _term.addListener(_scheduleCalculation);
    _scheduleCalculation();
  }

  void _scheduleCalculation() {
    _calculation?.cancel();
    if (_monthlyPayment != null) setState(() => _monthlyPayment = null);
    _calculation = Timer(RecordedFormsContent.calculationDelay, () {
      if (!mounted) return;
      final amount = double.tryParse(
        _amount.text.replaceAll(' ', '').replaceAll(',', '.'),
      );
      final term = int.tryParse(_term.text.trim());
      if (amount == null ||
          !amount.isFinite ||
          amount < RecordedFormsContent.minimumAmount ||
          amount > RecordedFormsContent.maximumAmount ||
          term == null ||
          term < RecordedFormsContent.minimumTerm ||
          term > RecordedFormsContent.maximumTerm) {
        return;
      }
      final rate = RecordedFormsContent.illustrativeAnnualRate / 1200;
      final factor = math.pow(1 + rate, term).toDouble();
      setState(() => _monthlyPayment = amount * rate * factor / (factor - 1));
    });
  }

  @override
  void dispose() {
    _calculation?.cancel();
    _amount.dispose();
    _term.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: RecordedFormsContent.creditTitle,
    child: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                RecordedFormsContent.creditName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _RecordedInput(
                controller: _amount,
                label: RecordedFormsContent.amountLabel,
                hint: RecordedFormsContent.amountHint,
                helper: RecordedFormsContent.amountRange,
                inputKey: 'recorded-credit-amount',
                decimal: true,
              ),
              const SizedBox(height: 14),
              _RecordedInput(
                controller: _term,
                label: RecordedFormsContent.termLabel,
                hint: RecordedFormsContent.termHint,
                helper: RecordedFormsContent.termRange,
                inputKey: 'recorded-credit-term',
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: MobyColors.rowBorder),
              const SizedBox(height: 16),
              _CalculatedValue(
                title: RecordedFormsContent.monthlyPayment,
                value: _monthlyPayment == null
                    ? null
                    : '${_monthlyPayment!.toStringAsFixed(2)} ${RecordedFormsContent.currency}',
              ),
              const SizedBox(height: 14),
              _CalculatedValue(
                title: RecordedFormsContent.rateLabel,
                value: _monthlyPayment == null
                    ? null
                    : '${RecordedFormsContent.illustrativeAnnualRate.toStringAsFixed(2)}${RecordedFormsContent.annualRateSuffix}',
              ),
            ],
          ),
        ),
        _BottomNext(
          onPressed: _monthlyPayment == null ? null : widget.onContinue,
        ),
      ],
    ),
  );
}

class RecordedTransferChooserPage extends StatelessWidget {
  const RecordedTransferChooserPage({super.key});

  @override
  Widget build(BuildContext context) => MobyPage(
    title: RecordedFormsContent.transferTitle,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        for (final item in RecordedFormsContent.transferItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _ActionRow(
              item: item,
              onTap: () => context.push(item.route),
            ),
          ),
      ],
    ),
  );
}

Future<void> showRecordedTransferSheet(BuildContext context) =>
    _showActionSheet(
      context,
      RecordedFormsContent.transferTitle,
      RecordedFormsContent.transferItems,
    );

Future<void> showRecordedPaymentSheet(BuildContext context) => _showActionSheet(
  context,
  RecordedFormsContent.paymentTitle,
  RecordedFormsContent.paymentItems,
);

Future<void> _showActionSheet(
  BuildContext context,
  String title,
  List<RecordedActionItem> items,
) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: MobyColors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (sheetContext) => SafeArea(
    top: false,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheetContext).height * .88,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: MobyColors.navBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const SizedBox(height: 32),
            _ActionRow(
              item: items[index],
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push(items[index].route);
              },
            ),
          ],
        ],
      ),
    ),
  ),
);

// Local fixture access belongs to this demo session, not the device phonebook.
// Route removal retains the grant; demo reset replaces this store and surface.
final _contactsSessionProvider = Provider<_ContactsSession>((ref) {
  ref.watch(demoSessionProvider);
  return _ContactsSession();
});

class _ContactsSession {
  bool granted = false;
}

class RecordedPhoneContactsPage extends ConsumerWidget {
  const RecordedPhoneContactsPage({super.key, this.initiallyLoaded = false});
  final bool initiallyLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(_contactsSessionProvider);
    return _RecordedContactsSurface(
      key: ObjectKey(session),
      session: session,
      initiallyLoaded: initiallyLoaded,
    );
  }
}

class _RecordedContactsSurface extends StatefulWidget {
  const _RecordedContactsSurface({
    super.key,
    required this.session,
    required this.initiallyLoaded,
  });
  final _ContactsSession session;
  final bool initiallyLoaded;

  @override
  State<_RecordedContactsSurface> createState() =>
      _RecordedPhoneContactsPageState();
}

class _RecordedPhoneContactsPageState extends State<_RecordedContactsSurface> {
  late bool _loaded = widget.initiallyLoaded;
  bool _loading = false;
  bool _requestingAccess = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initiallyLoaded) widget.session.granted = true;
    if (widget.session.granted && !_loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadContacts());
      });
    }
  }

  Future<void> _loadContacts() async {
    if (_loading || _requestingAccess) return;
    if (!widget.session.granted) {
      _requestingAccess = true;
      final granted = await _showContactsRationale();
      _requestingAccess = false;
      if (!mounted || granted != true) return;
      // This grants access to invented fixtures only. No platform channel or
      // READ_CONTACTS request is made, and no OS dialog is reproduced.
      widget.session.granted = true;
    }
    if (!mounted) return;
    setState(() => _loading = true);
    await Future<void>.delayed(RecordedFormsContent.contactsDelay);
    if (mounted) {
      setState(() {
        _loading = false;
        _loaded = true;
      });
    }
  }

  // ChooseContactFragment uses ActionDialogHelper.showMessageDialog: a plain
  // app-owned Material alert with radius 4, title/message and text actions.
  Future<bool?> _showContactsRationale() => showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      key: const ValueKey('recorded-contacts-rationale'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      backgroundColor: MobyColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(
              RecordedFormsContent.contactsRationaleTitle,
              style: TextStyle(
                fontSize: 17,
                height: 1.18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text(
              RecordedFormsContent.contactsRationaleDescription,
              style: TextStyle(
                fontSize: 13,
                height: 1.25,
                color: Color(0xFF8A98AA),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: const ValueKey('recorded-contacts-cancel'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(RecordedFormsContent.cancel.toUpperCase()),
                ),
                TextButton(
                  key: const ValueKey('recorded-contacts-continue'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(
                    RecordedFormsContent.contactsRationaleContinue
                        .toUpperCase(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final contacts = RecordedFormsContent.contacts
        .where(
          (contact) => '${contact.name} ${contact.maskedPhone}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    return MobyPage(
      title: RecordedFormsContent.contactsTitle,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: TextField(
              key: const ValueKey('recorded-contact-search'),
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: RecordedFormsContent.contactsSearch,
                isDense: true,
                constraints: const BoxConstraints(minHeight: 44),
                prefixIconConstraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                filled: true,
                fillColor: const Color(0xFFEFF5FD),
                prefixIcon: const SourceIcon('ic_search', size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintStyle: const TextStyle(color: MobyColors.legacySecondary),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadContacts,
              child: _buildContacts(context, contacts),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContacts(BuildContext context, List<RecordedContact> contacts) {
    if (_loading) {
      return const _ContactPlaceholder(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 40, height: 40, child: NativeProgress()),
            SizedBox(height: 20),
            Text(
              RecordedFormsContent.contactsLoading,
              style: TextStyle(fontSize: 12, color: MobyColors.legacySecondary),
            ),
          ],
        ),
      );
    }
    if (!_loaded) {
      return _ContactPlaceholder(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _loadContacts,
              tooltip: RecordedFormsContent.contactsEmpty,
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints.tightFor(width: 58, height: 58),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F3FB),
              ),
              icon: const SourceIcon(
                'ic_arrow_down_big',
                width: 28,
                height: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              RecordedFormsContent.contactsEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: MobyColors.legacySecondary),
            ),
          ],
        ),
      );
    }
    if (contacts.isEmpty) {
      return const _ContactPlaceholder(
        child: Text(
          RecordedFormsContent.contactsNotFound,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: MobyColors.legacySecondary),
        ),
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        for (var index = 0; index < contacts.length; index++) ...[
          if (index == 0 ||
              contacts[index].section != contacts[index - 1].section)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                contacts[index].section,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _ContactRow(
            contact: contacts[index],
            onTap: () => context.push(
              Uri(
                path: '/transfer',
                queryParameters: {'recipient': contacts[index].name},
              ).toString(),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContactPlaceholder extends StatelessWidget {
  const _ContactPlaceholder({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Align(
            alignment: const Alignment(0, -.4),
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      ],
    ),
  );
}

class RecordedEripPickerPage extends StatelessWidget {
  const RecordedEripPickerPage({super.key});

  @override
  Widget build(BuildContext context) => MobyPage(
    title: RecordedFormsContent.eripTitle,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        _EripRow(
          title: RecordedFormsContent.cardReplenishment,
          route: RecordedFormsContent.cardReplenishmentRoute,
        ),
        const SizedBox(height: 8),
        _EripRow(
          title: RecordedFormsContent.accountReplenishment,
          route: RecordedFormsContent.accountReplenishmentRoute,
        ),
      ],
    ),
  );
}

class _EripRow extends StatelessWidget {
  const _EripRow({required this.title, required this.route});
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: const TextStyle(fontSize: 17)),
    trailing: const SizedBox(
      width: 9,
      height: 24,
      child: SourceIcon('ic_arrow_right'),
    ),
    onTap: () => context.push(route),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.item, required this.onTap});
  final RecordedActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              SourceIcon(item.icon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: MobyColors.legacySecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact, required this.onTap});
  final RecordedContact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    minVerticalPadding: 8,
    leading: CircleAvatar(
      radius: 24,
      backgroundColor: MobyColors.brand,
      foregroundColor: MobyColors.surface,
      child: Text(contact.initials, style: const TextStyle(fontSize: 15)),
    ),
    title: Text(contact.name, style: const TextStyle(fontSize: 15)),
    subtitle: Text(
      contact.maskedPhone,
      style: const TextStyle(fontSize: 15, color: MobyColors.legacySecondary),
    ),
    onTap: onTap,
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );
}

class _RecordedInput extends StatelessWidget {
  const _RecordedInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.helper,
    required this.inputKey,
    this.decimal = false,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final String helper;
  final String inputKey;
  final bool decimal;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(label),
      const SizedBox(height: 8),
      TextField(
        key: ValueKey(inputKey),
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          isDense: true,
          constraints: const BoxConstraints(minHeight: 44),
          suffixIconConstraints: const BoxConstraints.tightFor(
            width: 44,
            height: 44,
          ),
          suffixIcon: IconButton(
            tooltip: RecordedFormsContent.clear,
            onPressed: controller.clear,
            icon: const SourceIcon(
              'ic_close',
              size: 16,
              color: MobyColors.navBorder,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: MobyColors.rowBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: MobyColors.rowBorder),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        helper,
        style: const TextStyle(fontSize: 12, color: MobyColors.secondary),
      ),
    ],
  );
}

class _CalculatedValue extends StatelessWidget {
  const _CalculatedValue({required this.title, this.value});
  final String title;
  final String? value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 15)),
      const SizedBox(height: 8),
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 22),
        child: value == null
            ? null
            : Text(
                value!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: MobyColors.brand,
                ),
              ),
      ),
    ],
  );
}

class _BottomNext extends StatelessWidget {
  const _BottomNext({this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: FilledButton(
      key: const ValueKey('recorded-form-next'),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        maximumSize: const Size.fromHeight(48),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        disabledBackgroundColor: const Color(0xFFECEBF3),
        disabledForegroundColor: const Color(0xFFB8B9C7),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: const Text(RecordedFormsContent.next),
    ),
  );
}
