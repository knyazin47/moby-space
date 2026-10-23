import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

import 'package:go_router/go_router.dart';

import '../../data/bank_data.dart';
import '../config/app_copy.dart';
import '../formatting/formatters.dart';
import '../theme/app_theme.dart';
import 'source_assets.dart';
import 'replay_loading.dart';

class MobyPage extends StatelessWidget {
  const MobyPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.replayLoad = false,
    this.titleMaxLines = 1,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool replayLoad;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: AppCopy.back,
        icon: const SourceIcon('ic_app_bar_arrow', color: MobyColors.brand),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      titleSpacing: 0,
      title: Text(
        title,
        maxLines: titleMaxLines,
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
    ),
    body: SafeArea(
      top: false,
      child: replayLoad ? ReplayBodyLoading(child: child) : child,
    ),
  );
}

String operationIcon(DemoOperation operation) => switch (operation.category) {
  OperationCategory.income || OperationCategory.topUp => 'ic_operation_refill',
  OperationCategory.transfer ||
  OperationCategory.groceries ||
  OperationCategory.shopping ||
  OperationCategory.transport => 'ic_operation_transfer',
};

class OperationTile extends ConsumerWidget {
  const OperationTile({
    super.key,
    required this.operation,
    this.horizontalPadding = 8,
  });
  final double horizontalPadding;
  final DemoOperation operation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = watchBankSnapshot(
      ref,
    ).cards.where((card) => card.accountId == operation.accountId);
    final productLabel = cards.isEmpty ? operation.subtitle : cards.first.title;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Material(
        color: MobyColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/operation/${operation.id}'),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            child: Row(
              children: [
                ...[
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const SourceIcon('ic_squircle', size: 40),
                        Center(
                          child: SourceIcon(
                            operationIcon(operation),
                            color: MobyColors.brand,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: SourceIcon(switch (operation.status) {
                            OperationStatus.completed =>
                              'ic_operation_item_success',
                            OperationStatus.pending =>
                              'ic_operation_item_waiting',
                            OperationStatus.declined =>
                              'ic_operation_item_failure',
                          }, size: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        operation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: MobyColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MobyColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatOperationAmount(operation),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: operation.direction == OperationDirection.incoming
                        ? MobyColors.historyIncoming
                        : MobyColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardFace extends StatelessWidget {
  const CardFace({
    super.key,
    required this.card,
    required this.account,
    this.showBalance = true,
  });
  final DemoCard card;
  final DemoAccount account;
  final bool showBalance;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [MobyColors.headerTop, MobyColors.headerBottom],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  card.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                card.paymentSystem,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            showBalance ? formatMoney(account.balance) : AppCopy.hiddenBalance,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  card.maskedNumber,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Text(
                '${card.expiresAt.month.toString().padLeft(2, '0')}/${(card.expiresAt.year % 100).toString().padLeft(2, '0')}',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
