import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/widgets/hotel_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HotelsListWidget extends StatelessWidget {
  final List<Hotel> hotels;
  final String? title;
  final bool showCount;

  const HotelsListWidget({
    super.key,
    required this.hotels,
    this.title = "Hotels Found",
    this.showCount = true,
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
                color: VisitorThemeColors.deepBlueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.building_4,
                size: 20,
                color: VisitorThemeColors.deepBlueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VisitorThemeColors.blackColor,
              ),
            ),
          ],
        ),

        // Hotel Count
        if (showCount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: VisitorThemeColors.deepBlueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${hotels.length} ${hotels.length == 1 ? 'hotel' : 'hotels'}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: VisitorThemeColors.deepBlueAccent,
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
            Icon(
              Iconsax.building_4,
              size: 48,
              color: VisitorThemeColors.textGreyColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No Hotels Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VisitorThemeColors.textGreyColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search filters",
              style: TextStyle(
                fontSize: 14,
                color: VisitorThemeColors.textGreyColor.withOpacity(0.7),
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
        physics: const BouncingScrollPhysics(),
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
