import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/config/source_exchange_content.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';

/// Source-confirmed Nembo shell with a bounded local calculation preview.
/// No API call, exchange ledger mutation, promo acceptance or success is emitted.
class SourceExchangePage extends ConsumerStatefulWidget {
  const SourceExchangePage({super.key});

  @override
  ConsumerState<SourceExchangePage> createState() => _SourceExchangePageState();
}

class _SourceExchangePageState extends ConsumerState<SourceExchangePage> {
  final _input = TextEditingController();
  final _output = TextEditingController();
  final _promo = TextEditingController();
  String _from = SourceExchangeContent.initialInputCurrency;
  String _to = SourceExchangeContent.initialOutputCurrency;
  bool _receivingInput = false;
  bool _improveOpen = false;
  bool _promoOpen = false;
  bool _promoChecked = false;
  bool _busy = false;
  SourceExchangeQuote? _quote;

  @override
  void dispose() {
    _input.dispose();
    _output.dispose();
    _promo.dispose();
    super.dispose();
  }

  void _calculate({bool? receivingInput}) {
    setState(() {
      if (receivingInput != null) _receivingInput = receivingInput;
      _quote = SourceExchangeContent.calculate(
        text: (_receivingInput ? _output : _input).text,
        from: _from,
        to: _to,
        receivingInput: _receivingInput,
      );
      final other = _receivingInput ? _input : _output;
      other.text = _quote == null
          ? ''
          : (_receivingInput ? _quote!.debit : _quote!.credit).toStringAsFixed(
              2,
            );
    });
  }

  Future<void> _chooseCurrency(bool receiving) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MobyColors.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const Text(
              SourceExchangeContent.chooseCurrency,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            for (final code in SourceExchangeContent.currencies)
              ListTile(
                leading: SourceIcon(
                  SourceExchangeContent.flagFor(code)!,
                  size: 26,
                ),
                title: Text(code),
                selected: code == (receiving ? _to : _from),
                onTap: () => Navigator.of(sheetContext).pop(code),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    if (receiving) {
      if (selected == _from) _from = _to;
      _to = selected;
    } else {
      if (selected == _to) _to = _from;
      _from = selected;
    }
    _calculate();
  }

  void _swap() {
    final old = _from;
    _from = _to;
    _to = old;
    final text = _input.text;
    _input.text = _output.text;
    _output.text = text;
    _calculate();
  }

  Future<void> _notice(String title, String body) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(SourceExchangeContent.close),
        ),
      ],
    ),
  );

  Future<void> _continue() async {
    final quote = _quote;
    if (quote == null || _busy) return;
    setState(() => _busy = true);
    FocusScope.of(context).unfocus();
    try {
      final snapshot = ref.read(bankRepositoryProvider).snapshot;
      final debit = snapshot.accounts
          .where((a) => a.balance.currency == quote.from)
          .toList();
      final credit = snapshot.accounts
          .where((a) => a.balance.currency == quote.to)
          .toList();
      if (debit.isEmpty || credit.isEmpty) {
        await _notice(
          SourceExchangeContent.unavailableTitle,
          SourceExchangeContent.noAccounts,
        );
        return;
      }
      final accounts = await showModalBottomSheet<(DemoAccount, DemoAccount)>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: MobyColors.surface,
        builder: (sheetContext) =>
            _ExchangeAccounts(debit: debit, credit: credit, quote: quote),
      );
      if (!mounted || accounts == null) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          key: const ValueKey('exchange-confirmation'),
          title: const Text(SourceExchangeContent.confirmation),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(SourceExchangeContent.debitAmount),
                Text(quote.debitLabel),
                Text(accounts.$1.maskedNumber),
                const SizedBox(height: 16),
                const Text(SourceExchangeContent.creditAmount),
                Text(quote.creditLabel),
                Text(accounts.$2.maskedNumber),
                const SizedBox(height: 16),
                Text(quote.rateLabel),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(SourceExchangeContent.cancel),
            ),
            TextButton(
              key: const ValueKey('exchange-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(SourceExchangeContent.confirm),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      // There is no repository FX settlement contract. Stop explicitly instead
      // of claiming completion or changing either currency balance separately.
      await _notice(
        SourceExchangeContent.unavailableTitle,
        SourceExchangeContent.unavailableBody,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _receivingInput ? _output : _input;
    final invalid = active.text.trim().isNotEmpty && _quote == null;
    final rate = SourceExchangeContent.rateFor(_from, _to);
    return MobyPage(
      title: SourceExchangeContent.title,
      replayLoad: true,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  SourceExchangeContent.calculationTitle,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MobyColors.rowBorder),
                  ),
                  child: Column(
                    children: [
                      _AmountRow(
                        label: SourceExchangeContent.inputTitle,
                        inputKey: 'exchange-input',
                        controller: _input,
                        code: _from,
                        onChanged: (_) => _calculate(receivingInput: false),
                        onCurrency: () => _chooseCurrency(false),
                      ),
                      SizedBox(
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Divider(
                              height: 1,
                              color: MobyColors.rowBorder,
                            ),
                            Material(
                              color: MobyColors.surface,
                              shape: const CircleBorder(),
                              child: IconButton(
                                key: const ValueKey('exchange-swap'),
                                tooltip: SourceExchangeContent.swap,
                                onPressed: _swap,
                                constraints: const BoxConstraints.tightFor(
                                  width: 48,
                                  height: 48,
                                ),
                                padding: const EdgeInsets.all(8),
                                icon: const SourceIcon(
                                  'ic_two_arrows',
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _AmountRow(
                        label: SourceExchangeContent.outputTitle,
                        inputKey: 'exchange-output',
                        controller: _output,
                        code: _to,
                        onChanged: (_) => _calculate(receivingInput: true),
                        onCurrency: () => _chooseCurrency(true),
                      ),
                    ],
                  ),
                ),
                if (invalid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      SourceExchangeContent.invalidAmount,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MobyColors.danger,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  SourceExchangeContent.rateTitle,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 4),
                if (rate != null)
                  Text(
                    SourceExchangeContent.formatRate(rate, _from, _to),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 24),
                _Disclosure(
                  title: SourceExchangeContent.improveTitle,
                  open: _improveOpen,
                  onTap: () => setState(() => _improveOpen = !_improveOpen),
                ),
                if (_improveOpen)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      SourceExchangeContent.improveUnavailable,
                      style: TextStyle(
                        fontSize: 13,
                        color: MobyColors.legacySecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _Disclosure(
                  title: SourceExchangeContent.promoTitle,
                  open: _promoOpen,
                  onTap: () => setState(() => _promoOpen = !_promoOpen),
                ),
                if (_promoOpen) ...[
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('exchange-promo'),
                    controller: _promo,
                    onChanged: (_) => setState(() => _promoChecked = false),
                    decoration: InputDecoration(
                      hintText: SourceExchangeContent.promoHint,
                      errorText:
                          _promoChecked &&
                              _promo.text.trim().length <
                                  SourceExchangeContent.promoMinimumLength
                          ? SourceExchangeContent.promoShort
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      key: const ValueKey('exchange-apply-promo'),
                      onPressed: () => setState(() => _promoChecked = true),
                      child: const Text(SourceExchangeContent.apply),
                    ),
                  ),
                  if (_promoChecked &&
                      _promo.text.trim().length >=
                          SourceExchangeContent.promoMinimumLength)
                    const Text(
                      SourceExchangeContent.promoUnavailable,
                      style: TextStyle(
                        fontSize: 13,
                        color: MobyColors.legacySecondary,
                      ),
                    ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const ValueKey('exchange-continue'),
                onPressed: _quote == null || _busy ? null : _continue,
                child: const Text(SourceExchangeContent.next),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.inputKey,
    required this.controller,
    required this.code,
    required this.onChanged,
    required this.onCurrency,
  });
  final String label;
  final String inputKey;
  final TextEditingController controller;
  final String code;
  final ValueChanged<String> onChanged;
  final VoidCallback onCurrency;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            key: ValueKey(inputKey),
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              labelText: label,
              hintText: SourceExchangeContent.amountHint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(
                fontSize: 15,
                color: MobyColors.legacySecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          key: ValueKey('$inputKey-currency'),
          onPressed: onCurrency,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: const BorderSide(color: MobyColors.rowBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(code),
              const SizedBox(width: 8),
              const SourceIcon('ic_arrow_down', size: 16),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Disclosure extends StatelessWidget {
  const _Disclosure({
    required this.title,
    required this.open,
    required this.onTap,
  });
  final String title;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    expanded: open,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
            RotatedBox(
              quarterTurns: open ? 2 : 0,
              child: const SourceIcon('ic_arrow_down', size: 24),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ExchangeAccounts extends StatefulWidget {
  const _ExchangeAccounts({
    required this.debit,
    required this.credit,
    required this.quote,
  });
  final List<DemoAccount> debit;
  final List<DemoAccount> credit;
  final SourceExchangeQuote quote;
  @override
  State<_ExchangeAccounts> createState() => _ExchangeAccountsState();
}

class _ExchangeAccountsState extends State<_ExchangeAccounts> {
  late DemoAccount _debit = widget.debit.first;
  late DemoAccount _credit = widget.credit.first;
  @override
  Widget build(BuildContext context) {
    final sufficient =
        (widget.quote.debit * 100).round() <= _debit.balance.minorUnits;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _accountPicker(
              SourceExchangeContent.debitAccount,
              widget.debit,
              _debit,
              (account) => setState(() => _debit = account),
            ),
            const SizedBox(height: 24),
            _accountPicker(
              SourceExchangeContent.creditAccount,
              widget.credit,
              _credit,
              (account) => setState(() => _credit = account),
            ),
            const SizedBox(height: 16),
            Text('${widget.quote.debitLabel} → ${widget.quote.creditLabel}'),
            if (!sufficient)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  SourceExchangeContent.insufficientFunds,
                  style: TextStyle(color: MobyColors.danger),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('exchange-accounts-continue'),
              onPressed: sufficient
                  ? () => Navigator.of(context).pop((_debit, _credit))
                  : null,
              child: const Text(SourceExchangeContent.next),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountPicker(
    String label,
    List<DemoAccount> accounts,
    DemoAccount selected,
    ValueChanged<DemoAccount> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      for (final account in accounts)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            selected: selected.id == account.id,
            button: true,
            child: Material(
              color: MobyColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selected.id == account.id
                      ? MobyColors.brand
                      : MobyColors.rowBorder,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(account),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const SourceIcon('ic_cards', size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.title,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              account.maskedNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                color: MobyColors.legacySecondary,
                              ),
                            ),
                            Text(
                              formatMoney(account.balance),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
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
  );
}
