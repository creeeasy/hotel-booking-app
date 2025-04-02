import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/room.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RoomCardWidget extends StatelessWidget {
  final Room room;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const RoomCardWidget({
    Key? key,
    required this.room,
    required this.onTap,
    this.isSelected = false,
    this.width = 240,
    this.height = 180,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final priceColor =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary;

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.05)
            : theme.cardColor,
        borderRadius: cardBorderRadius,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: cardBorderRadius,
        child: InkWell(
          borderRadius: cardBorderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildRoomImage(),
                ),
                const SizedBox(height: 12),

                // Room Name
                Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 6),

                // Room Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Guest Capacity
                    Row(
                      children: [
                        Icon(
                          Iconsax.profile_2user,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${room.capacity} ${L10n.of(context).guests}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Row(
                      children: [
                        Icon(
                          Iconsax.dollar_circle,
                          size: 14,
                          color: priceColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${room.pricePerNight.toStringAsFixed(2)}/${L10n.of(context).night}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: priceColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Amenities (if any)
                if (room.amenities.isNotEmpty) ...[
                  _buildAmenitiesChips(),
                  const SizedBox(height: 8),
                ],

                // Availability Badge
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildAvailabilityBadge(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomImage() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: room.images.isNotEmpty
          ? Image.network(
              room.images[0],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Iconsax.gallery_slash,
        size: 32,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildAmenitiesChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: room.amenities.take(2).map((amenity) {
        return Chip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          backgroundColor: Colors.blueGrey.withOpacity(0.1),
          side: BorderSide.none,
          label: Text(
            amenity,
            style: const TextStyle(fontSize: 10),
          ),
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: room.availability.isAvailable
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: room.availability.isAvailable ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            room.availability.isAvailable
                ? Iconsax.tick_circle
                : Iconsax.close_circle,
            size: 12,
            color: room.availability.isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            room.availability.isAvailable
                ? L10n.of(context).available
                : L10n.of(context).unavailable,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: room.availability.isAvailable ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
