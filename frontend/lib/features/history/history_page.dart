import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _query = '';
  OperationDirection? _direction;

  @override
  Widget build(BuildContext context) {
    final snapshot = watchBankSnapshot(ref);
    final items = snapshot.operations
        .where(
          (operation) =>
              (_direction == null || operation.direction == _direction) &&
              '${operation.title} ${operation.subtitle} ${snapshot.cards.where((card) => card.accountId == operation.accountId).map((card) => card.title).join(' ')}'
                  .toLowerCase()
                  .contains(_query.toLowerCase()),
        )
        .toList();
    return MobyPage(
      title: AppCopy.history,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      key: const ValueKey('history-search'),
                      onChanged: (value) => setState(() => _query = value),
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: AppCopy.search,
                        filled: true,
                        fillColor: Color(0xFFEFF5FB),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        prefixIcon: SourceIcon(
                          'ic_search',
                          size: 18,
                          color: MobyColors.legacySecondary,
                        ),
                        hintStyle: TextStyle(color: MobyColors.legacySecondary),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: AppCopy.filter,
                  onPressed: _showFilter,
                  icon: SourceIcon(
                    _direction == null
                        ? 'ic_filter_lines'
                        : 'ic_filter_lines_active',
                    width: 16,
                    height: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text(AppCopy.noOperations))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final operation = items[index];
                      final scenarioYear = ref
                          .read(bankRepositoryProvider)
                          .scenario
                          .actionTime
                          .year;
                      final day = formatHistoryDay(
                        operation.occurredAt,
                        scenarioYear: scenarioYear,
                      );
                      final newDay =
                          index == 0 ||
                          day !=
                              formatHistoryDay(
                                items[index - 1].occurredAt,
                                scenarioYear: scenarioYear,
                              );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (newDay)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                                bottom: 8,
                              ),
                              child: Text(
                                day,
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: MobyColors.secondary,
                                ),
                              ),
                            ),
                          OperationTile(
                            operation: operation,
                            horizontalPadding: 0,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilter() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in <(OperationDirection?, String)>[
                (null, AppCopy.allOperations),
                (OperationDirection.outgoing, AppCopy.onlyOutgoing),
                (OperationDirection.incoming, AppCopy.onlyIncoming),
              ])
                ListTile(
                  title: Text(option.$2),
                  trailing: _direction == option.$1
                      ? const Icon(Icons.check, color: MobyColors.brand)
                      : null,
                  onTap: () {
                    setState(() => _direction = option.$1);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OperationDetailsPage extends ConsumerWidget {
  const OperationDetailsPage({super.key, required this.operationId});
  final String operationId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = watchBankSnapshot(ref);
    final matches = snapshot.operations.where(
      (operation) => operation.id == operationId,
    );
    if (matches.isEmpty) {
      return const MobyPage(
        title: AppCopy.details,
        child: Center(child: Text(AppCopy.noItem)),
      );
    }
    final operation = matches.first;
    final account = snapshot.accountById(operation.accountId)!;
    final cards = snapshot.cards.where((card) => card.accountId == account.id);
    final product = cards.isEmpty ? account.title : cards.first.title;
    final cardNumber = cards.isEmpty ? '' : cards.first.maskedNumber;
    return MobyPage(
      title: AppCopy.details,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Divider(height: 1),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3FB),
                      shape: BoxShape.circle,
                    ),
                    child: SourceIcon(
                      operationIcon(operation),
                      color: MobyColors.legacyText,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    operation.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDateTime(operation.occurredAt),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: MobyColors.legacySecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatOperationAmount(operation),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (operation.sourceAmount case final Money amount)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  formatMoney(amount),
                  style: const TextStyle(
                    fontSize: 15,
                    color: MobyColors.legacySecondary,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _OperationField(AppCopy.account, '$product · $cardNumber'),
            _OperationField(
              AppCopy.operationType,
              operation.typeLabel ??
                  (switch (operation.category) {
                    OperationCategory.groceries ||
                    OperationCategory.shopping ||
                    OperationCategory.transport => AppCopy.purchaseType,
                    _ =>
                      operation.direction == OperationDirection.incoming
                          ? AppCopy.incoming
                          : AppCopy.outgoing,
                  }),
            ),
            if (operation.mcc case final int mcc)
              _OperationField(AppCopy.mcc, mcc.toString().padLeft(4, '0')),
            _OperationField(
              AppCopy.operationResult,
              switch (operation.status) {
                OperationStatus.completed => AppCopy.completed,
                OperationStatus.pending => AppCopy.pending,
                OperationStatus.declined => AppCopy.declined,
              },
              valueColor: switch (operation.status) {
                OperationStatus.completed => MobyColors.operationSuccess,
                OperationStatus.pending => MobyColors.legacySecondary,
                OperationStatus.declined => MobyColors.danger,
              },
            ),
            if (operation.note case final String note when note.isNotEmpty)
              _OperationField(AppCopy.message, note),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OperationField extends StatelessWidget {
  const _OperationField(this.label, this.value, {this.valueColor});
  final Color? valueColor;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 15, color: valueColor)),
        ],
      ),
    ),
  );
}
