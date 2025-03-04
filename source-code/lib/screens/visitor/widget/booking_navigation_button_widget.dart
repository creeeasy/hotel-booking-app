import 'dart:developer';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingNavigationButtonWidget extends StatefulWidget {
  final Room room;

  const BookingNavigationButtonWidget({Key? key, required this.room})
      : super(key: key);

  @override
  _BookingNavigationButtonWidgetState createState() =>
      _BookingNavigationButtonWidgetState();
}

class _BookingNavigationButtonWidgetState
    extends State<BookingNavigationButtonWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isConfirming = false;
  double _totalPrice = 0.0;
  late Room room;
  late double pricePerNight;

  @override
  void initState() {
    super.initState();
    room = widget.room;
    pricePerNight = room.pricePerNight;
  }

  Future<bool> showTotalPriceDialog({
    required BuildContext context,
  }) async {
    return await showGenericDialog<bool>(
      context: context,
      title: 'Confirm Booking',
      content: '''
Departure Date: ${_startDate!.toLocal().toString().split(' ')[0]}
Destination Date: ${_endDate!.toLocal().toString().split(' ')[0]}
Total Price: \$${_totalPrice.toStringAsFixed(2)}

Do you want to proceed with the payment?''',
      optionBuilder: () => {
        'Cancel': false,
        'Confirm & Pay': true,
      },
    ).then((value) => value ?? false);
  }

  Future<void> _bookNow() async {
    DateTime today = DateTime.now();
    DateTime initialDate = room.availability.nextAvailableDate != null &&
            room.availability.nextAvailableDate!.isAfter(today)
        ? room.availability.nextAvailableDate!
        : today;

    DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2100),
      helpText: "Select Check-in Date",
      cancelText: "Cancel",
      confirmText: "Next",
    );

    if (pickedStartDate == null || !mounted) return;

    DateTime minEndDate = pickedStartDate.add(const Duration(days: 1));

    DateTime? pickedEndDate = await showDatePicker(
      context: context,
      initialDate: minEndDate,
      firstDate: minEndDate,
      lastDate: DateTime(2100),
      helpText: "Select Check-out Date",
      cancelText: "Cancel",
      confirmText: "Confirm",
    );

    if (pickedEndDate != null && mounted) {
      setState(() {
        _startDate = pickedStartDate;
        _endDate = pickedEndDate;
        _isConfirming = true;
        _totalPrice =
            pricePerNight * pickedEndDate.difference(pickedStartDate).inDays;
      });
    }
  }

  void _confirmBooking({required String visitorId}) async {
    if (_startDate != null && _endDate != null) {
      final confirmBooking = await showTotalPriceDialog(context: context);

      if (confirmBooking) {
        final result = await Booking.createBooking(
          hotelId: room.hotelId,
          roomId: room.id,
          visitorId: visitorId,
          checkInDate: _startDate!,
          checkOutDate: _endDate!,
          totalPrice: _totalPrice,
        );

        if (result is BookingSuccess) {
          log("Booking confirmed: ${result.booking}");

          setState(() {
            _startDate = null;
            _endDate = null;
            _isConfirming = false;
            _totalPrice = 0.0;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Booking confirmed successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result is BookingFailure) {
          log("Booking failed: ${result.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = room.availability.isAvailable &&
        room.availability.nextAvailableDate != null;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentVisitorId = (state.currentUser as Visitor).id;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${room.pricePerNight.toStringAsFixed(2)} / night",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ElevatedButton(
                onPressed: isAvailable
                    ? (_isConfirming
                        ? () => _confirmBooking(visitorId: currentVisitorId)
                        : _bookNow)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAvailable ? VisitorThemeColors.pinkAccent : Colors.grey,
                  minimumSize: const Size(140, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isAvailable
                      ? (_isConfirming ? "Confirm" : "Book Now")
                      : "Unavailable",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
