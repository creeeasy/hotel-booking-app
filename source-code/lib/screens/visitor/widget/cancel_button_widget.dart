// ignore_for_file: use_build_context_synchronously

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/services/stream/visitor_bookings_stream.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final String bookingId;
  final VoidCallback onCancelBooking;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  CancelButton(
      {super.key, required this.bookingId, required this.onCancelBooking});

  Future<void> _cancelBooking(BuildContext context) async {
    final shouldCancel = await showGenericDialog<bool>(
      context: context,
      title: 'Cancel Booking',
      content: 'Are you sure you want to cancel this booking?',
      optionBuilder: () => {'No': false, 'Yes, Cancel': true},
    );

    if (shouldCancel != true) return;

    isLoading.value = true;

    bool isCanceled = await VisitorBookingsStream.cancelBooking(bookingId);

    isLoading.value = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(isCanceled
              ? 'Booking canceled successfully.'
              : 'Failed to cancel booking.')),
    );
    if (isCanceled) onCancelBooking();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, child) {
        return OutlinedButton(
          onPressed: loading ? null : () => _cancelBooking(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: VisitorThemeColors.deepBlueAccent),
            foregroundColor: VisitorThemeColors.deepBlueAccent,
            backgroundColor: VisitorThemeColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: VisitorThemeColors.deepBlueAccent,
                  ),
                )
              : const Text("Cancel",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        );
      },
    );
  }
}
