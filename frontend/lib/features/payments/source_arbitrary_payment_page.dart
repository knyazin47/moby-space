import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/config/payment_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/recorded_cards.dart';
import '../../data/bank_data.dart';

/// Field topology: current ViewArbitraryPaymentBinding in APK1.0.199.
/// Bank discovery, code directory and server BillDetail constraints are not
/// reconstructed as if they had been retrieved. Local bounds live in config.
class SourceArbitraryPaymentPage extends ConsumerStatefulWidget {
  const SourceArbitraryPaymentPage({super.key});
  @override
  ConsumerState<SourceArbitraryPaymentPage> createState() => _ArbitraryState();
}

class _ArbitraryState extends ConsumerState<SourceArbitraryPaymentPage> {
  final _unp = TextEditingController();
  final _iban = TextEditingController();
  final _bic = TextEditingController();
  final _recipient = TextEditingController();
  final _purpose = TextEditingController();
  final _code = TextEditingController();
  final _amount = TextEditingController();
  String _account = primaryAccountId;
  bool _refund = false;
  bool _submitted = false;
  String? _error;

  List<TextEditingController> get _controllers => [
    _unp,
    _iban,
    _bic,
    _recipient,
    _purpose,
    _code,
    _amount,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Money? get _money {
    final match = RegExp(
      r'^(\d{1,9})(?:[.,](\d{1,2}))?$',
    ).firstMatch(_amount.text.trim());
    if (match == null) return null;
    final value =
        int.parse(match[1]!) * 100 +
        int.parse((match[2] ?? '').padRight(2, '0'));
    return value > 0 ? Money(value) : null;
  }

  bool get _valid =>
      _unp.text.isNotEmpty &&
      PaymentContent.validIban(_iban.text) &&
      _bic.text.trim().isNotEmpty &&
      _recipient.text.trim().isNotEmpty &&
      _purpose.text.trim().isNotEmpty &&
      RegExp(r'^\d{5}$').hasMatch(_code.text) &&
      _money != null;

  Widget _field(
    String key,
    String label,
    TextEditingController controller, {
    bool numeric = false,
    int? limit,
    String? hint,
    bool upper = false,
    bool readOnly = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          key: ValueKey(key),
          controller: controller,
          readOnly: readOnly,
          textCapitalization: upper
              ? TextCapitalization.characters
              : TextCapitalization.sentences,
          autocorrect: false,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            if (numeric) FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(
              limit ?? PaymentContent.localTextLimit,
            ),
          ],
          decoration: InputDecoration(hintText: hint),
          onChanged: (value) {
            if (upper && value != value.toUpperCase()) {
              controller.value = controller.value.copyWith(
                text: value.toUpperCase(),
              );
            }
            if (controller == _iban) {
              _bic.text =
                  PaymentContent.validIban(_iban.text) &&
                      _iban.text.substring(4, 8) == 'MTBK'
                  ? PaymentContent.localBic
                  : '';
            }
            setState(() => _error = null);
          },
        ),
      ],
    ),
  );

  bool _pay() {
    if (_submitted || !_valid) return false;
    final result = ref
        .read(bankRepositoryProvider)
        .pay(
          description: PaymentContent.arbitrary,
          note:
              '${_purpose.text.trim()}\n${PaymentContent.code}: ${_code.text}\n${PaymentContent.iban}: ${_iban.text}\n${PaymentContent.unp}: ${_unp.text}${_refund ? '\n${PaymentContent.refund}' : ''}',
          accountId: _account,
          recipient: _recipient.text.trim(),
          amount: _money!,
        );
    switch (result) {
      case TransferSuccess(:final operation):
        _submitted = true;
        FocusScope.of(context).unfocus();
        context.pushReplacement('/operation/${operation.id}');
        return true;
      case TransferFailure(:final code):
        setState(
          () => _error = code == TransferFailureCode.insufficientFunds
              ? AppCopy.insufficientFunds
              : AppCopy.transferFailed,
        );
        return false;
    }
  }

  Future<void> _chooseAccount(BankSnapshot snapshot) async {
    final id = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final account in snapshot.accounts.where(
              (item) => item.balance.currency == 'BYN',
            ))
              ListTile(
                title: Text(account.title),
                subtitle: Text(account.maskedNumber),
                onTap: () => Navigator.pop(context, account.id),
              ),
          ],
        ),
      ),
    );
    if (mounted && id != null) setState(() => _account = id);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = watchBankSnapshot(ref);
    return MobyPage(
      title: PaymentContent.arbitrary,
      titleMaxLines: 2,
      replayLoad: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    PaymentContent.arbitraryWarning,
                    style: TextStyle(
                      fontSize: 13,
                      color: MobyColors.legacySecondary,
                    ),
                  ),
                ),
                _field(
                  'arbitrary-unp',
                  PaymentContent.unp,
                  _unp,
                  numeric: true,
                  limit: PaymentContent.localUnpLimit,
                ),
                _field(
                  'arbitrary-iban',
                  PaymentContent.iban,
                  _iban,
                  upper: true,
                  limit: 28,
                ),
                _field(
                  'arbitrary-bic',
                  PaymentContent.bic,
                  _bic,
                  upper: true,
                  readOnly: true,
                ),
                _field(
                  'arbitrary-recipient',
                  PaymentContent.recipient,
                  _recipient,
                  hint: PaymentContent.recipientHint,
                ),
                _field(
                  'arbitrary-purpose',
                  PaymentContent.purpose,
                  _purpose,
                  hint: PaymentContent.purposeHint,
                ),
                _field(
                  'arbitrary-code',
                  PaymentContent.code,
                  _code,
                  numeric: true,
                  limit: 5,
                  hint: PaymentContent.codeHint,
                ),
                TextButton(
                  onPressed: () => context.push('/payments/codes'),
                  child: const Text(PaymentContent.chooseCode),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(PaymentContent.refund),
                  value: _refund,
                  onChanged: (value) => setState(() => _refund = value),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    PaymentContent.refundExplanation,
                    style: TextStyle(
                      fontSize: 12,
                      color: MobyColors.legacySecondary,
                    ),
                  ),
                ),
                TextField(
                  key: const ValueKey('arbitrary-amount'),
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(12)],
                  decoration: const InputDecoration(
                    labelText: PaymentContent.amount,
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RecordedOwnCardPager(
            currency: 'BYN',
            snapshot: snapshot,
            selectedAccountId: _account,
            onSelected: (id) => setState(() => _account = id),
            onOpenPicker: () => _chooseAccount(snapshot),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(PaymentContent.commission),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: MobyColors.danger),
                    ),
                  ),
                const SizedBox(height: 24),
                RecordedSwipeConfirm(
                  key: const ValueKey('arbitrary-confirm'),
                  enabled:
                      !_submitted &&
                      _valid &&
                      snapshot.accountById(_account)!.balance.currency == 'BYN',
                  label: PaymentContent.arbitrarySwipe,
                  semanticLabel: PaymentContent.confirm,
                  onConfirm: _pay,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// view_codebook.xml: empty offline dictionary, not invented code entries.
class SourcePaymentCodebookPage extends StatefulWidget {
  const SourcePaymentCodebookPage({super.key});
  @override
  State<SourcePaymentCodebookPage> createState() => _CodebookState();
}

class _CodebookState extends State<SourcePaymentCodebookPage> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: PaymentContent.codebook,
    titleMaxLines: 2,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            key: const ValueKey('payment-code-search'),
            controller: _search,
            inputFormatters: [
              LengthLimitingTextInputFormatter(PaymentContent.searchLimit),
            ],
            decoration: InputDecoration(
              hintText: AppCopy.search,
              suffixIcon: IconButton(
                onPressed: _search.clear,
                tooltip: AppCopy.close,
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                PaymentContent.noCode,
                textAlign: TextAlign.center,
                style: TextStyle(color: MobyColors.legacySecondary),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
