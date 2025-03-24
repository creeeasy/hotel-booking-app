// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key});

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  Future<Map<String, dynamic>?> fetchBookingDetails(
      BuildContext context) async {
    final bookingId = ModalRoute.of(context)?.settings.arguments as String;
    final data = await Visitor.getBookingAndHotelById(bookingId);
    return data;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: fetchBookingDetails(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicatorWidget(
                indicatorColor: VisitorThemeColors.viewBookingBackground,
                containerColor: VisitorThemeColors.whiteColor,
              );
            } else if (snapshot.hasError) {
              return ErrorWidgetWithRetry(
                errorMessage: 'Error: ${snapshot.error}',
              );
            } else if (!snapshot.hasData) {
              return const NoDataWidget(
                message: "No hotel listings found.",
              );
            }

            final hotel = snapshot.data!["hotel"] as Hotel;
            final booking = snapshot.data!["booking"] as Booking;
            final room = snapshot.data!["room"] as Room;

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final currentVisitor = state.currentUser as Visitor;

                return Scaffold(
                  backgroundColor: VisitorThemeColors.whiteColor,
                  appBar: CustomBackAppBar(
                    title: "Booking Summary",
                    titleColor: VisitorThemeColors.emeraldGreen,
                    iconColor: VisitorThemeColors.emeraldGreen,
                    onBack: () => Navigator.pop(context),
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildVisitorInfo(currentVisitor),
                        const SizedBox(height: 16),
                        _buildCheckInCheckOutSection(booking),
                        const SizedBox(height: 16),
                        _buildTotalPriceSection(booking),
                        const SizedBox(height: 16),
                        _buildRoomWidget(room, booking),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, hotelDetailsRoute,
                                arguments: booking.hotelId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VisitorThemeColors
                                .deepBlueAccent, // Change to your defined deep blue color
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.info,
                              size: 20, color: Colors.white), // Changed icon
                          label: const Text(
                            "Explore Hotel Info", // Updated text
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  /// **Current Visitor Section**
  Widget _buildVisitorInfo(Visitor visitor) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: VisitorThemeColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("First Name", "${visitor.firstName}"),
          _buildInfoRow("Last Name", "${visitor.lastName}"),
          _buildInfoRow("Email", visitor.email),
        ],
      ),
    );
  }

  Widget _buildCheckInCheckOutSection(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: VisitorThemeColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booking Dates",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: VisitorThemeColors.textGreyColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100, // Adjust height dynamically based on content
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: _buildDateCard("Check-In", booking.checkInDate)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildDateCard("Check-Out", booking.checkOutDate)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime date) {
    final String formattedDate = DateFormat("EEE, MMM d, yyyy").format(date);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VisitorThemeColors.lightGrayColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: VisitorThemeColors.textGreyColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: VisitorThemeColors.textGreyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: VisitorThemeColors.blackColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **Total Price & Number of Guests Section**
  Widget _buildTotalPriceSection(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: VisitorThemeColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              "Total Price", "\$${booking.totalPrice.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  /// **Reusable Info Row**
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: VisitorThemeColors.textGreyColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: VisitorThemeColors.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomWidget(Room room, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: VisitorThemeColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// **Room Title**
          Text(
            room.name,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: VisitorThemeColors.deepBlueAccent,
            ),
          ),

          const SizedBox(height: 8),

          /// **Room Details**
          _buildInfoRow("Guest Capacity", "${room.capacity} people"),
          _buildInfoRow(
            "Days Booked",
            "${booking.checkOutDate.difference(booking.checkInDate).inDays} nights",
          ),
          _buildInfoRow(
              "Rate Per Night", "\$${room.pricePerNight.toStringAsFixed(2)}"),

          const SizedBox(height: 8),

          /// **Amenities Section**
          /// **Amenities Section**
          Text(
            "Included Amenities",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: VisitorThemeColors.deepBlueAccent,
            ),
          ),

          const SizedBox(height: 6),

          /// **List of Amenities (Each on a Separate Line)**
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: room.amenities.map((item) {
              final amenityData = AmenityIcons.getAmenity(item);

              if (amenityData == null)
                return const SizedBox(); // Handle null case safely

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      amenityData.icon,
                      color: VisitorThemeColors.radiantPink,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amenityData.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: VisitorThemeColors.radiantPink,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// **Reusable Info Row**
}
