import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/room_availability.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class RoomBookingOffersPage extends StatefulWidget {
  const RoomBookingOffersPage({
    super.key,
  });

  @override
  State<RoomBookingOffersPage> createState() => _RoomBookingOffersPageState();
}

class _RoomBookingOffersPageState extends State<RoomBookingOffersPage> {
  final String hotelId = "dHNQ0AKCIrWeqpKR81Q0fbfORZM2";

  late final ScrollController _scrollController;
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _roomsFuture = Room.getHotelRoomsById(hotelId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshRooms() async {
    setState(() {
      _roomsFuture = Room.getHotelRoomsById(hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomBackAppBar(
          title: 'Room Offers',
          onBack: () => Navigator.of(context).pop(),
        ),
        backgroundColor: ThemeColors.background,
        body: FutureBuilder<List<Room>>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ThemeColors.primary,
                ),
              );
            }

            if (snapshot.hasError) {
              return RoomErrorView(
                error: snapshot.error.toString(),
                onRetry: _refreshRooms,
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const RoomEmptyView();
            }

            return RoomListView(
              rooms: snapshot.data!,
              scrollController: _scrollController,
            );
          },
        ),
      ),
    );
  }
}

class RoomListView extends StatefulWidget {
  final List<Room> rooms;
  final ScrollController scrollController;

  const RoomListView({
    super.key,
    required this.rooms,
    required this.scrollController,
  });

  @override
  State<RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> {
  int _selectedRoomIndex = 0;
  late Room _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.rooms.first;
  }

  void _selectRoom(int index) {
    setState(() {
      _selectedRoomIndex = index;
      _selectedRoom = widget.rooms[index];
    });
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

  Future<void> _bookRoom() async {
    final dateRange = await showDateRangePicker(
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
              primary: ThemeColors.primary,
              onPrimary: ThemeColors.textOnPrimary,
              surface: ThemeColors.white,
              onSurface: ThemeColors.textPrimary,
            ),
            dialogBackgroundColor: ThemeColors.white,
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      await _confirmBooking(dateRange);
    }
  }

  Future<void> _confirmBooking(DateTimeRange dateRange) async {
    final duration = dateRange.end.difference(dateRange.start).inDays;
    final totalPrice = _selectedRoom.pricePerNight * duration;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            color: ThemeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${_selectedRoom.name}'),
            const SizedBox(height: 8),
            Text(
              'Dates: ${DateFormat('MMM d, y').format(dateRange.start)} - '
              '${DateFormat('MMM d, y').format(dateRange.end)}',
            ),
            const SizedBox(height: 8),
            Text('Duration: $duration night${duration > 1 ? 's' : ''}'),
            const SizedBox(height: 8),
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ThemeColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: ThemeColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully booked ${_selectedRoom.name}!'),
            backgroundColor: ThemeColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RoomCarousel(
          rooms: widget.rooms,
          selectedIndex: _selectedRoomIndex,
          scrollController: widget.scrollController,
          onRoomSelected: _selectRoom,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoomGallery(images: _selectedRoom.images),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RoomHeader(room: _selectedRoom),
                      const SizedBox(height: 16),
                      _RoomDescription(description: _selectedRoom.description),
                      const SizedBox(height: 24),
                      const _SectionDivider(icon: Iconsax.category),
                      const SizedBox(height: 16),
                      const _SectionTitle(
                        title: "Facilities",
                        icon: Iconsax.category,
                      ),
                      const SizedBox(height: 12),
                      RoomAmenities(amenities: _selectedRoom.amenities),
                      const SizedBox(height: 24),
                      const _SectionDivider(icon: Iconsax.calendar),
                      const SizedBox(height: 16),
                      const _SectionTitle(
                        title: "Availability",
                        icon: Iconsax.calendar_tick,
                      ),
                      const SizedBox(height: 12),
                      RoomAvailabilityCard(
                          availability: _selectedRoom.availability),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        BookNowButton(
          onPressed: _bookRoom,
        ),
      ],
    );
  }
}

class RoomCarousel extends StatelessWidget {
  final List<Room> rooms;
  final int selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onRoomSelected;

  const RoomCarousel({
    super.key,
    required this.rooms,
    required this.selectedIndex,
    required this.scrollController,
    required this.onRoomSelected,
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
            child: RoomCard(
              room: rooms[index],
              isSelected: selectedIndex == index,
              onTap: () => onRoomSelected(index),
            ),
          );
        },
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final Room room;
  final bool isSelected;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 240,
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ThemeColors.primary : ThemeColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow.withOpacity(isSelected ? 0.2 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: RoomThumbnail(images: room.images),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.profile_2user,
                        size: 14,
                        color: ThemeColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${room.capacity} Guests",
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "\$${room.pricePerNight.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primary,
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

class RoomThumbnail extends StatelessWidget {
  final List<String> images;

  const RoomThumbnail({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: ThemeColors.grey100,
      child: images.isEmpty
          ? const Center(
              child: Icon(
                Iconsax.gallery_slash,
                size: 32,
                color: ThemeColors.grey400,
              ),
            )
          : Image.network(
              images.first,
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
                    color: ThemeColors.primary,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Iconsax.gallery_slash,
                  size: 32,
                  color: ThemeColors.grey400,
                ),
              ),
            ),
    );
  }
}

class RoomGallery extends StatelessWidget {
  final List<String> images;

  const RoomGallery({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 200,
        color: ThemeColors.grey100,
        child: const Center(
          child: Icon(
            Iconsax.gallery_slash,
            size: 48,
            color: ThemeColors.grey400,
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
                  color: ThemeColors.grey100,
                  child: const Center(
                    child: Icon(
                      Iconsax.gallery_slash,
                      size: 48,
                      color: ThemeColors.grey400,
                    ),
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

class _RoomHeader extends StatelessWidget {
  final Room room;

  const _RoomHeader({
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            room.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.textPrimary,
                ),
          ),
        ),
        Text(
          '\$${room.pricePerNight.toStringAsFixed(2)}/night',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeColors.primary,
              ),
        ),
      ],
    );
  }
}

class _RoomDescription extends StatelessWidget {
  final String description;

  const _RoomDescription({
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: ThemeColors.textSecondary,
          ),
    );
  }
}

class RoomAmenities extends StatelessWidget {
  final List<String> amenities;

  const RoomAmenities({
    super.key,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const _EmptyState(
        icon: Iconsax.close_circle,
        message: "No amenities listed",
        color: ThemeColors.warning,
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
            color: ThemeColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.shadow.withOpacity(0.05),
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
                  color: ThemeColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  amenityData?.icon ?? Iconsax.info_circle,
                  size: 20,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amenityData?.label ?? amenity,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class RoomAvailabilityCard extends StatelessWidget {
  final RoomAvailability availability;

  const RoomAvailabilityCard({
    super.key,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = availability.nextAvailableDate != null;
    final color = isAvailable ? ThemeColors.success : ThemeColors.error;
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
                      color: ThemeColors.textSecondary,
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

class BookNowButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BookNowButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: const Text(
          'Book Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final IconData icon;

  const _SectionDivider({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ThemeColors.primary),
        const Expanded(
          child: Divider(
            color: ThemeColors.border,
            thickness: 1,
            indent: 8,
          ),
        ),
      ],
    );
  }
}

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
        Icon(icon, size: 20, color: ThemeColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

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

class RoomErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const RoomErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, size: 48, color: ThemeColors.error),
          const SizedBox(height: 16),
          const Text(
            'Failed to load rooms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ThemeColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: ThemeColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class RoomEmptyView extends StatelessWidget {
  const RoomEmptyView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.house_2, size: 48, color: ThemeColors.grey400),
          SizedBox(height: 16),
          Text(
            'No rooms available at this time',
            style: TextStyle(
              fontSize: 18,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
