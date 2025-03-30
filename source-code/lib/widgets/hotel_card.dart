import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/favorite_button_widget.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/widgets/rating_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HotelCard extends StatefulWidget {
  final String hotelId;
  final VoidCallback? onPressed;
  final bool showPremiumBadge;
  final double borderRadius;
  final double aspectRatio;

  const HotelCard({
    super.key,
    required this.hotelId,
    this.onPressed,
    this.showPremiumBadge = true,
    this.borderRadius = 20,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Hotel?>(
      future: Hotel.getHotelById(widget.hotelId),
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        // Error State
        if (snapshot.hasError) {
          return ErrorWidgetWithRetry(
            errorMessage: 'Failed to load hotel details',
            onRetry: () => setState(() {}),
          );
        }

        // Empty State
        if (!snapshot.hasData) {
          return const NoDataWidget(
            message: "Hotel information not available",
          );
        }

        final hotel = snapshot.data!;
        final locationName = hotel.location != null
            ? Wilaya.fromIndex(hotel.location!)?.name
            : null;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              hotelDetailsRoute,
              arguments: hotel.id,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  // Hero Image with Gradient Overlay
                  _buildHotelImage(hotel.images),

                  // Content Overlay
                  _buildContentOverlay(hotel, locationName),

                  // Premium Badge (if applicable)
                  if (widget.showPremiumBadge && hotel.ratings.rating >= 4.5)
                    _buildPremiumBadge(),

                  // Favorite Button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FavoriteButton(
                      hotelId: widget.hotelId,
                      size: 28,
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

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            color: ThemeColors.grey200,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ThemeColors.accentDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelImage(List<String> images) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        color: ThemeColors.grey200, // Fallback background
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
                      color: ThemeColors.accentDeep,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageErrorWidget(),
              )
            else
              _buildImageErrorWidget(),

            // Enhanced Gradient Overlay
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

  Widget _buildImageErrorWidget() {
    return Container(
      color: ThemeColors.grey200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.gallery_slash, size: 40, color: ThemeColors.grey500),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: ThemeColors.grey600,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ThemeColors.white,
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

            const SizedBox(height: 8),

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
                          locationName ?? 'Location not specified',
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
                        activeColor: ThemeColors.secondary,
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

            // Additional Info (if available)
            if (hotel.totalRooms != null) ...[
              const SizedBox(height: 8),
              Text(
                '${hotel.totalRooms} rooms available',
                style: TextStyle(
                  fontSize: 13,
                  color: ThemeColors.white.withOpacity(0.8),
                ),
              ),
            ],
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
