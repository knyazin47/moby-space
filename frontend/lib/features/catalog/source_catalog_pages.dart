import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/source_catalog_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/native_progress.dart';
import '../../core/ui/source_assets.dart';

/// fragment_deposit_calculator.xml. An empty local product catalog produces
/// the source inline no-results state; no account or application is created.
class SourceDepositCalculatorPage extends StatefulWidget {
  const SourceDepositCalculatorPage({
    super.key,
    this.fixture = const SourceDepositFixture(),
  });

  final SourceDepositFixture fixture;

  @override
  State<SourceDepositCalculatorPage> createState() =>
      _SourceDepositCalculatorPageState();
}

class _SourceDepositCalculatorPageState
    extends State<SourceDepositCalculatorPage> {
  final _amount = TextEditingController();
  String _currency = SourceCatalogContent.currencies.first;
  bool _revocable = true;
  bool _irrevocable = true;
  bool _submitted = false;
  bool _loading = false;
  bool _empty = false;
  late RangeValues _months;

  @override
  void initState() {
    super.initState();
    _months = RangeValues(
      widget.fixture.minMonths.toDouble(),
      widget.fixture.maxMonths.toDouble(),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _changed() => setState(() => _empty = false);

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!widget.fixture.acceptsAmount(_amount.text)) return;
    setState(() {
      _loading = true;
      _empty = false;
    });
    await Future<void>.delayed(widget.fixture.loadingDuration);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _empty = true;
    });
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: SourceCatalogContent.depositTitle,
    child: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _Label(SourceCatalogContent.currency),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final code in SourceCatalogContent.currencies)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Semantics(
                            selected: _currency == code,
                            child: InkWell(
                              key: ValueKey('deposit-currency-$code'),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() {
                                _currency = code;
                                _empty = false;
                              }),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: _currency == code ? 16 : 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _currency == code
                                      ? MobyColors.brand
                                      : const Color(0xFFEFF5FB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  code,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _currency == code
                                        ? Colors.white
                                        : MobyColors.brand,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _Label(SourceCatalogContent.amount),
                  const SizedBox(height: 8),
                  TextField(
                    key: const ValueKey('deposit-amount'),
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return RegExp(
                              r'^\d{0,11}([.,]\d{0,2})?$',
                            ).hasMatch(newValue.text)
                            ? newValue
                            : oldValue;
                      }),
                    ],
                    onChanged: (_) => _changed(),
                    decoration: InputDecoration(
                      hintText: SourceCatalogContent.amountHint,
                      errorText: _submitted
                          ? widget.fixture.amountError(_amount.text)
                          : null,
                      suffixIcon: IconButton(
                        tooltip: SourceCatalogContent.clear,
                        onPressed: () {
                          _amount.clear();
                          _changed();
                        },
                        icon: const SourceIcon('ic_close', size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _Label(SourceCatalogContent.type),
                  const SizedBox(height: 4),
                  _TypeSwitch(
                    title: SourceCatalogContent.revocable,
                    value: _revocable,
                    onChanged: (value) => setState(() {
                      _revocable = value;
                      _empty = false;
                    }),
                  ),
                  const SizedBox(height: 4),
                  _TypeSwitch(
                    title: SourceCatalogContent.irrevocable,
                    value: _irrevocable,
                    onChanged: (value) => setState(() {
                      _irrevocable = value;
                      _empty = false;
                    }),
                  ),
                  const SizedBox(height: 16),
                  const _Label(SourceCatalogContent.term),
                  const SizedBox(height: 8),
                  Text(
                    '${SourceCatalogContent.months(_months.start.round())}'
                    ' — ${SourceCatalogContent.months(_months.end.round())}',
                    textAlign: TextAlign.center,
                  ),
                  RangeSlider(
                    key: const ValueKey('deposit-term'),
                    values: _months,
                    min: widget.fixture.minMonths.toDouble(),
                    max: widget.fixture.maxMonths.toDouble(),
                    divisions:
                        widget.fixture.maxMonths - widget.fixture.minMonths,
                    onChanged: (values) => setState(() {
                      _months = values;
                      _empty = false;
                    }),
                  ),
                  if (_empty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      SourceCatalogContent.empty,
                      key: ValueKey('deposit-no-results'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MobyColors.danger, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  key: const ValueKey('deposit-search'),
                  onPressed: _loading ? null : _search,
                  child: const Text(SourceCatalogContent.search),
                ),
              ),
            ),
          ],
        ),
        if (_loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
              child: Center(child: NativeProgress()),
            ),
          ),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
}

class _TypeSwitch extends StatelessWidget {
  const _TypeSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}

/// Packaged presentation, not proof of this user's package eligibility.
/// The owner supplies the exact imported img_loyalty asset and connect route.
class SourceLoyaltyPage extends StatelessWidget {
  const SourceLoyaltyPage({
    super.key,
    this.artAssetPath = SourceCatalogContent.loyaltyArt,
    required this.onConnect,
  });
  final String artAssetPath;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: IconButton(
                tooltip: SourceCatalogContent.close,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/more'),
                icon: const SourceIcon('ic_close', color: MobyColors.brand),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Text(
                          SourceCatalogContent.loyaltyTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          SourceCatalogContent.loyaltySubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          SourceCatalogContent.loyaltyDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF696E77),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    artAssetPath,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const ValueKey('loyalty-connect'),
                onPressed: onConnect,
                child: const Text(SourceCatalogContent.connect),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class SourceLoyaltyErrorPage extends StatelessWidget {
  const SourceLoyaltyErrorPage({super.key});

  @override
  Widget build(BuildContext context) => const MobyPage(
    title: SourceCatalogContent.packageTitle,
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        child: Text(
          SourceCatalogContent.loyaltyError,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: MobyColors.legacySecondary),
        ),
      ),
    ),
  );
}

/// Salary(unp) uses CardsFilter.NoFilter and the packaged no-offers binding.
class SourceSalaryCardSelectionPage extends StatelessWidget {
  const SourceSalaryCardSelectionPage({super.key});

  @override
  Widget build(BuildContext context) => const MobyPage(
    title: SourceCatalogContent.chooseCard,
    replayLoad: true,
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SourceIcon('ic_no_card_offers', width: 24, height: 25),
            SizedBox(height: 12),
            Text(
              SourceCatalogContent.noCardOffers,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF8A98AA)),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Uses public generic APK error/retry copy. The offline route mapping is a
/// local fallback, not evidence of a recorded bank response for this action.
class SourceCatalogUnavailablePage extends StatefulWidget {
  const SourceCatalogUnavailablePage({super.key, required this.title});
  final String title;

  @override
  State<SourceCatalogUnavailablePage> createState() =>
      _SourceCatalogUnavailablePageState();
}

class _SourceCatalogUnavailablePageState
    extends State<SourceCatalogUnavailablePage> {
  bool _loading = false;

  Future<void> _retry() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const SourceDepositFixture().loadingDuration);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: widget.title,
    child: Center(
      child: _loading
          ? const NativeProgress()
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    SourceCatalogContent.loadingError,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _retry,
                    child: const Text(SourceCatalogContent.retry),
                  ),
                ],
              ),
            ),
    ),
  );
}
