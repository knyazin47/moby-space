import 'package:flutter/material.dart';

import '../../data/demo/demo_scenario.dart';
import '../theme/app_theme.dart';

/// Offer copy stays visible independently of the interchangeable illustration.
/// A single accessible button and the whole card share the existing route action.
class DemoBannerCard extends StatelessWidget {
  const DemoBannerCard({
    super.key,
    required this.banner,
    required this.height,
    required this.onTap,
    this.compact = false,
  });

  final DemoBanner banner;
  final double height;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${banner.title}. ${banner.description}. ${banner.actionLabel}',
    onTap: onTap,
    excludeSemantics: true,
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: MobyColors.surface,
        borderRadius: BorderRadius.circular(MobyMetrics.productBannerRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 8 : 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 12 : 14,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: compact ? 2 : 4),
                      Flexible(
                        child: Text(
                          banner.description,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 10 : 11,
                            height: 1.1,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 2 : 4),
                      Text(
                        banner.actionLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 10 : 11,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: MobyColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: compact ? 48 : 72,
                  child: Image.asset(
                    banner.assetPath,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
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
