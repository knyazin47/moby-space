import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/formatting/formatters.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/common.dart';
import '../../core/ui/demo_banner_card.dart';
import '../../core/ui/source_assets.dart';
import '../../data/bank_data.dart';
import '../recorded/recorded_forms.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = watchBankSnapshot(ref);
    final repository = ref.watch(bankRepositoryProvider);
    final inset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: ColoredBox(
        color: MobyColors.background,
        child: CustomScrollView(
          key: PageStorageKey('home-scroll-${ref.watch(demoSessionProvider)}'),
          slivers: [
            SliverPersistentHeader(
              key: const ValueKey('home-header'),
              pinned: true,
              delegate: _HomeHeader(
                topInset: inset,
                snapshot: snapshot,
                onEye: repository.toggleBalanceVisibility,
              ),
            ),
            SliverLayoutBuilder(
              builder: (context, constraints) => SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.viewportMainAxisExtent - (72 + inset),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      MobyMetrics.contentBottomPadding +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 57,
                          child: Row(
                            children: [
                              Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => context.push('/history'),
                                  child: const Tooltip(
                                    message: AppCopy.history,
                                    child: SizedBox(
                                      width: 57,
                                      height: 57,
                                      child: SourceIcon(
                                        'ic_clock_counter',
                                        color: MobyColors.brand,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (snapshot.operations.isNotEmpty)
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: 320,
                                      child: OperationTile(
                                        operation: snapshot.operations.first,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        for (
                          var i = 0;
                          i < repository.scenario.homeBanners.length;
                          i++
                        ) ...[
                          _DemoBanner(
                            banner: repository.scenario.homeBanners[i],
                            compact: i == 0,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => context.push('/apply-card'),
                            child: const SizedBox(
                              height: 184,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SourceIcon('ic_squircle', size: 40),
                                        SourceIcon(
                                          'ic_add_card_redesign',
                                          size: 40,
                                          color: MobyColors.brand,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    AppCopy.addCard,
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: MobyColors.brand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends SliverPersistentHeaderDelegate {
  _HomeHeader({
    required this.topInset,
    required this.snapshot,
    required this.onEye,
  });
  final double topInset;
  final BankSnapshot snapshot;
  final VoidCallback onEye;
  @override
  double get minExtent => 72 + topInset;
  @override
  double get maxExtent => 272 + topInset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final visibility = (1 - shrinkOffset / 120).clamp(0.0, 1.0);
    final card = snapshot.cards.first;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(MobyMetrics.headerRadius),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [MobyColors.headerTop, MobyColors.headerBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: topInset + 24,
                left: 32,
                right: 32,
                child: Row(
                  children: [
                    Material(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/profile'),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: SourceIcon('ic_user', color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        snapshot.profile.firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: topInset + 66,
                left: 32,
                right: 32,
                child: IgnorePointer(
                  ignoring: visibility < .5,
                  child: Opacity(
                    opacity: visibility,
                    child: Row(
                      children: [
                        _HeaderBadge(card.title),
                        const SizedBox(width: 6),
                        _HeaderBadge(card.maskedNumber),
                        IconButton(
                          onPressed: () => context.push('/card/${card.id}'),
                          icon: const SourceIcon(
                            'ic_info',
                            size: 16,
                            color: Colors.white,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topInset + 101,
                left: 32,
                right: 32,
                child: IgnorePointer(
                  ignoring: visibility < .5,
                  child: Opacity(
                    opacity: visibility,
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.balanceVisible
                                  ? formatMoney(snapshot.primaryAccount.balance)
                                  : '${AppCopy.hiddenBalance} ${snapshot.primaryAccount.balance.currency}',
                              key: const ValueKey('home-balance'),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: snapshot.balanceVisible
                              ? AppCopy.hideBalance
                              : AppCopy.showBalance,
                          onPressed: onEye,
                          icon: SourceIcon(
                            snapshot.balanceVisible
                                ? 'ic_eye_not_visible'
                                : 'ic_eye_visible',
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topInset + 164,
                left: 32,
                right: 32,
                child: IgnorePointer(
                  ignoring: visibility < .5,
                  child: Opacity(
                    opacity: visibility,
                    child: Row(
                      children: [
                        _HeaderAction(
                          label: AppCopy.refill,
                          icon: 'ic_card_refill',
                          onTap: () => context.push('/refill'),
                        ),
                        const SizedBox(width: 8),
                        _HeaderAction(
                          label: AppCopy.transfer,
                          icon: 'ic_transfer',
                          onTap: () => showRecordedTransferSheet(context),
                        ),
                        const SizedBox(width: 8),
                        _HeaderAction(
                          label: AppCopy.pay,
                          icon: 'ic_pay',
                          onTap: () => showRecordedPaymentSheet(context),
                        ),
                        const SizedBox(width: 8),
                        const _HeaderAction(
                          label: AppCopy.points,
                          icon: 'ic_cactus_action_gift',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeader old) =>
      old.snapshot != snapshot || old.topInset != topInset;
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
  );
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.label, required this.icon, this.onTap});
  final String label;
  final String icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Opacity(
      opacity: onTap == null ? .45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEBFE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SourceIcon(icon, color: MobyColors.brand, size: 24),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.banner, required this.compact});
  final DemoBanner banner;
  final bool compact;
  @override
  Widget build(BuildContext context) => DemoBannerCard(
    banner: banner,
    compact: compact,
    height: compact ? 72 : 120,
    onTap: () => context.push(banner.route),
  );
}
