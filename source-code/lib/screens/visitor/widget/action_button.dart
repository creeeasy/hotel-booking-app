import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/screens/visitor/widget/cancel_button_widget.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final BookingStatus bookingStatus;
  final String? bookingId;

  const ActionButton({super.key, required this.bookingStatus, this.bookingId});

  @override
  Widget build(BuildContext context) {
    if (bookingStatus == BookingStatus.cancelled) {
      return const Text(
        "This hotel booking has been cancelled",
        style: TextStyle(
          color: VisitorThemeColors.cancelledTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (bookingStatus == BookingStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: VisitorThemeColors.bookingCompletedBackground.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          "Booking Completed",
          style: TextStyle(
            color: VisitorThemeColors.bookingCompletedTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CancelButton(bookingId: bookingId!),
        _viewBookingButton(context),
      ],
    );
  }

  Future<bool> showCancelBookingDialog(BuildContext context) async {
    return await showGenericDialog<bool>(
      context: context,
      title: 'Cancel Booking',
      content: 'Are you sure you want to cancel this booking?',
      optionBuilder: () => {'No': false, 'Yes, Cancel': true},
    ).then((value) => value ?? false);
  }

  Widget _viewBookingButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, bookingDetailsViewRoute,
          arguments: bookingId),
      style: TextButton.styleFrom(
        backgroundColor: VisitorThemeColors.viewBookingBackground,
        foregroundColor: VisitorThemeColors.viewBookingTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "View Booking",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
