import 'dart:developer';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/booking/booking_service.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class BookingNavigationButtonWidget extends StatefulWidget {
  final Room room;
  final VoidCallback? onBookingSuccess;

  const BookingNavigationButtonWidget({
    Key? key,
    required this.room,
    this.onBookingSuccess,
  }) : super(key: key);

  @override
  State<BookingNavigationButtonWidget> createState() =>
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

  Future<bool> _showTotalPriceDialog() async {
    return await showGenericDialog<bool>(
      context: context,
      title: L10n.of(context).confirmBooking,
      content: '''
      ${L10n.of(context).checkInDate}: ${DateFormat('MMM d, y').format(_startDate!)}
      ${L10n.of(context).checkOutDate}: ${DateFormat('MMM d, y').format(_endDate!)}
      ${L10n.of(context).totalNights}: ${_endDate!.difference(_startDate!).inDays}
      ${L10n.of(context).totalPrice}: \$${_totalPrice.toStringAsFixed(2)}''',
      optionBuilder: () => {
        L10n.of(context).cancel: false,
        L10n.of(context).confirmAndPay: true,
      },
    ).then((value) => value ?? false);
  }

  Future<void> _selectDates() async {
    final today = DateTime.now();
    final initialDate = room.availability.nextAvailableDate != null &&
            room.availability.nextAvailableDate!.isAfter(today)
        ? room.availability.nextAvailableDate!
        : today;

    final pickedStartDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2100),
      helpText: L10n.of(context).selectCheckInDate,
      cancelText: L10n.of(context).cancel,
      confirmText: L10n.of(context).next,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.primary,
              onPrimary: ThemeColors.white,
              surface: ThemeColors.white,
              onSurface: ThemeColors.textPrimary,
            ),
            dialogBackgroundColor: ThemeColors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedStartDate == null || !mounted) return;

    final minEndDate = pickedStartDate.add(const Duration(days: 1));

    final pickedEndDate = await showDatePicker(
      context: context,
      initialDate: minEndDate,
      firstDate: minEndDate,
      lastDate: DateTime(2100),
      helpText: L10n.of(context).selectCheckOutDate,
      cancelText: L10n.of(context).cancel,
      confirmText: L10n.of(context).confirm,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeColors.primary,
              onPrimary: ThemeColors.white,
              surface: ThemeColors.white,
              onSurface: ThemeColors.textPrimary,
            ),
            dialogBackgroundColor: ThemeColors.white,
          ),
          child: child!,
        );
      },
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

  Future<void> _confirmBooking({required String visitorId}) async {
    if (_startDate == null || _endDate == null) return;

    final confirmBooking = await _showTotalPriceDialog();

    if (confirmBooking) {
      final result = await BookingService.createBooking(
        hotelId: room.hotelId,
        roomId: room.id,
        visitorId: visitorId,
        checkInDate: _startDate!,
        checkOutDate: _endDate!,
        totalPrice: _totalPrice,
      );

      if (result is BookingSuccess) {
        log("Booking confirmed: ${result.booking}");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context).bookingConfirmed),
              backgroundColor: ThemeColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          widget.onBookingSuccess?.call();
        }

        setState(() {
          _startDate = null;
          _endDate = null;
          _isConfirming = false;
          _totalPrice = 0.0;
        });
      } else if (result is BookingFailure && mounted) {
        log("Booking failed: ${result.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: ThemeColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: ThemeColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.grey400.withOpacity(0.1),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${L10n.of(context).from} \$${room.pricePerNight.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  Text(
                    "\$${room.pricePerNight.toStringAsFixed(2)} / ${L10n.of(context).night}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isAvailable
                    ? (_isConfirming
                        ? () => _confirmBooking(visitorId: currentVisitorId)
                        : _selectDates)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable
                      ? _isConfirming
                          ? ThemeColors.accentPink
                          : ThemeColors.primary
                      : ThemeColors.grey400,
                  foregroundColor: ThemeColors.white,
                  minimumSize: const Size(140, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isConfirming ? Iconsax.tick_circle : Iconsax.calendar,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable
                          ? (_isConfirming
                              ? L10n.of(context).confirm
                              : L10n.of(context).bookNow)
                          : L10n.of(context).unavailable,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}