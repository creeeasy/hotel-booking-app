// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/screens/visitor/widget/action_button.dart';
import 'package:fatiel/screens/visitor/widget/hotel_image_widget.dart';
import 'package:intl/intl.dart';

class HotelBookingCard extends StatefulWidget {
  final Hotel hotel;
  final Booking booking;
  final VoidCallback onAction;
  const HotelBookingCard(
      {super.key,
      required this.booking,
      required this.hotel,
      required this.onAction});

  @override
  State<HotelBookingCard> createState() => _HotelBookingCardState();
}

class _HotelBookingCardState extends State<HotelBookingCard> {
  late Hotel hotel;
  late Booking booking;
  late VoidCallback onAction;

  @override
  void initState() {
    hotel = widget.hotel;
    booking = widget.booking;
    onAction = widget.onAction;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: VisitorThemeColors.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () => Navigator.of(context)
                    .pushNamed(hotelDetailsRoute, arguments: hotel.id),
                child: ClipRRect(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: HotelImageWidget(images: hotel.images),
                  ),
                ),
              ),
              Positioned(
                bottom: 16, // Space around the bottom
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: _buildDateCard("Check-In", booking.checkInDate)),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            _buildDateCard("Check-Out", booking.checkOutDate)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hotel.hotelName,
            style: const TextStyle(
              fontFamily: "Poppins",

              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: VisitorThemeColors.vibrantOrange, // Deep & lively purple
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 18, color: VisitorThemeColors.greyColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hotel.location != null
                      ? Wilaya.fromIndex(hotel.location!)?.name ??
                          'Location not available'
                      : 'Location not available',
                  style: const TextStyle(
                    fontSize: 16,
                    color: VisitorThemeColors.greyColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: ActionButton(
              bookingStatus: booking.status,
              bookingId: booking.id,
              visitorId: booking.visitorId,
              hotelId: booking.hotelId,
              cancelBookingAction: onAction,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime date) {
    final String formattedDate = DateFormat("EEE, MMM d, yyyy").format(date);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: VisitorThemeColors.whiteColor
                .withOpacity(0.2), // Light gray background
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            color: VisitorThemeColors.whiteColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12), // Increased spacing
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VisitorThemeColors.whiteColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: VisitorThemeColors.whiteColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
