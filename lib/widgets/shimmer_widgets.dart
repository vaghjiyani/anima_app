import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/responsive_helper.dart';

/// Shimmer loading widget for anime cards in horizontal lists
/// Used in: home_page.dart (Trending, Top Anime, Manga sections)
class ShimmerAnimeCard extends StatelessWidget {
  const ShimmerAnimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
        child: Container(
          width: 120, // Same width as real anime card
          height: 180, // Same height as real anime card
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading widget for banner cards
/// Used in: home_page.dart (Featured section)
class ShimmerBannerCard extends StatelessWidget {
  const ShimmerBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
        child: Container(
          width: isDesktop ? 350 : 300, // Fixed width based on screen size
          height: ResponsiveHelper.getBannerHeight(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading widget for search result cards
/// Used in: search_page.dart
class ShimmerSearchResultCard extends StatelessWidget {
  const ShimmerSearchResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster shimmer
              Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // Info shimmer
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle shimmer
                      Container(
                        width: 150,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Type badge shimmer
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Score shimmer
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
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
  }
}

/// Shimmer loading widget for image placeholders
/// Used in: anime_detail_page.dart, cached_network_image placeholders
class ShimmerImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(0),
        ),
      ),
    );
  }
}
