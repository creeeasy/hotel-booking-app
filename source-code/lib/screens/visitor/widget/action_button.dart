import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/services/stream/visitor_bookings_stream.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final BookingStatus bookingStatus;
  final String? bookingId;
  const ActionButton({super.key, required this.bookingStatus, this.bookingId});

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

      default:
        return Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between buttons
          children: [
            _cancelButton(context, bookingId!),
            _viewBookingButton(),
          ],
        );
    }
  }

// Cancel Button
  Future<bool> showCancelBookingDialog(BuildContext context) async {
    return await showGenericDialog<bool>(
      context: context,
      title: 'Cancel Booking',
      content: 'Are you sure you want to cancel this booking?',
      optionBuilder: () => {'No': false, 'Yes, Cancel': true},
    ).then((value) => value ?? false);
  }

  Widget _cancelButton(BuildContext context, String bookingId) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isLoading = false;

        return OutlinedButton(
          onPressed: () async {
            final shouldCancel = await showCancelBookingDialog(context);
            if (!shouldCancel) return;

            setState(() => isLoading = true);

            bool isCanceled =
                await VisitorBookingsStream.cancelBooking(bookingId);

            setState(() => isLoading = false);

            if (isCanceled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking canceled successfully.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to cancel booking.')),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
                color: VisitorThemeColors.viewBookingBackground),
            foregroundColor: VisitorThemeColors.viewBookingBackground,
            backgroundColor: VisitorThemeColors.cancelBackground,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VisitorThemeColors.viewBookingBackground,
                  ),
                )
              : const Text(
                  "Cancel",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
        );
      },
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
