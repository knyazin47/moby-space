import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/config/transfer_content.dart';
import '../../core/ui/common.dart';
import '../../core/ui/recorded_cards.dart';
import '../../core/ui/source_assets.dart';

class CardsPage extends ConsumerStatefulWidget {
  const CardsPage({super.key});
  @override
  ConsumerState<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends ConsumerState<CardsPage> {
  List<String> _order = [];
  final _visibility = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    final snapshot = watchBankSnapshot(ref);
    final known = snapshot.cards.map((card) => card.id).toSet();
    final ids = [
      ..._order.where(known.contains),
      ...known.where((id) => !_order.contains(id)),
    ];
    final cards = [
      for (final id in ids) snapshot.cards.firstWhere((card) => card.id == id),
    ];
    void move(int oldIndex, int newIndex) {
      if (newIndex < 0 || newIndex >= cards.length) return;
      final updated = [...ids];
      updated.insert(newIndex, updated.removeAt(oldIndex));
      setState(() => _order = updated);
    }

    return MobyPage(
      title: AppCopy.cards,
      actions: [
        IconButton(
          tooltip: AppCopy.addCard,
          onPressed: () => context.go('/products'),
          icon: const SourceIcon('ic_add_card'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 8, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FE),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  TransferContent.cards,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: cards.length,
                  proxyDecorator: (child, index, animation) => Material(
                    color: const Color(0xFFEFF4FE),
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                  onReorderItem: move,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return RecordedAccountCardRow(
                      key: ValueKey(card.id),
                      card: card,
                      account: snapshot.accountById(card.accountId)!,
                      visible: _visibility[card.id] ?? snapshot.balanceVisible,
                      onToggleVisibility: () => setState(() {
                        _visibility[card.id] =
                            !(_visibility[card.id] ?? snapshot.balanceVisible);
                      }),
                      onOpen: () => context.push('/card/${card.id}'),
                      dragHandle: Semantics(
                        label: TransferContent.reorder,
                        customSemanticsActions: {
                          if (index > 0)
                            const CustomSemanticsAction(
                              label: TransferContent.moveEarlier,
                            ): () =>
                                move(index, index - 1),
                          if (index < cards.length - 1)
                            const CustomSemanticsAction(
                              label: TransferContent.moveLater,
                            ): () =>
                                move(index, index + 1),
                        },
                        child: ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 16,
                            ),
                            child: SourceIcon('ic_drag_and_drop', size: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardDetailsPage extends ConsumerWidget {
  const CardDetailsPage({super.key, required this.cardId});
  final String cardId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = watchBankSnapshot(ref);
    final cards = snapshot.cards.where((card) => card.id == cardId);
    if (cards.isEmpty) {
      return const MobyPage(
        title: AppCopy.card,
        child: Center(child: Text(AppCopy.noItem)),
      );
    }
    final card = cards.first;
    final account = snapshot.accountById(card.accountId)!;
    return MobyPage(
      title: card.title,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RecordedOwnCard(
            card: card,
            account: account,
            showBalance: snapshot.balanceVisible,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () =>
                      context.push('/refill?account=${account.id}'),
                  child: const Text(AppCopy.refill),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      context.push('/transfer?account=${account.id}'),
                  child: const Text(AppCopy.transfer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(AppCopy.account),
            subtitle: Text(account.maskedNumber),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(AppCopy.cardHolder),
            subtitle: Text(card.holderName),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  AppCopy.history,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/history'),
                child: const Text(AppCopy.allHistory),
              ),
            ],
          ),
          for (final operation
              in snapshot.operations
                  .where((operation) => operation.accountId == account.id)
                  .take(3))
            OperationTile(operation: operation),
        ],
      ),
    );
  }
}
