import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/InfoCard.dart';
import 'package:flutter/material.dart';

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
    return FutureBuilder(
      future: fetchBookingDetails(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                VisitorThemeColors.viewBookingBackground,
              ),
            ),
          ));
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Hotel not found')),
          );
        }
        final hotelData = snapshot.data!["hotel"] as Hotel;
        final bookingData = snapshot.data!["booking"] as Booking;

        return InfoCard(
          hotel: hotelData,
          booking: bookingData,
        );
      },
    );
  }
}
