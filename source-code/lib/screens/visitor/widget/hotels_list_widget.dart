import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/widgets/hotel_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HotelsListWidget extends StatelessWidget {
  final List<Hotel> hotels;
  final String? title;
  final bool showCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const HotelsListWidget({
    super.key,
    required this.hotels,
    this.title = "Hotels Found",
    this.showCount = true,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          if (title != null) _buildHeaderSection(),
          const SizedBox(height: 16),

          // Hotels List
          if (hotels.isEmpty) _buildEmptyState(),
          if (hotels.isNotEmpty) _buildHotelsList(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title with Icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.building_4,
                size: 20,
                color: ThemeColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeColors.textPrimary,
              ),
            ),
          ],
        ),

        // Hotel Count
        if (showCount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${hotels.length} ${hotels.length == 1 ? 'hotel' : 'hotels'}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.building_4,
              size: 48,
              color: ThemeColors.grey400,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Hotels Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search filters",
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelsList() {
    return Expanded(
      child: ListView.separated(
        physics: physics ?? const BouncingScrollPhysics(),
        shrinkWrap: shrinkWrap,
        itemCount: hotels.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return HotelCard(
            hotelId: hotels[index].id,
          );
        },
      ),
    );
  }
}
