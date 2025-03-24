import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/room_availability.dart';
import 'package:fatiel/screens/visitor/widget/booking_navigation_button_widget.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/details_image_with_hero_widget.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/screens/visitor/widget/room_card_widget.dart';
import 'package:fatiel/screens/visitor/widget/section_title_widget.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoomBookingOffersPage extends StatefulWidget {
  const RoomBookingOffersPage({super.key});

  @override
  State<RoomBookingOffersPage> createState() => _RoomBookingOffersPageState();
}

class _RoomBookingOffersPageState extends State<RoomBookingOffersPage> {
  String? hotelId;

  Future<List<Room>> initializeRoomsData(BuildContext context) async {
    final hotelId = ModalRoute.of(context)?.settings.arguments as String?;
    return await Room.getHotelRoomsById(hotelId!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomBackAppBar(
          title: 'Explore room offers',
          onBack: () => Navigator.pop(context),
        ),
        body: FutureBuilder<List<Room>>(
          future: initializeRoomsData(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicatorWidget(
                indicatorColor: VisitorThemeColors.deepBlueAccent,
                containerColor: VisitorThemeColors.whiteColor,
              );
            }
            if (snapshot.hasError) {
              return ErrorWidgetWithRetry(
                errorMessage: 'Error: ${snapshot.error}',
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const NoDataWidget(
                message: "No room listings found.",
              );
            }

            final rooms = snapshot.data!;

            return BuildRoomList(rooms: rooms);
          },
        ),
      ),
    );
  }
}

class BuildRoomList extends StatefulWidget {
  final List<Room> rooms;
  const BuildRoomList({super.key, required this.rooms});

  @override
  State<BuildRoomList> createState() => _BuildRoomListState();
}

class _BuildRoomListState extends State<BuildRoomList> {
  int currentIndex = 0;
  late List<Room> rooms;

  void updateSelectedIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _bookNow() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Handle the selected date
      print("Selected Date: ${pickedDate.toLocal()}");
    }
  }

  @override
  void initState() {
    rooms = widget.rooms;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Room selectedRoom = rooms[currentIndex];
    return Scaffold(
      bottomNavigationBar: BookingNavigationButtonWidget(
          key: ValueKey(currentIndex), room: selectedRoom),
      body: _buildRoomDetails(selectedRoom),
    );
  }

  Widget _buildRoomDetails(Room selectedRoom) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        color: VisitorThemeColors.whiteColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoomSelection(),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DividerWidget(),
                    DetailsImageWithHero(
                      images: selectedRoom.images,
                      hotelId: null,
                    ),
                    const DividerWidget(),

                    SectionTitle(title: selectedRoom.name),

                    // Room Capacity
                    Row(
                      children: [
                        const Icon(Icons.people,
                            color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          "Capacity: ${selectedRoom.capacity} guests",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: VisitorThemeColors.textGreyColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Room Description
                    Text(
                      selectedRoom.description,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: VisitorThemeColors.textGreyColor,
                      ),
                    ),

                    const DividerWidget(),

                    const SectionTitle(title: "What this place offers"),
                    _buildAmenities(selectedRoom),

                    const DividerWidget(),

                    const SectionTitle(title: "Upcoming Availability"),
                    _buildAvailibility(selectedRoom.availability),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomSelection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          rooms.length,
          (index) => GestureDetector(
            onTap: () => updateSelectedIndex(index),
            child: RoomCardWidget(
              key: ValueKey(currentIndex),
              room: rooms[index],
              isSelected: currentIndex == index,
              jumpToIndex: () => updateSelectedIndex(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmenities(Room selectedRoom) {
    if (selectedRoom.amenities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 10),
            Text(
              "No facilities available",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: selectedRoom.amenities.map((item) {
            var facility = AmenityIcons.getAmenity(item);
            return Container(
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      facility!.icon, // Use the FontAwesome icon here
                      size: 32,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    facility.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAvailibility(RoomAvailability roomAvailability) {
    if (roomAvailability.nextAvailableDate != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_available, color: Colors.blue, size: 24),
            const SizedBox(width: 10),
            Text(
              "Available From: ${DateFormat.yMMMMd().format(roomAvailability.nextAvailableDate!)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 10),
            Text(
              "Availability Unknown",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      );
    }
  }
}
