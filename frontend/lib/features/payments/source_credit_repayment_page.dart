import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/config/source_credit_repayment_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/native_progress.dart';
import '../../core/ui/source_assets.dart';

/// Source contract-entry stage only. No contract lookup, debt, recipient,
/// payment success, network or repository mutation is fabricated.
class SourceCreditRepaymentPage extends StatefulWidget {
  const SourceCreditRepaymentPage({super.key});

  @override
  State<SourceCreditRepaymentPage> createState() =>
      _SourceCreditRepaymentPageState();
}

class _SourceCreditRepaymentPageState extends State<SourceCreditRepaymentPage> {
  final _contract = TextEditingController();
  Timer? _lookup;
  bool _loading = false;
  bool _errorOpen = false;

  @override
  void dispose() {
    _lookup?.cancel();
    _contract.dispose();
    super.dispose();
  }

  void _submit() {
    if (_loading ||
        _errorOpen ||
        !SourceCreditRepaymentContent.canContinue(_contract.text)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    _lookup?.cancel();
    _lookup = Timer(SourceCreditRepaymentContent.lookupDuration, () {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorOpen = true;
      });
      unawaited(_showUnavailable());
    });
  }

  Future<void> _showUnavailable() async {
    final retry = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        key: const ValueKey('credit-repayment-unavailable'),
        backgroundColor: MobyColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SourceIcon('ic_action_error', size: 32),
              const SizedBox(height: 16),
              const Text(
                SourceCreditRepaymentContent.errorTitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, color: MobyColors.legacyText),
              ),
              const SizedBox(height: 16),
              const Text(
                SourceCreditRepaymentContent.unavailable,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: MobyColors.danger),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('credit-repayment-close'),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(SourceCreditRepaymentContent.close),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('credit-repayment-retry'),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(SourceCreditRepaymentContent.retry),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _errorOpen = false);
    if (retry == true) _submit();
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: SourceCreditRepaymentContent.title,
    replayLoad: true,
    child: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      SourceCreditRepaymentContent.information,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: MobyColors.legacySecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    SourceCreditRepaymentContent.contractNumber,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const ValueKey('credit-repayment-contract'),
                    controller: _contract,
                    enabled: !_loading && !_errorOpen,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      suffixIcon: _contract.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: SourceCreditRepaymentContent.clear,
                              onPressed: _loading
                                  ? null
                                  : () {
                                      _contract.clear();
                                      setState(() {});
                                    },
                              icon: const SourceIcon(
                                'ic_input_remove',
                                size: 20,
                              ),
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: MobyColors.rowBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: MobyColors.rowBorder,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('credit-repayment-continue'),
                  onPressed:
                      _loading ||
                          _errorOpen ||
                          !SourceCreditRepaymentContent.canContinue(
                            _contract.text,
                          )
                      ? null
                      : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    maximumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    disabledBackgroundColor: const Color(0xFFECEBF3),
                    disabledForegroundColor: const Color(0xFFB8B9C7),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text(
                    SourceCreditRepaymentContent.continueAction,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_loading)
          const Positioned.fill(
            child: ColoredBox(
              color: MobyColors.surface,
              child: Center(
                child: SizedBox(width: 40, height: 40, child: NativeProgress()),
              ),
            ),
          ),
      ],
    ),
  );
}
