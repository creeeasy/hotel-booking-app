import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key});

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final bookingId = ModalRoute.of(context)?.settings.arguments as String;
    return await VisitorService.getBookingAndHotelById(bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: CustomBackAppBar(
        title: "Booking Summary",
        onBack: () => Navigator.of(context).pop(),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchBookingDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicatorWidget(),
            );
          }

          if (snapshot.hasError) {
            return _BookingErrorView(error: snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const _NoBookingDataView();
          }

          final booking = snapshot.data!['booking'] as Booking;
          final hotel = snapshot.data!['hotel'] as Hotel;
          final room = snapshot.data!['room'] as Room;

          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final visitor = state.currentUser as Visitor;
              return _BookingDetailsContent(
                visitor: visitor,
                booking: booking,
                hotel: hotel,
                room: room,
              );
            },
          );
        },
      ),
    );
  }
}

class _BookingDetailsContent extends StatelessWidget {
  final Visitor visitor;
  final Booking booking;
  final Hotel hotel;
  final Room room;

  const _BookingDetailsContent({
    required this.visitor,
    required this.booking,
    required this.hotel,
    required this.room,
  });

  int get _durationDays =>
      booking.checkOutDate.difference(booking.checkInDate).inDays;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _HeaderSection(hotel: hotel),
          const SizedBox(height: 24),
          _VisitorInfoCard(visitor: visitor),
          const SizedBox(height: 16),
          _BookingDatesCard(booking: booking),
          const SizedBox(height: 16),
          _RoomDetailsCard(room: room, durationDays: _durationDays),
          const SizedBox(height: 16),
          _PriceSummaryCard(booking: booking, room: room),
          const SizedBox(height: 24),
          _ExploreHotelButton(hotelId: hotel.id),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Hotel hotel;

  const _HeaderSection({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.house_2, size: 28, color: ThemeColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.hotelName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Booking Confirmed",
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorInfoCard extends StatelessWidget {
  final Visitor visitor;

  const _VisitorInfoCard({required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Guest Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: "First Name",
            value: visitor.firstName,
            icon: Iconsax.user,
          ),
          const Divider(height: 24, thickness: 1, color: ThemeColors.grey200),
          _InfoRow(
            label: "Last Name",
            value: visitor.lastName,
            icon: Iconsax.user,
          ),
          const Divider(height: 24, thickness: 1, color: ThemeColors.grey200),
          _InfoRow(
            label: "Email",
            value: visitor.email,
            icon: Iconsax.sms,
          ),
        ],
      ),
    );
  }
}

class _BookingDatesCard extends StatelessWidget {
  final Booking booking;

  const _BookingDatesCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booking Dates",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateCard(
                  label: "Check-In",
                  date: booking.checkInDate,
                  icon: Iconsax.calendar_1,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateCard(
                  label: "Check-Out",
                  date: booking.checkOutDate,
                  icon: Iconsax.calendar_1,
                  color: ThemeColors.accentPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;
  final Color color;

  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM d, y').format(date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          Text(
            DateFormat('EEEE').format(date),
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final Booking booking;
  final Room room;

  const _PriceSummaryCard({
    required this.booking,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final duration =
        booking.checkOutDate.difference(booking.checkInDate).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Price Summary",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _PriceRow(
            label: "Room Rate",
            value: "\$${room.pricePerNight.toStringAsFixed(2)}",
            description: "per night",
          ),
          const Divider(height: 24, thickness: 1, color: ThemeColors.grey200),
          _PriceRow(
            label: "Duration",
            value: "$duration",
            description: "night${duration > 1 ? 's' : ''}",
          ),
          const Divider(height: 24, thickness: 1, color: ThemeColors.grey200),
          _PriceRow(
            label: "Total Price",
            value: "\$${booking.totalPrice.toStringAsFixed(2)}",
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final String? description;
  final TextStyle? valueStyle;

  const _PriceRow({
    required this.label,
    required this.value,
    this.description,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: ThemeColors.textSecondary,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textPrimary,
                  ),
            ),
            if (description != null)
              Text(
                description!,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textSecondary.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RoomDetailsCard extends StatelessWidget {
  final Room room;
  final int durationDays;

  const _RoomDetailsCard({
    required this.room,
    required this.durationDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Room Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            room.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          _RoomDetailItem(
            icon: Iconsax.profile_2user,
            label: "Capacity",
            value: "${room.capacity} guest${room.capacity > 1 ? 's' : ''}",
          ),
          const SizedBox(height: 8),
          _RoomDetailItem(
            icon: Iconsax.calendar_1,
            label: "Duration",
            value: "$durationDays night${durationDays > 1 ? 's' : ''}",
          ),
          const SizedBox(height: 16),
          const Text(
            "Amenities",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: room.amenities
                .map((amenity) => _AmenityChip(amenity: amenity))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RoomDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RoomDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ThemeColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: ThemeColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String amenity;

  const _AmenityChip({required this.amenity});

  @override
  Widget build(BuildContext context) {
    final amenityData = AmenityIcons.getAmenity(amenity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            amenityData?.icon ?? Iconsax.info_circle,
            size: 16,
            color: ThemeColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            amenityData?.label ?? amenity,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreHotelButton extends StatelessWidget {
  final String hotelId;

  const _ExploreHotelButton({required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            hotelDetailsRoute,
            arguments: hotelId,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primary,
          foregroundColor: ThemeColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.house_2, size: 20),
            SizedBox(width: 8),
            Text(
              "Explore Hotel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingErrorView extends StatelessWidget {
  final String error;

  const _BookingErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeColors.error.withOpacity(0.1),
              ),
              child: Icon(
                Iconsax.warning_2,
                size: 48,
                color: ThemeColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Booking Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: ThemeColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoBookingDataView extends StatelessWidget {
  const _NoBookingDataView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeColors.primary.withOpacity(0.1),
              ),
              child: Icon(
                Iconsax.note_remove,
                size: 48,
                color: ThemeColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Booking Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We couldn\'t find any booking details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: ThemeColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final TextStyle? valueStyle;
  final Color? iconColor;
  final double iconSize;

  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueStyle,
    this.iconColor,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? ThemeColors.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ThemeColors.textSecondary.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: valueStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.primaryDark,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
