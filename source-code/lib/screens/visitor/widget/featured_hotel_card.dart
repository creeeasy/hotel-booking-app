import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
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

  const FeaturedHotelCard({
    super.key,
    required this.hotel,
    this.onPressed,
    this.showPremiumBadge = true,
    this.borderRadius = 20,
    this.aspectRatio = 16 / 9,
    this.showFavoriteButton = true,
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
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // Hero Image with Gradient Overlay
              _buildHotelImage(hotel.images),

              // Content Overlay
              _buildContentOverlay(hotel, locationName),

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

  Widget _buildHotelImage(List<String> images) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: Colors.grey[200], // Fallback background color
        child: Stack(
          fit: StackFit.expand, // Ensure the stack fills the container
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
                      color: VisitorThemeColors.deepBlueAccent,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageErrorWidget(),
              )
            else
              _buildImageErrorWidget(),

            // Gradient Overlay - more pronounced at the bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8), // Darker at bottom
                      Colors.black.withOpacity(0.3),
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

  Widget _buildImageErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.gallery_slash, size: 40, color: Colors.grey[500]),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentOverlay(Hotel hotel, String? locationName) {
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
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hotel Name
          Text(
            hotel.hotelName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 6,
                  offset: Offset(1, 1),
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
                      color: VisitorThemeColors.vibrantOrange,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        locationName ?? 'Location not specified',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
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
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RatingBarWidget(
                      rating: hotel.ratings.rating,
                      size: 14,
                      activeColor: VisitorThemeColors.secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel.ratings.totalRating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
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
          color: VisitorThemeColors.vibrantOrange,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
