// ignore_for_file: prefer_const_constructors

import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/screens/visitor/widget/action_button.dart';
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:fatiel/widgets/hotel/network_image_widget.dart';
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
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final Booking booking = snapshot.data!["booking"];
        final Hotel hotel = snapshot.data!["hotel"];

        return Card(
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
                    child: NetworkImageWithLoader(
                      imageUrl: (hotel.images?.isNotEmpty == true)
                          ? hotel.images!.first
                          : 'https://via.placeholder.com/400',
                    ),
                  ),
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
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
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
                Text(
                  "Price per night: \$${hotel.pricePerNight?.toStringAsFixed(2) ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: ActionButton(bookingStatus: booking.status),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
