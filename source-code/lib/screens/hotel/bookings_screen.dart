import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/booking/booking_service.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class StatusFilter {
  String value;
  String label;

  StatusFilter({required this.value, required this.label});
}

class HotelBookingsPage extends StatefulWidget {
  const HotelBookingsPage({super.key});

  @override
  State<HotelBookingsPage> createState() => _HotelBookingsPageState();
}

class _HotelBookingsPageState extends State<HotelBookingsPage> {
  final ValueNotifier<String> _filterStatus = ValueNotifier<String>('All');
  late Hotel _hotel;
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthBloc>().state.currentUser;
    if (currentUser is Hotel) {
      _hotel = currentUser;
      _bookingsFuture = _fetchBookings();
    } else {
      _bookingsFuture = Future.value([]);
    }
  }

  Future<List<Booking>> _fetchBookings() async {
    try {
      return await BookingService.fetchHotelBookings(hotelId: _hotel.id);
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      return [];
    }
  }

  Future<void> _refreshBookings() async {
    setState(() {
      _bookingsFuture = _fetchBookings();
    });
  }

  @override
  void dispose() {
    _filterStatus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomBackAppBar(
          title: L10n.of(context).bookingsTitle,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.filter,
                  size: 20, color: ThemeColors.primary),
              onPressed: _showFilterDialog,
              style: IconButton.styleFrom(
                backgroundColor: ThemeColors.surface,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        backgroundColor: ThemeColors.background,
        body: RefreshIndicator(
          color: ThemeColors.primary,
          onRefresh: _refreshBookings,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<List<Booking>>(
                    future: _bookingsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ThemeColors.primary,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return _buildErrorState();
                      }

                      final bookings = snapshot.data!;
                      return ValueListenableBuilder<String>(
                        valueListenable: _filterStatus,
                        builder: (context, filterValue, _) {
                          return _buildSummaryCards(bookings, filterValue);
                        },
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: FutureBuilder<List<Booking>>(
                  future: _bookingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ThemeColors.primary,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return SliverFillRemaining(
                        child: _buildErrorState(),
                      );
                    }

                    final bookings = snapshot.data!;
                    return ValueListenableBuilder<String>(
                      valueListenable: _filterStatus,
                      builder: (context, filterValue, _) {
                        final filteredBookings = filterValue == 'All'
                            ? bookings
                            : bookings
                                .where((b) => b.status.name == filterValue)
                                .toList();

                        if (filteredBookings.isEmpty) {
                          return SliverFillRemaining(
                            child: _buildEmptyState(filterValue),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBookingCard(filteredBookings[index]),
                            ),
                            childCount: filteredBookings.length,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Booking> bookings, String filterValue) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 4),
          _buildSummaryCard(
            title: L10n.of(context).summaryTotal,
            value: bookings.length,
            icon: Iconsax.book,
            color: ThemeColors.primary,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            title: L10n.of(context).summaryPending,
            value:
                bookings.where((b) => b.status == BookingStatus.pending).length,
            icon: Iconsax.clock,
            color: ThemeColors.warning,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            title: L10n.of(context).summaryCompleted,
            value: bookings
                .where((b) => b.status == BookingStatus.completed)
                .length,
            icon: Iconsax.tick_circle,
            color: ThemeColors.success,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            title: L10n.of(context).summaryRevenue,
            value: bookings.fold(0.0, (sum, b) => sum + b.totalPrice),
            icon: Iconsax.dollar_circle,
            color: ThemeColors.accentPurple,
            isCurrency: true,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: VisitorService.getBookingAndHotelById(booking.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildBookingCardSkeleton();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildBookingCardError(booking);
        }

        final data = snapshot.data!;
        final visitor = data['visitor'] as Visitor?;
        final room = data['room'] as Room?;

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: ThemeColors.border,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showBookingDetails(booking, room, visitor),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: room?.images.isNotEmpty == true
                            ? Image.network(
                                room!.images.first,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholderImage(),
                              )
                            : _buildPlaceholderImage(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room?.name ?? 'Unknown Room',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ThemeColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              visitor != null
                                  ? '${visitor.firstName} ${visitor.lastName}'
                                  : 'Unknown Visitor',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ThemeColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(booking.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInfo(
                          icon: Iconsax.calendar_1,
                          title: 'Check-in',
                          date: booking.checkInDate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateInfo(
                          icon: Iconsax.calendar_tick,
                          title: 'Check-out',
                          date: booking.checkOutDate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${booking.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: ThemeColors.textPrimary,
                            ),
                          ),
                          Text(
                            L10n.of(context).nights(booking.checkOutDate
                                .difference(booking.checkInDate)
                                .inDays),
                            style: const TextStyle(
                              fontSize: 10,
                              color: ThemeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (booking.status == BookingStatus.pending) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateBookingStatus(
                              booking,
                              BookingStatus.completed,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side:
                                  const BorderSide(color: ThemeColors.primary),
                            ),
                            child: Text(
                              L10n.of(context).complete,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ThemeColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateBookingStatus(
                              booking,
                              BookingStatus.cancelled,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(color: ThemeColors.error),
                            ),
                            child: Text(
                              L10n.of(context).cancel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ThemeColors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      color: ThemeColors.surface,
      child:
          const Icon(Iconsax.image, size: 20, color: ThemeColors.textSecondary),
    );
  }

  Widget _buildBookingCardSkeleton() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: ThemeColors.border,
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              color: ThemeColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCardError(Booking booking) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: ThemeColors.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPlaceholderImage(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Error loading booking details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final statusInfo = {
      BookingStatus.pending: {
        'color': ThemeColors.warning,
        'label': L10n.of(context).pending
      },
      BookingStatus.completed: {
        'color': ThemeColors.success,
        'label': L10n.of(context).completed
      },
      BookingStatus.cancelled: {
        'color': ThemeColors.error,
        'label': L10n.of(context).cancelled
      },
    };

    final color = statusInfo[status]!['color'] as Color;
    final label = statusInfo[status]!['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required dynamic value,
    required IconData icon,
    required Color color,
    bool isCurrency = false,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: ThemeColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              isCurrency
                  ? '\$${(value as double).toStringAsFixed(2)}'
                  : value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo({
    required IconData icon,
    required String title,
    required DateTime date,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ThemeColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: ThemeColors.textSecondary,
              ),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ThemeColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String filterValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          const Icon(
            Iconsax.note_remove,
            size: 48,
            color: ThemeColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.of(context).noBookingsFound,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            filterValue == 'All'
                ? L10n.of(context).noBookingsDefault
                : L10n.of(context).noFilteredBookings(filterValue),
            style: const TextStyle(
              fontSize: 12,
              color: ThemeColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
            color: ThemeColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.of(context).failedToLoadBookings,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _refreshBookings,
              child: Text(
                L10n.of(context).retry,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final List<StatusFilter> statusFilters = [
      StatusFilter(label: L10n.of(context).all, value: 'All'),
      StatusFilter(label: L10n.of(context).pending, value: 'pending'),
      StatusFilter(label: L10n.of(context).cancelled, value: 'cancelled'),
      StatusFilter(label: L10n.of(context).completed, value: 'completed'),
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.card,
        title: Text(
          L10n.of(context).filterBookingsTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: statusFilters.length,
            itemBuilder: (context, index) {
              final status = statusFilters[index];
              return RadioListTile(
                title: Text(
                  status.label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                value: status.value,
                groupValue: _filterStatus.value,
                activeColor: ThemeColors.primary,
                onChanged: (value) {
                  _filterStatus.value = value.toString();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking, Room? room, Visitor? visitor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: ThemeColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadowDark,
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ThemeColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    L10n.of(context).bookingDetailsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusBadge(booking.status),
                ],
              ),
              const SizedBox(height: 16),
              if (room != null) ...[
                Text(
                  L10n.of(context).roomInformation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: room.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            room.images.first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholderImage(),
                          ),
                        )
                      : _buildPlaceholderImage(),
                  title: Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    L10n.of(context)
                        .perNight('\$${room.pricePerNight.toStringAsFixed(2)}'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (visitor != null) ...[
                Text(
                  L10n.of(context).guestInformation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ThemeColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: visitor.avatarURL != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(
                              visitor.avatarURL!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  '${visitor.firstName[0]}${visitor.lastName[0]}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              '${visitor.firstName[0]}${visitor.lastName[0]}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.primary,
                              ),
                            ),
                          ),
                  ),
                  title: Text(
                    '${visitor.firstName} ${visitor.lastName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    visitor.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                L10n.of(context).bookingDates,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo(
                      icon: Iconsax.calendar_1,
                      title: L10n.of(context).checkIn,
                      date: booking.checkInDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDateInfo(
                      icon: Iconsax.calendar_tick,
                      title: L10n.of(context).checkOut,
                      date: booking.checkOutDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                L10n.of(context).paymentInformation,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    L10n.of(context).totalAmount,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  Text(
                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    L10n.of(context).paymentStatus,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      L10n.of(context).paid,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (booking.status == BookingStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _updateBookingStatus(booking, BookingStatus.completed);
                      Navigator.pop(context);
                    },
                    child: Text(
                      L10n.of(context).markCompleted,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateBookingStatus(
      Booking booking, BookingStatus newStatus) async {
    final result = await BookingService.updateBookingStatus(
      bookingId: booking.id,
      newStatus: newStatus,
    );

    if (!mounted) return;

    if (result is BookingSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.name}'),
          backgroundColor: ThemeColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      await _refreshBookings();
    } else if (result is BookingFailure) {
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
