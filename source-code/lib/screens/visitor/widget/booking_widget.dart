// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/screens/visitor/widget/action_button.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/hotel_image_widget.dart';
import 'package:fatiel/screens/visitor/widget/hotel_price_widget.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:flutter/material.dart';

class BookingWidget extends StatelessWidget {
  final String bookingId;

  const BookingWidget({Key? key, required this.bookingId}) : super(key: key);

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

        return InkWell(
          onTap: () => Navigator.of(context)
              .pushNamed(hotelDetailsRoute, arguments: hotel.id),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: HotelImageWidget(images: hotel.images)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hotel.hotelName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.location != null
                              ? Wilaya.fromIndex(hotel.location!)?.name ??
                                  'Location not available'
                              : 'Location not available',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (hotel.startingPricePerNight != null)
                    HotelPriceWidget(
                        startingPricePerNight: hotel.startingPricePerNight!),
                  const SizedBox(height: 14),
                  Center(
                    child: ActionButton(
                      bookingStatus: booking.status,
                      bookingId: booking.id,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
