import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/screens/visitor/widget/booking_hotel_details_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class InfoCard extends StatelessWidget {
  final Hotel hotel;
  final Booking booking;

  const InfoCard({super.key, required this.hotel, required this.booking});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentVisitor = state.currentUser as Visitor;

        return Scaffold(
          backgroundColor: VisitorThemeColors.whiteColor,
          appBar: AppBar(
            backgroundColor: VisitorThemeColors.whiteColor,
            elevation: 0,
            leading: IconButton(
              color: VisitorThemeColors.blackColor,
              icon: const Icon(
                Icons.chevron_left,
                size: 32, // Matching Visitor screen
              ),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
            centerTitle: true,
            title: const Text(
              'Booking Summary',
              style: TextStyle(
                color: VisitorThemeColors.blackColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVisitorInfo(currentVisitor),
                const SizedBox(height: 16),
                BookingHotelCard(
                  hotel: hotel,
                ),
                const SizedBox(height: 16),
                _buildCheckInCheckOutSection(),
                const SizedBox(height: 16),
                _buildTotalPriceSection(),
              ],
            ),
          ),
        );
      },
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

  Widget _buildCheckInCheckOutSection() {
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
  Widget _buildTotalPriceSection() {
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
          _buildInfoRow("Number of Guests", booking.numberOfGuests.toString()),
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
}
