import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/hotel/widget/headline_text_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class HotelBookingsPage extends StatefulWidget {
  const HotelBookingsPage({super.key});

  @override
  State<HotelBookingsPage> createState() => _HotelBookingsPageState();
}

class _HotelBookingsPageState extends State<HotelBookingsPage> {
  final ValueNotifier<String> _filterStatus = ValueNotifier('All');
  final List<String> _statusFilters = [
    'All',
    'pending',
    'cancelled',
    'completed'
  ];

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
      return await Booking.fetchHotelBookingsById(hotelId: _hotel.id);
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshBookings,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<List<Booking>>(
                  future: _bookingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: FutureBuilder<List<Booking>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
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
                            padding: const EdgeInsets.only(bottom: 16),
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
    );
  }

  Widget _buildSummaryCards(List<Booking> bookings, String filterValue) {
    final filteredBookings = filterValue == 'All'
        ? bookings
        : bookings.where((b) => b.status.name == filterValue).toList();

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSummaryCard(
                title: 'Total',
                value: bookings.length,
                icon: Iconsax.book,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                title: 'Pending',
                value: bookings
                    .where((b) => b.status == BookingStatus.pending)
                    .length,
                icon: Iconsax.clock,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                title: 'Completed',
                value: bookings
                    .where((b) => b.status == BookingStatus.completed)
                    .length,
                icon: Iconsax.tick_circle,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                title: 'Revenue',
                value: bookings.fold(0.0, (sum, b) => sum + b.totalPrice),
                icon: Iconsax.dollar_circle,
                color: Colors.purple,
                isCurrency: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: Visitor.getBookingAndHotelById(booking.id),
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
        final nights =
            booking.checkOutDate.difference(booking.checkInDate).inDays;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showBookingDetails(booking, room, visitor),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                                width: 60,
                                height: 60,
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              visitor != null
                                  ? '${visitor.firstName} ${visitor.lastName}'
                                  : 'Unknown Visitor',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(booking.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDateInfo(
                        icon: Iconsax.calendar_1,
                        title: 'Check-in',
                        date: booking.checkInDate,
                      ),
                      const SizedBox(width: 16),
                      _buildDateInfo(
                        icon: Iconsax.calendar_tick,
                        title: 'Check-out',
                        date: booking.checkOutDate,
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${booking.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$nights ${nights == 1 ? 'night' : 'nights'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (booking.status == BookingStatus.pending) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateBookingStatus(
                              booking,
                              BookingStatus.completed,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Complete'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateBookingStatus(
                              booking,
                              BookingStatus.cancelled,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: Colors.red.shade400),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red.shade400),
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
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Iconsax.image, color: Colors.grey),
    );
  }

  Widget _buildBookingCardSkeleton() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildBookingCardError(Booking booking) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontWeight: FontWeight.w600,
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
      BookingStatus.pending: {'color': Colors.orange, 'label': 'Pending'},
      BookingStatus.completed: {'color': Colors.green, 'label': 'Completed'},
      BookingStatus.cancelled: {'color': Colors.red, 'label': 'Cancelled'},
    };

    final color = statusInfo[status]!['color'] as Color;
    final label = statusInfo[status]!['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _updateBookingStatus(
      Booking booking, BookingStatus newStatus) async {
    final result = await Booking.updateBookingStatus(
      bookingId: booking.id,
      newStatus: newStatus,
    );

    if (!mounted) return;

    if (result is BookingSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.name}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      await _refreshBookings();
    } else if (result is BookingFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildSummaryCard({
    required String title,
    required dynamic value,
    required IconData icon,
    required Color color,
    bool isCurrency = false,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCurrency
                ? '\$${(value as double).toStringAsFixed(2)}'
                : value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
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
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String filterValue) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Iconsax.note_remove,
          size: 60,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          "No Bookings Found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          filterValue == 'All'
              ? "You don't have any bookings yet"
              : "No $filterValue bookings found",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          "Failed to load bookings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _refreshBookings,
          child: const Text("Retry"),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Bookings'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _statusFilters.length,
            itemBuilder: (context, index) {
              final status = _statusFilters[index];
              return RadioListTile(
                title: Text(status),
                value: status,
                groupValue: _filterStatus.value,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  'Booking Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 24),
            if (room != null) ...[
              Text('Room Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  )),
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
                title: Text(room.name),
                subtitle: Text(
                    '\$${room.pricePerNight.toStringAsFixed(2)} per night'),
              ),
              const SizedBox(height: 16),
            ],
            if (visitor != null) ...[
              Text('Guest Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  )),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            '${visitor.firstName[0]}${visitor.lastName[0]}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                ),
                title: Text('${visitor.firstName} ${visitor.lastName}'),
                subtitle: Text(visitor.email),
              ),
              const SizedBox(height: 16),
            ],
            Text('Booking Dates',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    icon: Iconsax.calendar_1,
                    title: 'Check-in',
                    date: booking.checkInDate,
                  ),
                ),
                Expanded(
                  child: _buildDateInfo(
                    icon: Iconsax.calendar_tick,
                    title: 'Check-out',
                    date: booking.checkOutDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Payment Information',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                )),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount'),
                Text(
                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Status',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    )),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Paid',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (booking.status == BookingStatus.pending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _updateBookingStatus(booking, BookingStatus.completed);
                    Navigator.pop(context);
                  },
                  child: const Text('Mark as Completed'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const HeadlineText(text: "Bookings"),
        IconButton(
          icon: const Icon(Iconsax.filter),
          onPressed: _showFilterDialog,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
