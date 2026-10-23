import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/family_session.dart';
import '../../core/config/app_copy.dart';
import '../../core/config/family_content.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/source_assets.dart';
import '../../core/ui/demo_banner_card.dart';
import '../../core/ui/native_progress.dart';
import '../../core/config/demo_motion.dart';
import '../../data/bank_data.dart';
import '../../data/family/family_store.dart';
import '../family/family_widgets.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _bannerController = PageController(
    viewportFraction: MobyMetrics.productPagerViewportFraction,
  );
  int _selectedBanner = 0;
  int? _loadingBanner = 0;
  Timer? _bannerTimer;
  @override
  void initState() {
    super.initState();
    _finishBannerLoad();
  }

  void _finishBannerLoad() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer(DemoMotion.bannerLoad, () {
      if (mounted) setState(() => _loadingBanner = null);
    });
  }

  void _selectBanner(int index) {
    setState(() {
      _selectedBanner = index;
      _loadingBanner = index;
    });
    _finishBannerLoad();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = ref.watch(bankRepositoryProvider).scenario;
    final family = familyApiEnabled ? null : ref.watch(familyProvider);

    return ColoredBox(
      color: MobyColors.productsBackground,
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 160),
              children: [
                if (scenario.productBanners.isNotEmpty) ...[
                  SizedBox(
                    height: MobyMetrics.productBannerHeight,
                    child: PageView.builder(
                      key: const ValueKey('products-carousel'),
                      controller: _bannerController,
                      itemCount: scenario.productBanners.length,
                      onPageChanged: _selectBanner,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _loadingBanner == index
                            ? ClipRRect(
                                key: ValueKey('product-banner-loading-$index'),
                                borderRadius: BorderRadius.circular(
                                  MobyMetrics.productBannerRadius,
                                ),
                                child: const ColoredBox(
                                  color: Colors.white,
                                  child: Center(child: NativeProgress()),
                                ),
                              )
                            : _ProductBanner(
                                banner: scenario.productBanners[index],
                                onTap: () => context.push(
                                  scenario.productBanners[index].route,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (
                        var i = 0;
                        i < scenario.productBannerIndicatorCount;
                        i++
                      ) ...[
                        if (i > 0) const SizedBox(width: 1.5),
                        GestureDetector(
                          key: ValueKey('product-banner-dot-$i'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _bannerController.animateToPage(
                            i,
                            duration: DemoMotion.routeTransition,
                            curve: Curves.easeOutCubic,
                          ),
                          child: Container(
                            width: i == _selectedBanner ? 9.5 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.5),
                              color: i == _selectedBanner
                                  ? const Color(0xFF202020)
                                  : MobyColors.navBorder,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                for (var i = 0; i < scenario.products.length; i++) ...[
                  if (i == 3)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Divider(height: 1),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ProductRow(
                      product: scenario.products[i],
                      onTap: () => context.push(scenario.products[i].route),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (!familyApiEnabled) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Divider(height: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: FamilySectionLabel(FamilyContent.familySection),
                  ),
                  for (final child in family!.children)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: ChildCard(child: child),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ProductRow(
                      product: _addChildProduct,
                      onTap: () => context.push('/family'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 78,
              child: FilledButton.icon(
                onPressed: () =>
                    _showApplySheet(context, scenario.applyProducts),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: MobyColors.surface,
                  foregroundColor: MobyColors.legacyText,
                  elevation: 1,
                  shadowColor: Colors.black12,
                  side: const BorderSide(color: MobyColors.rowBorder),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const SourceIcon('ic_add_card'),
                label: const Text(AppCopy.apply),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplySheet(BuildContext context, List<DemoProduct> products) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: MobyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .75,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              const Text(
                AppCopy.apply,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              for (final product in products)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _ProductRow(
                    product: product,
                    applySheet: true,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      context.push(product.route);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductBanner extends StatelessWidget {
  const _ProductBanner({required this.banner, required this.onTap});

  final DemoBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DemoBannerCard(
    banner: banner,
    height: MobyMetrics.productBannerHeight,
    onTap: onTap,
  );
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.onTap,
    this.applySheet = false,
  });

  final DemoProduct product;
  final VoidCallback onTap;
  final bool applySheet;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SourceIcon(_productIcon(product)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MobyColors.legacyText,
                        ),
                      ),
                      ...[
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: applySheet
                                ? MobyColors.legacySecondary
                                : MobyColors.text90,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

const _addChildProduct = DemoProduct(
  id: 'family-add-child',
  title: FamilyContent.addChild,
  description: FamilyContent.addChildDescription,
  iconName: 'ic_add_card',
  route: '/family',
);

String _productIcon(DemoProduct product) {
  if (product.iconName.startsWith('ic_')) return product.iconName;
  return switch (product.id) {
    'apply-halva' => 'ic_halva',
    'apply-salary' => 'ic_salary_card',
    'apply-card-account' => 'ic_new_card',
    'apply-credit' => 'ic_new_credit',
    'apply-deposit' => 'ic_deposits',
    _ => switch (product.iconName) {
      'credit_card' => 'ic_cards',
      'payments' => 'ic_wallet',
      'savings' => 'ic_deposits',
      'description' => 'ic_product_requests',
      _ => product.iconName,
    },
  };
}
