import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/config/app_copy.dart';
import '../../core/ui/common.dart';

/// Local readable detail for each captured public banner. The original tap
/// destination was not recorded; this is explicitly a prototype continuation.
class SourceOfferPage extends ConsumerWidget {
  const SourceOfferPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(bankRepositoryProvider).scenario.productBanners;
    final matches = offers.where((item) => item.id == id);
    if (matches.isEmpty) {
      return const MobyPage(
        title: AppCopy.productInfo,
        child: Center(child: Text(AppCopy.noItem)),
      );
    }
    final offer = matches.first;
    return MobyPage(
      title: offer.title,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              offer.assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            offer.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            offer.description,
            style: const TextStyle(fontSize: 17, height: 1.3),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => context.push('/apply-card'),
            child: const Text(AppCopy.applyCard),
          ),
        ],
      ),
    );
  }
}

/// Local entry to the six captured Halva campaigns. Runtime web destinations
/// and product eligibility were not recorded; the catalog is not fabricated.
class SourceHalvaOffersPage extends ConsumerWidget {
  const SourceHalvaOffersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MobyPage(
    title: AppCopy.halva,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final offer
            in ref.watch(bankRepositoryProvider).scenario.productBanners)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push(offer.route),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(offer.assetPath, fit: BoxFit.contain),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        offer.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
