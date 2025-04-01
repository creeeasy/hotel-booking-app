import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/room_availability.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/image_gallery.dart';
import 'package:fatiel/services/room/room_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class RoomBookingOffersPage extends StatefulWidget {
  const RoomBookingOffersPage({super.key});

  @override
  State<RoomBookingOffersPage> createState() => _RoomBookingOffersPageState();
}

class _RoomBookingOffersPageState extends State<RoomBookingOffersPage> {
  late final ScrollController _scrollController;

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

  Future<List<Room>> _loadRooms() async {
    final hotelId = ModalRoute.of(context)?.settings.arguments as String?;
    return await RoomService.getHotelRoomsById(hotelId!);
  }

  Future<void> _refreshRooms() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: CustomBackAppBar(
        title: 'Explore room offers',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: ThemeColors.background,
      body: FutureBuilder<List<Room>>(
        future: _loadRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: ThemeColors.primary,
                strokeWidth: 2,
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
          final rooms = snapshot.data!;
          return RoomContent(
            rooms: rooms,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }
}

class RoomContent extends StatefulWidget {
  final List<Room> rooms;
  final ScrollController scrollController;
  const RoomContent(
      {super.key, required this.rooms, required this.scrollController});

  @override
  State<RoomContent> createState() => _RoomContentState();
}

class _RoomContentState extends State<RoomContent> {
  late Room _selectedRoom;
  late ScrollController _scrollController;
  void _selectRoom(Room room) {
    setState(() => _selectedRoom = room);
  }

  late List<Room> rooms;

  @override
  void initState() {
    rooms = widget.rooms;
    _selectedRoom = rooms.first;
    _scrollController = widget.scrollController;
    super.initState();
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
      builder: (context) => Dialog(
        backgroundColor: ThemeColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Booking',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 20),
              _buildBookingDetailRow(
                icon: Iconsax.house_2,
                label: 'Room Type',
                value: _selectedRoom.name,
              ),
              const SizedBox(height: 12),
              _buildBookingDetailRow(
                icon: Iconsax.calendar,
                label: 'Dates',
                value: '${DateFormat('MMM d, y').format(dateRange.start)} - '
                    '${DateFormat('MMM d, y').format(dateRange.end)}',
              ),
              const SizedBox(height: 12),
              _buildBookingDetailRow(
                icon: Iconsax.moon,
                label: 'Duration',
                value: '$duration night${duration > 1 ? 's' : ''}',
              ),
              const SizedBox(height: 12),
              _buildBookingDetailRow(
                icon: Iconsax.receipt,
                label: 'Total Price',
                value: '\$${totalPrice.toStringAsFixed(2)}',
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: ThemeColors.border),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: ThemeColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully booked ${_selectedRoom.name}!'),
          backgroundColor: ThemeColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      bottomNavigationBar: BookNowButton(
        onPressed: _bookRoom,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: RoomCarousel(
              rooms: rooms,
              selectedRoom: _selectedRoom,
              onRoomSelected: _selectRoom,
              scrollController: _scrollController,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                ImageGallery(images: _selectedRoom.images),
                const SizedBox(height: 20),
                _RoomHeader(room: _selectedRoom),
                const SizedBox(height: 12),
                _RoomDescription(description: _selectedRoom.description),
                const SizedBox(height: 24),
                const _SectionDivider(icon: Iconsax.category_2),
                const SizedBox(height: 16),
                const SectionTitle(
                    title: "Facilities", icon: Iconsax.category_2),
                const SizedBox(height: 12),
                RoomAmenities(amenities: _selectedRoom.amenities),
                const SizedBox(height: 24),
                const _SectionDivider(icon: Iconsax.calendar_tick),
                const SizedBox(height: 16),
                const SectionTitle(
                    title: "Availability", icon: Iconsax.calendar_tick),
                const SizedBox(height: 12),
                RoomAvailabilityCard(availability: _selectedRoom.availability),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ThemeColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 14,
                    color: ThemeColors.textPrimary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class RoomCarousel extends StatelessWidget {
  final List<Room> rooms;
  final Room selectedRoom;
  final ValueChanged<Room> onRoomSelected;
  final ScrollController scrollController;

  const RoomCarousel({
    super.key,
    required this.rooms,
    required this.selectedRoom,
    required this.onRoomSelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: RoomCard(
              room: room,
              isSelected: room.id == selectedRoom.id,
              onTap: () => onRoomSelected(room),
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
        duration: const Duration(milliseconds: 200),
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.primary.withOpacity(0.05)
              : ThemeColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ThemeColors.primary : ThemeColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? ThemeColors.primary : ThemeColors.textPrimary,
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
                  '${room.capacity} Guests',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Per night',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${room.pricePerNight.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  final Room room;

  const _RoomHeader({required this.room});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ThemeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Iconsax.profile_2user,
              size: 16,
              color: ThemeColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '${room.capacity} Guests',
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoomDescription extends StatelessWidget {
  final String description;

  const _RoomDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 14,
        color: ThemeColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}

class RoomAmenities extends StatelessWidget {
  final List<String> amenities;

  const RoomAmenities({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const _EmptyState(
        icon: Iconsax.close_circle,
        message: "No amenities listed",
        color: ThemeColors.warning,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenityData = AmenityIcons.getAmenity(amenities[index]);
        return Container(
          decoration: BoxDecoration(
            color: ThemeColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                amenityData?.label ?? amenities[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoomAvailabilityCard extends StatelessWidget {
  final RoomAvailability availability;

  const RoomAvailabilityCard({super.key, required this.availability});

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
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Column(
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
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final IconData icon;

  const _SectionDivider({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ThemeColors.primary),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(
            color: ThemeColors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({
    super.key,
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
            fontWeight: FontWeight.w600,
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.warning_2,
              size: 48,
              color: ThemeColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load rooms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: ThemeColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomEmptyView extends StatelessWidget {
  const RoomEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.house_2,
              size: 48,
              color: ThemeColors.grey400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No rooms available',
              style: TextStyle(
                fontSize: 18,
                color: ThemeColors.textSecondary,
              ),
            ),
          ],
        ),
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primary,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Book Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.white,
          ),
        ),
      ),
    );
  }
}
