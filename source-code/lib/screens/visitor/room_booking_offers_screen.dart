import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/room_availability.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class RoomBookingOffersPage extends StatefulWidget {
  const RoomBookingOffersPage({super.key});

  @override
  State<RoomBookingOffersPage> createState() => _RoomBookingOffersPageState();
}

class _RoomBookingOffersPageState extends State<RoomBookingOffersPage> {
  final String _hotelId = "dHNQ0AKCIrWeqpKR81Q0fbfORZM2";
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Room>> _fetchRooms() async {
    return await Room.getHotelRoomsById(_hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      body: SafeArea(
        child: FutureBuilder<List<Room>>(
          future: _fetchRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: VisitorThemeColors.primaryColor,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ErrorView(
                onRetry: () => setState(() {}),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const _EmptyView();
            }

            return _RoomListView(
              rooms: snapshot.data!,
              scrollController: _scrollController,
            );
          },
        ),
      ),
    );
  }
}

class _RoomListView extends StatefulWidget {
  final List<Room> rooms;
  final ScrollController scrollController;

  const _RoomListView({
    required this.rooms,
    required this.scrollController,
  });

  @override
  State<_RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<_RoomListView> {
  int _currentIndex = 0;

  void _updateSelectedIndex(int index) {
    setState(() => _currentIndex = index);
    _scrollToSelectedRoom(index);
  }

  void _scrollToSelectedRoom(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scrollPosition = (240 * index - (screenWidth / 2 - 120)).clamp(
      0.0,
      widget.scrollController.position.maxScrollExtent,
    );
    widget.scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _bookNow(Room room) async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: VisitorThemeColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      final duration = dateRange.end.difference(dateRange.start).inDays;
      final totalPrice = room.pricePerNight * duration;

      // Show booking confirmation dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room: ${room.name}'),
              const SizedBox(height: 8),
              Text(
                  'Dates: ${DateFormat('MMM d, y').format(dateRange.start)} - ${DateFormat('MMM d, y').format(dateRange.end)}'),
              const SizedBox(height: 8),
              Text('Duration: $duration night${duration > 1 ? 's' : ''}'),
              const SizedBox(height: 8),
              Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VisitorThemeColors.primaryColor,
              ),
              onPressed: () {
                // Here you would typically send the booking to your backend
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully booked ${room.name}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoom = widget.rooms[_currentIndex];
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom App Bar
        _CustomAppBar(
          title: 'Room Offers',
          onBack: () => Navigator.pop(context),
        ),

        // Room Selection Carousel
        _RoomSelectionCarousel(
          rooms: widget.rooms,
          currentIndex: _currentIndex,
          scrollController: widget.scrollController,
          onIndexChanged: _updateSelectedIndex,
        ),

        // Room Details
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Images
                _RoomImagesCarousel(images: selectedRoom.images),
                const SizedBox(height: 24),

                // Room Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedRoom.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: VisitorThemeColors.deepBlueAccent,
                              ),
                            ),
                          ),
                          Text(
                            '\$${selectedRoom.pricePerNight.toStringAsFixed(2)}/night',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: VisitorThemeColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Capacity
                      Row(
                        children: [
                          const Icon(Iconsax.profile_2user,
                              size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Text(
                            '${selectedRoom.capacity} guests',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: VisitorThemeColors.textGreyColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        selectedRoom.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: VisitorThemeColors.textGreyColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider with icon
                      const _SectionDivider(icon: Iconsax.category),
                      const SizedBox(height: 16),

                      // Amenities
                      const _SectionTitle(
                        title: "Facilities",
                        icon: Iconsax.category,
                      ),
                      const SizedBox(height: 12),
                      _AmenitiesGrid(amenities: selectedRoom.amenities),
                      const SizedBox(height: 24),

                      // Divider with icon
                      const _SectionDivider(icon: Iconsax.calendar),
                      const SizedBox(height: 16),

                      // Availability
                      const _SectionTitle(
                        title: "Availability",
                        icon: Iconsax.calendar_tick,
                      ),
                      const SizedBox(height: 12),
                      _AvailabilityCard(
                          availability: selectedRoom.availability),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Booking Button
        _BookingButton(
          room: selectedRoom,
          onPressed: () => _bookNow(selectedRoom),
        ),
      ],
    );
  }
}

// Custom App Bar Component
class _CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _CustomAppBar({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: onBack,
            iconSize: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: VisitorThemeColors.deepBlueAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// Room Selection Carousel Component
class _RoomSelectionCarousel extends StatelessWidget {
  final List<Room> rooms;
  final int currentIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onIndexChanged;

  const _RoomSelectionCarousel({
    required this.rooms,
    required this.currentIndex,
    required this.scrollController,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _RoomCard(
              room: rooms[index],
              isSelected: currentIndex == index,
              onTap: () => onIndexChanged(index),
            ),
          );
        },
      ),
    );
  }
}

// Room Card Component
class _RoomCard extends StatelessWidget {
  final Room room;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 240,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.withOpacity(0.2),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey.shade200,
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
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Iconsax.gallery_slash,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Iconsax.gallery_slash,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // Room Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? selectedColor
                          : VisitorThemeColors.deepBlueAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.profile_2user,
                          size: 14, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(
                        "${room.capacity} Guests",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "\$${room.pricePerNight.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? selectedColor
                              : VisitorThemeColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Room Images Carousel Component
class _RoomImagesCarousel extends StatelessWidget {
  final List<String> images;

  const _RoomImagesCarousel({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Iconsax.gallery_slash,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Iconsax.gallery_slash,
                        size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Section Divider Component
class _SectionDivider extends StatelessWidget {
  final IconData icon;

  const _SectionDivider({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: VisitorThemeColors.primaryColor),
        const Expanded(
          child: Divider(
            color: VisitorThemeColors.primaryColor,
            thickness: 1,
            indent: 8,
          ),
        ),
      ],
    );
  }
}

// Section Title Component
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: VisitorThemeColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: VisitorThemeColors.deepBlueAccent,
          ),
        ),
      ],
    );
  }
}

// Amenities Grid Component
class _AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;

  const _AmenitiesGrid({required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const _EmptyState(
        icon: Iconsax.close_circle,
        message: "No amenities listed",
        color: Colors.orange,
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((amenity) {
        final amenityData = AmenityIcons.getAmenity(amenity);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: VisitorThemeColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  amenityData?.icon ?? Iconsax.info_circle,
                  size: 20,
                  color: VisitorThemeColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amenityData?.label ?? amenity,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Availability Card Component
class _AvailabilityCard extends StatelessWidget {
  final RoomAvailability availability;

  const _AvailabilityCard({required this.availability});

  @override
  Widget build(BuildContext context) {
    final isAvailable = availability.nextAvailableDate != null;
    final color = isAvailable ? Colors.green : Colors.red;
    final icon = isAvailable ? Iconsax.calendar_tick : Iconsax.calendar_remove;
    final message = isAvailable
        ? "Available from ${DateFormat('MMM d, y').format(availability.nextAvailableDate!)}"
        : "Not currently available";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? "Available" : "Unavailable",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (isAvailable)
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Booking Button Component
class _BookingButton extends StatelessWidget {
  final Room room;
  final VoidCallback onPressed;

  const _BookingButton({
    required this.room,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: VisitorThemeColors.primaryColor,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: const Text(
          'Book Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Empty State Component
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Error View Component
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load room data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: VisitorThemeColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Empty View Component
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.house_2, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No rooms available at this time',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
