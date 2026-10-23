import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/bank_data.dart';
import '../config/app_copy.dart';
import '../config/transfer_content.dart';
import '../formatting/formatters.dart';
import '../theme/app_theme.dart';
import 'source_assets.dart';

class RecordedCardThumbnail extends StatelessWidget {
  const RecordedCardThumbnail({super.key, required this.card});
  final DemoCard card;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 64,
    height: 40,
    child: card.artAssetPath != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image.asset(
              card.artAssetPath!,
              width: 64,
              height: 40,
              fit: BoxFit.cover,
            ),
          )
        : Stack(
            children: [
              const Positioned.fill(
                child: SourceIcon('small_card_default_background', size: 64),
              ),
              Positioned(
                right: 4,
                bottom: 3,
                child: SizedBox(
                  width: 20,
                  height: 12,
                  child: SourceIcon(
                    card.paymentSystem == 'Visa'
                        ? 'ic_visa'
                        : 'ic_mastercard_logo',
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
  );
}

/// The medium 2:1 card topology, with an accessibility height expansion.
class RecordedOwnCard extends StatelessWidget {
  const RecordedOwnCard({
    super.key,
    required this.card,
    required this.account,
    this.showBalance = true,
    this.onTap,
  });
  final DemoCard card;
  final DemoAccount account;
  final bool showBalance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = math.max(
        constraints.maxWidth / 2,
        MediaQuery.textScalerOf(
          context,
        ).scale(TransferCardMetrics.accessibleMinHeight),
      );
      final money = formatMoney(account.balance);
      final balance = showBalance
          ? money.substring(
              0,
              money.length - account.balance.currency.length - 1,
            )
          : AppCopy.hiddenBalance;
      return Material(
        color: const Color(TransferCardMetrics.cardSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TransferCardMetrics.cardRadius),
          side: const BorderSide(color: Color(TransferCardMetrics.cardBorder)),
        ),
        elevation: TransferCardMetrics.cardElevation,
        shadowColor: Colors.black12,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  right: 96,
                  child: Text(
                    card.title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: RecordedCardThumbnail(card: card),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: height * .36,
                  bottom: height * .25 + 8,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: balance,
                        children: [
                          const TextSpan(
                            text: ' ',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextSpan(
                            text: account.balance.currency,
                            style: const TextStyle(fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: height * .25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(TransferCardMetrics.cardDivider),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${card.maskedNumber} · ${card.expiresAt.month.toString().padLeft(2, '0')}/${(card.expiresAt.year % 100).toString().padLeft(2, '0')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: MobyColors.legacySecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            TransferContent.points,
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 30,
                          height: 16,
                          child: SourceIcon(
                            card.paymentSystem == 'Visa'
                                ? 'ic_visa'
                                : 'ic_mastercard_logo',
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Source medium pager. Selection belongs to the form, not the page controller.
class RecordedOwnCardPager extends StatefulWidget {
  const RecordedOwnCardPager({
    super.key,
    required this.snapshot,
    required this.selectedAccountId,
    required this.onSelected,
    required this.onOpenPicker,
    this.currency,
  });

  final BankSnapshot snapshot;
  final String selectedAccountId;
  final ValueChanged<String> onSelected;
  final VoidCallback onOpenPicker;
  final String? currency;

  @override
  State<RecordedOwnCardPager> createState() => _RecordedOwnCardPagerState();
}

class _RecordedOwnCardPagerState extends State<RecordedOwnCardPager> {
  late final PageController _controller;
  late int _reportedIndex;
  late double _page;
  int? _pendingIndex;

  List<DemoCard> get _cards => [
    for (final card in widget.snapshot.cards)
      if (widget.snapshot.accountById(card.accountId) != null &&
          (widget.currency == null ||
              widget.snapshot.accountById(card.accountId)!.balance.currency ==
                  widget.currency))
        card,
  ];

  int get _selectedIndex {
    final index = _cards.indexWhere(
      (card) => card.accountId == widget.selectedAccountId,
    );
    return math.max(0, index);
  }

  @override
  void initState() {
    super.initState();
    _reportedIndex = _selectedIndex;
    _page = _reportedIndex.toDouble();
    // Padding defines the viewport inset without changing this controller on
    // resize. The account id remains canonical when ListView remounts a page.
    _controller = PageController(initialPage: _reportedIndex, keepPage: false)
      ..addListener(_pageMoved);
  }

  void _pageMoved() {
    if (!mounted || !_controller.hasClients) return;
    final page = _controller.page ?? _reportedIndex.toDouble();
    if (page != _page) setState(() => _page = page);
  }

  @override
  void didUpdateWidget(covariant RecordedOwnCardPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _selectedIndex;
    if (target == _reportedIndex) return;
    _reportedIndex = target;
    _page = target.toDouble();
    _pendingIndex = target;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingIndex != target) return;
      if (_controller.hasClients) _controller.jumpToPage(target);
      _pendingIndex = null;
    });
  }

  void _selected(int index) {
    if (_pendingIndex != null && index != _pendingIndex) return;
    final cards = _cards;
    if (index >= cards.length) return;
    _reportedIndex = index;
    widget.onSelected(cards[index].accountId);
  }

  void _goTo(int index) {
    if (!_controller.hasClients) return;
    _controller.animateToPage(
      index,
      duration: TransferCardMetrics.pageNavigationDuration,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_pageMoved);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cards;
    if (cards.isEmpty) return const SizedBox.shrink();
    final multiple = cards.length > 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            constraints.maxWidth -
            2 *
                (TransferCardMetrics.pagerInset +
                    TransferCardMetrics.cardSideMargin);
        final cardHeight = math.max(
          cardWidth / 2,
          MediaQuery.textScalerOf(
            context,
          ).scale(TransferCardMetrics.accessibleMinHeight),
        );
        final pageHeight =
            cardHeight +
            TransferCardMetrics.cardTop +
            TransferCardMetrics.cardBottom;
        final totalHeight =
            pageHeight +
            (multiple
                ? -TransferCardMetrics.dotTopOverlap +
                      TransferCardMetrics.dotSize +
                      TransferCardMetrics.dotBottom
                : 0);
        return SizedBox(
          height: totalHeight,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: pageHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TransferCardMetrics.pagerInset,
                    ),
                    child: PageView.builder(
                      key: const ValueKey('transfer-own-card-pager'),
                      controller: _controller,
                      // Adjacent content can paint through the 12dp gutter;
                      // the outer ClipRect still clips at the full form width.
                      clipBehavior: Clip.none,
                      allowImplicitScrolling: true,
                      physics: multiple
                          ? null
                          : const NeverScrollableScrollPhysics(),
                      itemCount: cards.length,
                      onPageChanged: _selected,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return Padding(
                          key: ValueKey('transfer-own-card-${card.id}'),
                          padding: const EdgeInsets.fromLTRB(
                            TransferCardMetrics.cardSideMargin,
                            TransferCardMetrics.cardTop,
                            TransferCardMetrics.cardSideMargin,
                            TransferCardMetrics.cardBottom,
                          ),
                          child: RecordedOwnCard(
                            card: card,
                            account: widget.snapshot.accountById(
                              card.accountId,
                            )!,
                            showBalance: widget.snapshot.balanceVisible,
                            onTap: card.accountId == widget.selectedAccountId
                                ? widget.onOpenPicker
                                : () => _goTo(index),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (multiple)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height:
                        TransferCardMetrics.cardBottom -
                        TransferCardMetrics.dotTopOverlap +
                        TransferCardMetrics.dotSize +
                        TransferCardMetrics.dotBottom,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < cards.length; i++)
                          _dot(i, cards.length),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dot(int index, int count) {
    final weight = (1 - (_page - index).abs()).clamp(0.0, 1.0);
    return Semantics(
      label: TransferContent.cardPageLabel(index + 1, count),
      selected: index == _reportedIndex,
      button: true,
      child: GestureDetector(
        key: ValueKey('transfer-card-dot-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _goTo(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TransferCardMetrics.dotSideMargin,
          ),
          child: Center(
            child: Container(
              width:
                  TransferCardMetrics.dotSize *
                  (1 + (TransferCardMetrics.dotWidthFactor - 1) * weight),
              height: TransferCardMetrics.dotSize,
              decoration: BoxDecoration(
                color: Color.lerp(
                  const Color(TransferCardMetrics.dotInactive),
                  const Color(TransferCardMetrics.dotActive),
                  weight,
                ),
                borderRadius: BorderRadius.circular(
                  TransferCardMetrics.dotRadius,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecordedAccountCardRow extends StatelessWidget {
  const RecordedAccountCardRow({
    super.key,
    required this.card,
    required this.account,
    required this.visible,
    required this.onToggleVisibility,
    required this.onOpen,
    required this.dragHandle,
  });
  final DemoCard card;
  final DemoAccount account;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onOpen;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(
          width: 24,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minHeight: 48),
            tooltip: visible ? AppCopy.hideBalance : AppCopy.showBalance,
            onPressed: onToggleVisibility,
            icon: SourceIcon(
              visible ? 'ic_eye_open' : 'ic_eye_not_visible',
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: onOpen,
          child: RecordedCardThumbnail(card: card),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    visible
                        ? formatMoney(account.balance)
                        : AppCopy.hiddenBalance,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    TransferContent.points,
                    style: TextStyle(
                      fontSize: 12,
                      color: MobyColors.legacySecondary,
                    ),
                  ),
                  Text(
                    '${card.maskedNumber} · ${card.expiresAt.month.toString().padLeft(2, '0')}/${(card.expiresAt.year % 100).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        dragHandle,
      ],
    ),
  );
}

/// Drag-only visual control; assistive technology can invoke the same action.
class RecordedSwipeConfirm extends StatefulWidget {
  const RecordedSwipeConfirm({
    super.key,
    required this.enabled,
    required this.label,
    required this.semanticLabel,
    required this.onConfirm,
  });
  final bool enabled;
  final String label;
  final String semanticLabel;
  final bool Function() onConfirm;

  @override
  State<RecordedSwipeConfirm> createState() => _RecordedSwipeConfirmState();
}

class _RecordedSwipeConfirmState extends State<RecordedSwipeConfirm>
    with SingleTickerProviderStateMixin {
  late final _position = AnimationController(
    vsync: this,
    duration: TransferContent.swipeReturnDuration,
  );
  bool _canDrag = false;
  bool _confirmed = false;

  @override
  void didUpdateWidget(covariant RecordedSwipeConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      _canDrag = false;
      _position.value = 0;
    }
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _return() {
    _canDrag = false;
    _position.animateTo(0, curve: Curves.easeOut);
  }

  void _confirm() {
    if (!widget.enabled || _confirmed) return;
    _confirmed = true;
    _position.value = 1;
    if (!widget.onConfirm() && mounted) {
      _confirmed = false;
      _return();
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.enabled && !_confirmed,
    label: widget.semanticLabel,
    onTap: widget.enabled && !_confirmed ? _confirm : null,
    excludeSemantics: true,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final travel = math.max(
          1.0,
          constraints.maxWidth - TransferContent.swipeHeight,
        );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragDown: (details) {
            _canDrag =
                widget.enabled &&
                !_confirmed &&
                details.localPosition.dx <=
                    constraints.maxWidth * TransferContent.swipeStartZone;
            if (_canDrag) _position.stop();
          },
          onHorizontalDragUpdate: (details) {
            if (_canDrag) {
              _position.value = (_position.value + details.delta.dx / travel)
                  .clamp(0.0, 1.0);
            }
          },
          onHorizontalDragEnd: (_) {
            if (!_canDrag) return;
            if (_position.value >= TransferContent.swipeCompleteThreshold) {
              _confirm();
            } else {
              _return();
            }
          },
          onHorizontalDragCancel: _return,
          child: Container(
            height: TransferContent.swipeHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, _) => Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 52),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label,
                            maxLines: 2,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.1,
                              color: widget.enabled
                                  ? MobyColors.brand
                                  : MobyColors.navBorder,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                          color: widget.enabled
                              ? MobyColors.brand
                              : MobyColors.navBorder,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _position.value * travel,
                    top: 0,
                    bottom: 0,
                    width: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.enabled
                            ? MobyColors.brand
                            : MobyColors.rowBorder,
                      ),
                      child: SourceIcon(
                        'ic_drag_start_arrow',
                        size: 21.33,
                        color: widget.enabled
                            ? Colors.white
                            : MobyColors.navBorder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
