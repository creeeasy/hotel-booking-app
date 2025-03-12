// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/hotel_booking_card.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:flutter/material.dart';

class BookingWidget extends StatelessWidget {
  final String bookingId;
  final VoidCallback onAction;

  const BookingWidget(
      {Key? key, required this.bookingId, required this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: Visitor.getBookingAndHotelById(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CardLoadingIndicator();
        } else if (snapshot.hasError) {
          return ErrorWidgetWithRetry(
            errorMessage: 'Error: ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return NoDataWidget(
            message: "Currently, there are no bookings for this hotel.",
          );
        }

        final Booking booking = snapshot.data!["booking"];
        final Hotel hotel = snapshot.data!["hotel"];
        return HotelBookingCard(
          booking: booking,
          hotel: hotel,
          onAction: onAction,
        );
      },
    );
  }
}
