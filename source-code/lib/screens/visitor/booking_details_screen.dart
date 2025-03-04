import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/info_card_widget.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
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
