import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/config/transfer_content.dart';
import '../../core/formatting/formatters.dart';
import '../../core/formatting/card_input_formatters.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/recorded_cards.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';

class TransferPage extends ConsumerStatefulWidget {
  const TransferPage({
    super.key,
    this.refill = false,
    this.accountId,
    this.recipient,
  });
  final String? recipient;
  final bool refill;
  final String? accountId;
  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  final _form = GlobalKey<FormState>();
  final _recipient = TextEditingController();
  final _amount = TextEditingController();
  final _sourceNumber = TextEditingController();
  final _sourceExpiry = TextEditingController();
  final _sourceCvv = TextEditingController();
  String? _selectedAccountId;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _recipient.text = widget.recipient ?? '';
    _selectedAccountId = widget.accountId;
    for (final controller in [
      _recipient,
      _amount,
      _sourceNumber,
      _sourceExpiry,
      _sourceCvv,
    ]) {
      controller.addListener(_inputsChanged);
    }
  }

  void _inputsChanged() {
    if (mounted) setState(() => _error = null);
  }

  @override
  void dispose() {
    for (final controller in [
      _recipient,
      _amount,
      _sourceNumber,
      _sourceExpiry,
      _sourceCvv,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Money? _parseAmount(String text, String currency) {
    final match = RegExp(
      r'^(\d{1,10})(?:[.,](\d{1,2}))?$',
    ).firstMatch(text.trim().replaceAll(' ', ''));
    if (match == null) return null;
    final cents =
        int.parse(match[1]!) * 100 +
        int.parse((match[2] ?? '').padRight(2, '0'));
    return cents > 0 ? Money(cents, currency: currency) : null;
  }

  void _fillExternal() {
    _sourceNumber.text = TransferContent.externalCard.number;
    _sourceExpiry.text = TransferContent.externalCard.expiry;
    _sourceCvv.text = TransferContent.externalCard.cvv;
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = watchBankSnapshot(ref);
    final account =
        snapshot.accountById(_selectedAccountId ?? primaryAccountId) ??
        snapshot.primaryAccount;
    final ready =
        !_submitting &&
        _parseAmount(_amount.text, account.balance.currency) != null &&
        (widget.refill
            ? TransferContent.externalInputComplete(
                _sourceNumber.text,
                _sourceExpiry.text,
                _sourceCvv.text,
              )
            : _recipient.text.trim().isNotEmpty);
    final ownCard = RecordedOwnCardPager(
      snapshot: snapshot,
      selectedAccountId: account.id,
      onSelected: _selectAccount,
      onOpenPicker: () => _chooseAccount(snapshot),
    );
    return MobyPage(
      replayLoad: true,
      title: widget.refill ? AppCopy.refill : AppCopy.transfer,
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _TransferHeader(
              title: TransferContent.from,
              trailing: widget.refill
                  ? _ScanActions(onTap: _fillExternal)
                  : TextButton(
                      onPressed: () => _chooseAccount(snapshot),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF4FE),
                        foregroundColor: MobyColors.brand,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text(
                        TransferContent.favourites,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
            ),
            if (widget.refill)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: _InputCard(
                  number: _sourceNumber,
                  expiry: _sourceExpiry,
                  cvv: _sourceCvv,
                ),
              )
            else
              ownCard,
            _TransferHeader(
              title: TransferContent.to,
              trailing: widget.refill
                  ? null
                  : _ScanActions(
                      onTap: () =>
                          _recipient.text = TransferContent.syntheticRecipient,
                    ),
            ),
            if (widget.refill)
              ownCard
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: _InputCard(number: _recipient),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _showCountries,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: const Text(TransferContent.countries),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TransferContent.amountLabel(account.balance.currency),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const ValueKey('transfer-amount'),
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 15),
                    decoration: _pillDecoration(TransferContent.amountHint),
                    validator: (value) =>
                        _parseAmount(value ?? '', account.balance.currency) ==
                            null
                        ? AppCopy.amountInvalid
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    TransferContent.commission(
                      formatMoney(Money(0, currency: account.balance.currency)),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MobyColors.danger,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  KeyedSubtree(
                    key: const ValueKey('confirm-transfer'),
                    child: RecordedSwipeConfirm(
                      key: ValueKey('confirm-${account.id}'),
                      enabled: ready,
                      label: widget.refill
                          ? TransferContent.swipeRefill
                          : TransferContent.swipeTransfer,
                      semanticLabel: widget.refill
                          ? TransferContent.confirmRefill
                          : TransferContent.confirmTransfer,
                      onConfirm: () =>
                          _submit(account.id, account.balance.currency),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseAccount(BankSnapshot snapshot) async {
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
            for (final card in snapshot.cards)
              ListTile(
                leading: RecordedCardThumbnail(card: card),
                title: Text(card.title),
                subtitle: Text(card.maskedNumber),
                onTap: () => Navigator.of(sheetContext).pop(card.accountId),
              ),
          ],
        ),
      ),
    );
    if (mounted && selected != null) _selectAccount(selected);
  }

  void _selectAccount(String accountId) {
    if (_submitting || _selectedAccountId == accountId) return;
    setState(() {
      _selectedAccountId = accountId;
      _error = null;
    });
  }

  void _showCountries() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(TransferContent.countries),
      content: const Text(TransferContent.countriesDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(TransferContent.close),
        ),
      ],
    ),
  );

  bool _submit(String accountId, String currency) {
    if (_submitting || !_form.currentState!.validate()) return false;
    if (widget.refill &&
        !TransferContent.externalInputComplete(
          _sourceNumber.text,
          _sourceExpiry.text,
          _sourceCvv.text,
        )) {
      return false;
    }
    final amount = _parseAmount(_amount.text, currency);
    if (amount == null) return false;
    setState(() => _submitting = true);
    final repository = ref.read(bankRepositoryProvider);
    final result = widget.refill
        ? repository.topUp(accountId: accountId, amount: amount)
        : repository.transfer(
            fromAccountId: accountId,
            recipient: _recipient.text,
            amount: amount,
          );
    switch (result) {
      case TransferSuccess(:final operation):
        FocusScope.of(context).unfocus();
        context.pushReplacement('/operation/${operation.id}');
        return true;
      case TransferFailure(:final code):
        setState(() {
          _submitting = false;
          _error = code == TransferFailureCode.insufficientFunds
              ? AppCopy.insufficientFunds
              : AppCopy.transferFailed;
        });
        return false;
    }
  }
}

class _TransferHeader extends StatelessWidget {
  const _TransferHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 32, right: 24),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class _ScanActions extends StatelessWidget {
  const _ScanActions({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: onTap,
        tooltip: TransferContent.nfc,
        padding: const EdgeInsets.all(4),
        icon: const SourceIcon('ic_nfc', width: 53, height: 24),
      ),
      IconButton(
        onPressed: onTap,
        tooltip: TransferContent.camera,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        icon: const SourceIcon('ic_camera', size: 24),
      ),
    ],
  );
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.number, this.expiry, this.cvv});
  final TextEditingController number;
  final TextEditingController? expiry;
  final TextEditingController? cvv;
  bool get external => expiry != null;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final height = math.max(
        constraints.maxWidth / 2,
        (external ? 154 : 112) * scale,
      );
      return Container(
        constraints: BoxConstraints(minHeight: height),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        decoration: BoxDecoration(
          color: MobyColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MobyColors.rowBorder),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: ValueKey(
                external ? 'refill-source-number' : 'transfer-recipient',
              ),
              controller: number,
              enableSuggestions: false,
              autocorrect: false,
              inputFormatters: external ? [const PanInputFormatter()] : null,
              autovalidateMode: external
                  ? AutovalidateMode.onUnfocus
                  : AutovalidateMode.disabled,

              keyboardType: external
                  ? TextInputType.number
                  : TextInputType.text,
              style: const TextStyle(fontSize: 15),
              decoration: _pillDecoration(TransferContent.numberHint).copyWith(
                semanticCounterText: external
                    ? TransferContent.sourceNumber
                    : TransferContent.recipientNumber,
              ),
              validator: external
                  ? TransferContent.cardNumberError
                  : (value) => value == null || value.trim().isEmpty
                        ? AppCopy.recipientRequired
                        : null,
            ),
            if (external) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: TextFormField(
                        key: const ValueKey('refill-source-expiry'),
                        controller: expiry,
                        enableSuggestions: false,
                        autocorrect: false,
                        inputFormatters: [const ExpiryInputFormatter()],
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: TransferContent.expiryError,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 15),
                        decoration: _pillDecoration(TransferContent.expiryHint),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 96),
                      child: TextFormField(
                        key: const ValueKey('refill-source-cvv'),
                        controller: cvv,
                        enableSuggestions: false,
                        autocorrect: false,
                        inputFormatters: [const CvcInputFormatter()],
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: TransferContent.cvcError,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        style: const TextStyle(fontSize: 15),
                        decoration: _pillDecoration(TransferContent.cvvHint),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}

InputDecoration _pillDecoration(String hint) => InputDecoration(
  constraints: const BoxConstraints(minHeight: 44),
  hintText: hint,
  errorMaxLines: 3,
  errorStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11, height: 1.15),
  hintStyle: const TextStyle(color: MobyColors.legacySecondary),
  filled: true,
  fillColor: MobyColors.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
  isDense: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: const BorderSide(color: MobyColors.rowBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: const BorderSide(color: MobyColors.rowBorder),
  ),
);
