import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/source_branches_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/native_progress.dart';
import '../../core/ui/source_assets.dart';

/// Packaged map/search/filter topology without fabricated locations or tiles.
class SourceBranchesPage extends StatefulWidget {
  const SourceBranchesPage({super.key});

  @override
  State<SourceBranchesPage> createState() => _SourceBranchesPageState();
}

class _SourceBranchesPageState extends State<SourceBranchesPage> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  var _filter = SourceBranchesFilter();
  var _view = SourceBranchesView.map;
  bool _loading = true;
  bool _filterOpen = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_focusChanged);
    _scheduleUnavailable();
  }

  void _focusChanged() {
    if (mounted) setState(() {});
  }

  // Deterministic local loading affordance, never a request to a map/bank API.
  void _scheduleUnavailable() {
    _timer?.cancel();
    _timer = Timer(SourceBranchesContent.loadingDuration, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _retry() {
    setState(() => _loading = true);
    _scheduleUnavailable();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchFocus.removeListener(_focusChanged);
    _searchFocus.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    if (_filterOpen) return;
    _filterOpen = true;
    _searchFocus.unfocus();
    try {
      final selected = await Navigator.of(context).push<SourceBranchesFilter>(
        MaterialPageRoute(
          builder: (_) => _SourceBranchesFilterPage(initial: _filter),
        ),
      );
      if (mounted && selected != null) setState(() => _filter = selected);
    } finally {
      _filterOpen = false;
    }
  }

  Future<void> _location() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(SourceBranchesContent.location),
      content: const Text(SourceBranchesContent.locationUnavailable),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(SourceBranchesContent.close),
        ),
      ],
    ),
  );

  void _cancelSearch() {
    _search.clear();
    _searchFocus.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => MobyPage(
    title: SourceBranchesContent.title,
    child: DefaultTabController(
      length: SourceBranchesView.values.length,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('branches-search'),
                    controller: _search,
                    focusNode: _searchFocus,
                    maxLength: SourceBranchesContent.searchLimit,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        SourceBranchesContent.searchLimit,
                      ),
                    ],
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _searchFocus.unfocus(),
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: SourceBranchesContent.search,
                      prefixIcon: const SourceIcon('ic_search', size: 20),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              key: const ValueKey('branches-search-clear'),
                              tooltip: SourceBranchesContent.clear,
                              onPressed: () {
                                _search.clear();
                                setState(() {});
                              },
                              icon: const SourceIcon(
                                'ic_input_remove',
                                size: 20,
                              ),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF0F3FA),
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_searchFocus.hasFocus)
                  TextButton(
                    onPressed: _cancelSearch,
                    child: const Text(SourceBranchesContent.cancel),
                  )
                else
                  IconButton(
                    key: const ValueKey('branches-filter'),
                    tooltip: SourceBranchesContent.filter,
                    onPressed: _openFilter,
                    icon: SourceIcon(
                      _filter.isActive
                          ? 'ic_filter_lines_active'
                          : 'ic_filter_lines',
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TabBar(
              labelColor: MobyColors.brand,
              unselectedLabelColor: MobyColors.legacyText,
              indicatorColor: MobyColors.brand,
              indicatorSize: TabBarIndicatorSize.tab,
              onTap: (index) =>
                  setState(() => _view = SourceBranchesView.values[index]),
              tabs: [
                for (final view in SourceBranchesView.values)
                  Tab(
                    key: ValueKey('branches-tab-${view.name}'),
                    text: SourceBranchesContent.tabs[view],
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Blank source-unknown surface: no imitation map roads or POIs.
                Positioned.fill(
                  child: ColoredBox(
                    color: _view == SourceBranchesView.map
                        ? const Color(0xFFF8F9FC)
                        : MobyColors.surface,
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: NativeProgress(),
                            ),
                          )
                        : _UnavailableLocations(onRetry: _retry),
                  ),
                ),
                if (_view == SourceBranchesView.map) ...[
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Source fragment_map.xml places this at end|top with margin16.
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SizedBox.square(
                      dimension: 52,
                      child: FloatingActionButton(
                        key: const ValueKey('branches-location'),
                        tooltip: SourceBranchesContent.location,
                        backgroundColor: MobyColors.surface,
                        shape: const CircleBorder(),
                        onPressed: _location,
                        child: const SourceIcon('ic_find_location', size: 24),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _UnavailableLocations extends StatelessWidget {
  const _UnavailableLocations({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  SourceBranchesContent.unavailableTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  SourceBranchesContent.unavailableBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: MobyColors.legacySecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  key: const ValueKey('branches-retry'),
                  onPressed: onRetry,
                  child: const Text(SourceBranchesContent.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SourceBranchesFilterPage extends StatefulWidget {
  const _SourceBranchesFilterPage({required this.initial});
  final SourceBranchesFilter initial;
  @override
  State<_SourceBranchesFilterPage> createState() =>
      _SourceBranchesFilterPageState();
}

class _SourceBranchesFilterPageState extends State<_SourceBranchesFilterPage> {
  late SourceBranchesFilter _draft = widget.initial;
  bool _regionOpen = false;
  bool _metroOpen = false;

  void _kind(SourceBranchKind kind, bool enabled) {
    final selected = {..._draft.kinds};
    enabled ? selected.add(kind) : selected.remove(kind);
    setState(() => _draft = _draft.copyWith(kinds: selected));
  }

  void _currency(SourceBranchCurrency currency, bool enabled) {
    final selected = {..._draft.currencies};
    enabled ? selected.add(currency) : selected.remove(currency);
    setState(() => _draft = _draft.copyWith(currencies: selected));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: SourceBranchesContent.back,
        onPressed: () => Navigator.of(context).pop(),
        icon: const SourceIcon('ic_app_bar_arrow', color: MobyColors.brand),
      ),
      titleSpacing: 0,
      title: const Text(SourceBranchesContent.filter),
      actions: [
        TextButton(
          key: const ValueKey('branches-filter-reset'),
          onPressed: () => setState(() => _draft = SourceBranchesFilter()),
          child: const Text(SourceBranchesContent.reset),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          SwitchListTile(
            key: const ValueKey('branches-working-now'),
            contentPadding: EdgeInsets.zero,
            secondary: const SourceIcon('ic_clock', size: 24),
            title: const Text(
              SourceBranchesContent.workingNow,
              style: TextStyle(fontSize: 17),
            ),
            value: _draft.workingNow,
            onChanged: (value) =>
                setState(() => _draft = _draft.copyWith(workingNow: value)),
          ),
          const SizedBox(height: 16),
          _UnknownChoices(
            title: SourceBranchesContent.region,
            open: _regionOpen,
            onTap: () => setState(() => _regionOpen = !_regionOpen),
          ),
          const SizedBox(height: 16),
          _UnknownChoices(
            title: SourceBranchesContent.metro,
            open: _metroOpen,
            onTap: () => setState(() => _metroOpen = !_metroOpen),
          ),
          const SizedBox(height: 24),
          const Text(
            SourceBranchesContent.services,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          for (final kind in SourceBranchKind.values)
            SwitchListTile(
              key: ValueKey('branches-kind-${kind.name}'),
              contentPadding: EdgeInsets.zero,
              secondary: const SourceIcon('ic_location_marker', size: 24),
              title: Text(
                SourceBranchesContent.kinds[kind]!,
                style: const TextStyle(fontSize: 17),
              ),
              value: _draft.kinds.contains(kind),
              onChanged: (value) => _kind(kind, value),
            ),
          const SizedBox(height: 16),
          const Text(
            SourceBranchesContent.currency,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          for (final currency in SourceBranchCurrency.values)
            SwitchListTile(
              key: ValueKey('branches-currency-${currency.name}'),
              contentPadding: EdgeInsets.zero,
              secondary: SourceIcon(
                SourceBranchesContent.currencyAssets[currency]!,
                size: 26,
              ),
              title: Text(
                SourceBranchesContent.currencies[currency]!,
                style: const TextStyle(fontSize: 17),
              ),
              value: _draft.currencies.contains(currency),
              onChanged: (value) => _currency(currency, value),
            ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: FilledButton(
              key: const ValueKey('branches-filter-apply'),
              onPressed: () => Navigator.of(context).pop(_draft),
              child: const Text(SourceBranchesContent.apply),
            ),
          ),
        ],
      ),
    ),
  );
}

class _UnknownChoices extends StatelessWidget {
  const _UnknownChoices({
    required this.title,
    required this.open,
    required this.onTap,
  });
  final String title;
  final bool open;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        button: true,
        expanded: open,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SourceIcon('ic_location_marker', size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 17)),
                ),
                RotatedBox(
                  quarterTurns: open ? 2 : 0,
                  child: const SourceIcon('ic_arrow_down', size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      if (open)
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            SourceBranchesContent.choicesUnavailable,
            style: TextStyle(fontSize: 13, color: MobyColors.legacySecondary),
          ),
        ),
    ],
  );
}
