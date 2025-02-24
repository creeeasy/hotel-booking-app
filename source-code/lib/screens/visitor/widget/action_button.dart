import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final BookingStatus bookingStatus;
  const ActionButton({super.key, required this.bookingStatus});

  @override
  Widget build(BuildContext context) {
    switch (bookingStatus) {
      case BookingStatus.cancelled:
        return const Text(
          "This hotel booking has been cancelled",
          style: TextStyle(
            color: VisitorThemeColors.cancelledTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        );

      case BookingStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color:
                VisitorThemeColors.bookingCompletedBackground.withOpacity(0.2),
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

      case BookingStatus.pending:
        return Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between buttons
          children: [
            _cancelButton(),
            _viewBookingButton(),
          ],
        );

      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center buttons
          children: [
            _cancelButton(),
            const SizedBox(width: 12),
            _viewBookingButton(),
          ],
        );
    }
  }

// Cancel Button
  Widget _cancelButton() {
    return OutlinedButton(
      onPressed: () => {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: VisitorThemeColors.viewBookingBackground),
        foregroundColor: VisitorThemeColors.viewBookingBackground,
        backgroundColor: VisitorThemeColors.cancelBackground,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "Cancel",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

// View Booking Button
  Widget _viewBookingButton() {
    return TextButton(
      onPressed: () => {},
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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
