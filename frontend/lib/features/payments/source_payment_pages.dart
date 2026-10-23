import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/config/payment_content.dart';
import '../../core/config/recorded_forms_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/recorded_cards.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';

class SourceMobilePaymentPage extends ConsumerStatefulWidget {
  const SourceMobilePaymentPage({super.key});
  @override
  ConsumerState<SourceMobilePaymentPage> createState() => _MobileState();
}

class _MobileState extends ConsumerState<SourceMobilePaymentPage> {
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  String _account = primaryAccountId;
  int _operator = 0;
  bool _determining = false;
  bool _submitted = false;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _phone.addListener(_changed);
    _amount.addListener(_changed);
  }

  void _changed() => setState(() => _error = null);

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

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _chooseOperator(int index) {
    _timer?.cancel();
    setState(() {
      _determining = index == 3;
      _error = null;
      if (index != 3) _operator = index;
    });
    if (index == 3) {
      _timer = Timer(PaymentContent.determineDelay, () {
        if (!mounted) return;
        setState(() {
          _determining = false;
          _error = PaymentContent.determineError;
        });
      });
    }
  }

  Future<void> _contacts() async {
    final contact = await showModalBottomSheet<RecordedContact>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in RecordedFormsContent.contacts)
              ListTile(
                title: Text(item.name),
                subtitle: Text(item.maskedPhone),
                onTap: () => Navigator.pop(context, item),
              ),
          ],
        ),
      ),
    );
    if (contact == null || !mounted) return;
    final index = RecordedFormsContent.contacts.indexOf(contact);
    _phone.text = PaymentContent.contactNumbers[index];
  }

  Future<void> _chooseAccount(BankSnapshot snapshot) async {
    final selected = await showModalBottomSheet<String>(
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
    if (selected != null && mounted) {
      setState(() {
        _account = selected;
        _error = null;
      });
    }
  }

  bool _pay() {
    final amount = _money;
    if (_submitted ||
        amount == null ||
        !PaymentContent.validPhone(_phone.text)) {
      return false;
    }
    final result = ref
        .read(bankRepositoryProvider)
        .pay(
          description: PaymentContent.mobile,
          accountId: _account,
          recipient:
              '${PaymentContent.operators[_operator]} +375 ${_phone.text}',
          amount: amount,
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

  @override
  Widget build(BuildContext context) {
    final snapshot = watchBankSnapshot(ref);
    final account = snapshot.accountById(_account)!;
    return MobyPage(
      title: PaymentContent.mobile,
      replayLoad: true,
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              key: const ValueKey('mobile-phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: InputDecoration(
                labelText: PaymentContent.phone,
                prefixText: '+375 ',
                hintText: PaymentContent.phoneHint,
                suffixIcon: IconButton(
                  onPressed: _contacts,
                  tooltip: RecordedFormsContent.contactsTitle,
                  icon: const SourceIcon('ic_user'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: InkWell(
                    key: ValueKey('mobile-operator-$i'),
                    onTap: () => _chooseOperator(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _operator == i
                                    ? MobyColors.brand
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: SourceIcon(
                              _determining && i == 3
                                  ? 'loader_mobile_determining'
                                  : PaymentContent.operatorAssets[i],
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            PaymentContent.operators[i],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              key: const ValueKey('mobile-amount'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(12)],
              decoration: const InputDecoration(
                labelText: PaymentContent.amount,
                hintText: AppCopy.amountHint,
              ),
            ),
          ),
          const SizedBox(height: 16),
          RecordedOwnCardPager(
            currency: 'BYN',
            snapshot: snapshot,
            selectedAccountId: _account,
            onSelected: (id) => setState(() {
              _account = id;
              _error = null;
            }),
            onOpenPicker: () => _chooseAccount(snapshot),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  PaymentContent.commission,
                  style: TextStyle(fontSize: 15),
                ),
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
                  key: const ValueKey('mobile-confirm'),
                  enabled:
                      !_submitted &&
                      !_determining &&
                      _money != null &&
                      PaymentContent.validPhone(_phone.text) &&
                      account.balance.currency == 'BYN',
                  label: PaymentContent.swipe,
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

class SourcePaymentEmptyPage extends StatelessWidget {
  const SourcePaymentEmptyPage({super.key, this.credit = false});
  final bool credit;
  @override
  Widget build(BuildContext context) => MobyPage(
    title: credit ? PaymentContent.credit : PaymentContent.templates,
    replayLoad: true,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SourceIcon(
              credit ? 'ic_credits_empty_list' : 'ic_pay_template',
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              credit ? PaymentContent.noCredits : PaymentContent.noTemplates,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: MobyColors.legacySecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The camera is deliberately not accessed by this offline build. No fake scan
/// is presented as an actual recognition result.
class SourceQrPaymentPage extends StatelessWidget {
  const SourceQrPaymentPage({super.key});
  @override
  Widget build(BuildContext context) => MobyPage(
    title: PaymentContent.qr,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SourceIcon('ic_qr_code_scan', size: 72),
            const SizedBox(height: 24),
            const Text(PaymentContent.cameraUnavailable),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text(PaymentContent.close),
            ),
          ],
        ),
      ),
    ),
  );
}
