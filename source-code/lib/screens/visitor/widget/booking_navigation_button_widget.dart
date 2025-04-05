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
  late final Room _room;
  late final double _pricePerNight;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _pricePerNight = _room.pricePerNight;
  }

  bool get _isRoomAvailable =>
      _room.availability.isAvailable &&
      (_room.availability.nextAvailableDate == null ||
          _room.availability.nextAvailableDate!.isBefore(DateTime.now()));

  DateTime get _initialDate {
    final today = DateTime.now();
    return _room.availability.nextAvailableDate?.isAfter(today) ?? false
        ? _room.availability.nextAvailableDate!
        : today;
  }

  Widget _datePickerTheme(Widget? child) {
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
  }

  Future<void> _selectDates() async {
    final pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: _initialDate,
      lastDate: DateTime(2100),
      helpText: L10n.of(context).selectCheckInDate,
      cancelText: L10n.of(context).cancel,
      confirmText: L10n.of(context).next,
      builder: (context, child) => _datePickerTheme(child),
    );

    if (pickedStartDate == null || !mounted) return;

    final pickedEndDate = await showDatePicker(
      context: context,
      initialDate: pickedStartDate.add(const Duration(days: 1)),
      firstDate: pickedStartDate.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      helpText: L10n.of(context).selectCheckOutDate,
      cancelText: L10n.of(context).cancel,
      confirmText: L10n.of(context).confirm,
      builder: (context, child) => _datePickerTheme(child),
    );

    if (pickedEndDate != null && mounted) {
      setState(() {
        _startDate = pickedStartDate;
        _endDate = pickedEndDate;
        _isConfirming = true;
        _totalPrice =
            _pricePerNight * pickedEndDate.difference(pickedStartDate).inDays;
      });
    }
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

  Future<void> _confirmBooking({required String visitorId}) async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        _showErrorMessage(L10n.of(context).selectDatesFirst);
      }
      return;
    }

    try {
      final confirmed = await _showTotalPriceDialog();
      if (!confirmed) return;

      final result = await BookingService.createBooking(
        hotelId: _room.hotelId,
        roomId: _room.id,
        visitorId: visitorId,
        checkInDate: _startDate!,
        checkOutDate: _endDate!,
        totalPrice: _totalPrice,
      );

      if (result is BookingSuccess && mounted) {
        _showSuccessMessage();
        widget.onBookingSuccess?.call();
        _resetState();
      } else if (result is BookingFailure && mounted) {
        _showErrorMessage(result.message);
      }
    } catch (e) {
      log("Booking error: $e");
      if (mounted) {
        _showErrorMessage(L10n.of(context).bookingError);
      }
    }
  }

  void _showSuccessMessage() {
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
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetState() {
    if (mounted) {
      setState(() {
        _startDate = null;
        _endDate = null;
        _isConfirming = false;
        _totalPrice = 0.0;
      });
    }
  }

  Widget _buildBookButton(String visitorId) {
    return ElevatedButton(
      onPressed: _isRoomAvailable
          ? (_isConfirming
              ? () => _confirmBooking(visitorId: visitorId)
              : _selectDates)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRoomAvailable
            ? (_isConfirming ? ThemeColors.accentPink : ThemeColors.primary)
            : ThemeColors.grey400,
        foregroundColor: ThemeColors.white,
        minimumSize: const Size(140, 50),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
            _isRoomAvailable
                ? (_isConfirming
                    ? L10n.of(context).confirm
                    : L10n.of(context).bookNow)
                : L10n.of(context).unavailable,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final visitorId = (state.currentUser as Visitor).id;
        return _buildBookingBar(visitorId);
      },
    );
  }

  Widget _buildBookingBar(String visitorId) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBookButton(visitorId),
          ],
        ),
      ),
    );
  }
}
