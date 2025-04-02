import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/favorite_button_widget.dart';
import 'package:fatiel/widgets/rating_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FeaturedHotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback? onPressed;
  final bool showPremiumBadge;
  final double borderRadius;
  final double aspectRatio;
  final bool showFavoriteButton;
  final double elevation;

  const FeaturedHotelCard({
    super.key,
    required this.hotel,
    this.onPressed,
    this.showPremiumBadge = true,
    this.borderRadius = 16,
    this.aspectRatio = 16 / 9,
    this.showFavoriteButton = true,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    final locationName =
        hotel.location != null ? Wilaya.fromIndex(hotel.location!)?.name : null;

    return GestureDetector(
      onTap: onPressed ??
          () {
            Navigator.pushNamed(
              context,
              hotelDetailsRoute,
              arguments: hotel.id,
            );
          },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.grey800.withOpacity(0.1),
              blurRadius: elevation * 3,
              offset: Offset(0, elevation),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Hero Image with Gradient Overlay
              _buildHotelImage(hotel.images, context),

              // Content Overlay
              _buildContentOverlay(hotel, locationName, context),

              // Premium Badge (if applicable)
              if (showPremiumBadge && hotel.ratings.rating >= 4.5)
                _buildPremiumBadge(),

              // Favorite Button
              if (showFavoriteButton)
                Positioned(
                  top: 16,
                  right: 16,
                  child: FavoriteButton(
                    hotelId: hotel.id,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelImage(List<String> images, BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: ThemeColors.grey200, // Fallback background color
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main Image
            if (images.isNotEmpty)
              Image.network(
                images.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: ThemeColors.primary,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageErrorWidget(context),
              )
            else
              _buildImageErrorWidget(context),

            // Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      ThemeColors.black.withOpacity(0.8),
                      ThemeColors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 0.8],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.gallery_slash,
            size: 40,
            color: ThemeColors.grey400,
          ),
          const SizedBox(height: 8),
          Text(
            L10n.of(context).imageNotAvailable,
            style: const TextStyle(
              color: ThemeColors.grey600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentOverlay(
      Hotel hotel, String? locationName, BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              ThemeColors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Name
            Text(
              hotel.hotelName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ThemeColors.white,
                shadows: [
                  // <-- Fixed closing square bracket
                  Shadow(
                    color: ThemeColors.black.withOpacity(0.6),
                    blurRadius: 6,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Location and Rating Row
            Row(
              children: [
                // Location
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        size: 16,
                        color: ThemeColors.accentPink,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          locationName ?? L10n.of(context).locationNotSpecified,
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RatingBarWidget(
                        rating: hotel.ratings.rating,
                        size: 14,
                        activeColor: ThemeColors.star,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hotel.ratings.totalRating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ThemeColors.accentPink,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.crown_1,
              size: 14,
              color: ThemeColors.white,
            ),
            SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: ThemeColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
