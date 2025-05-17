import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/booking_with_details.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/booking/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({Key? key}) : super(key: key);

  @override
  _AdminBookingsPageState createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  // State variables
  List<BookingWithDetails> _allBookings = [];
  List<BookingWithDetails> _filteredBookings = [];
  String _dateFilterType = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  // Constants
  final double _commissionRate = 0.1; // Fixed at 10%

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // Load bookings with hotel and visitor details
  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingsWithDetails = await BookingService.getRecentBookings(
        isAdmin: true,
      );

      setState(() {
        _allBookings = bookingsWithDetails;
        _filteredBookings = bookingsWithDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(L10n.of(context).errorLoadingBookings(e.toString()));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: L10n.of(context).dismiss,
          textColor: ThemeColors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Apply date filter
  void _applyDateFilter(String filterType) {
    setState(() {
      _dateFilterType = filterType;

      switch (filterType) {
        case 'today':
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          _startDate = today;
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'last7days':
          final now = DateTime.now();
          _endDate = now;
          _startDate = now.subtract(const Duration(days: 7));
          break;
        case 'thisMonth':
          final now = DateTime.now();
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'lastMonth':
          final now = DateTime.now();
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'custom':
          // Keep existing custom dates
          break;
        case 'all':
        default:
          _startDate = null;
          _endDate = null;
          break;
      }

      // Apply filter
      _filterBookings();
    });
  }

  // Filter bookings based on selected date range
  void _filterBookings() {
    if (_startDate == null || _endDate == null) {
      // No date filter, show all bookings
      setState(() {
        _filteredBookings = _allBookings;
      });
      return;
    }

    // Apply date filter
    setState(() {
      _filteredBookings = _allBookings.where((booking) {
        return booking.booking.createdAt.isAfter(_startDate!) &&
            booking.booking.createdAt
                .isBefore(_endDate!.add(const Duration(seconds: 1)));
      }).toList();
    });
  }

  // Set custom date range
  void _setCustomDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      setState(() {
        _startDate = start;
        _endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
        _dateFilterType = 'custom';
        _filterBookings();
      });
    }
  }

  // Calculate summary statistics
  int get _totalBookings => _filteredBookings.length;

  double get _totalEarnings {
    return _filteredBookings.fold(
        0, (sum, booking) => sum + booking.commission);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: CustomBackAppBar(
        title: L10n.of(context).bookingsManagement,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: ThemeColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.of(context).loadingBookings,
                    style: const TextStyle(
                      color: ThemeColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: ThemeColors.primary,
              onRefresh: _loadBookings,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Summary cards
                        _buildSummaryCards(),

                        // Filter section
                        _buildFilterSection(),
                      ],
                    ),
                  ),

                  // Bookings list
                  _filteredBookings.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildBookingCard(
                                  _filteredBookings[index]);
                            },
                            childCount: _filteredBookings.length,
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.calendar_1,
            size: 80,
            color: ThemeColors.grey400,
          ),
          const SizedBox(height: 24),
          Text(
            L10n.of(context).noBookingsFound,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.of(context).tryAdjustingFilters,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Summary cards widget
  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Total Bookings Card
          Expanded(
            child: _buildSummaryCard(
              title: L10n.of(context).totalBookings,
              value: '$_totalBookings',
              icon: Iconsax.calendar_1,
              iconColor: ThemeColors.accentPurple,
              backgroundColor: ThemeColors.cardHighlight,
            ),
          ),
          const SizedBox(width: 16),
          // Total Earnings Card
          Expanded(
            child: _buildSummaryCard(
              title: L10n.of(context).totalEarnings,
              value: '\$${_totalEarnings.toStringAsFixed(2)}',
              icon: Iconsax.money,
              iconColor: ThemeColors.success,
              backgroundColor: ThemeColors.cardHighlight,
              valueColor: ThemeColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // Individual summary card
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: ThemeColors.border.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: valueColor ?? ThemeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Filter section widget
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.filter,
                size: 16,
                color: ThemeColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                L10n.of(context).filterByDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(L10n.of(context).allTime, 'all'),
                _buildFilterChip(L10n.of(context).today, 'today'),
                _buildFilterChip(L10n.of(context).last7Days, 'last7days'),
                _buildFilterChip(L10n.of(context).thisMonth, 'thisMonth'),
                _buildFilterChip(L10n.of(context).lastMonth, 'lastMonth'),
                _buildFilterChip(L10n.of(context).customRange, 'custom'),
              ],
            ),
          ),

          // Custom date range picker
          if (_dateFilterType == 'custom')
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10n.of(context).selectDateRange,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerButton(
                          label: L10n.of(context).startDate,
                          date: _startDate,
                          icon: Iconsax.calendar,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: ThemeColors.primary,
                                      onPrimary: ThemeColors.white,
                                      onSurface: ThemeColors.textPrimary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              if (_endDate == null ||
                                  date.isBefore(_endDate!)) {
                                _setCustomDateRange(date, _endDate ?? date);
                              } else {
                                _showErrorSnackBar(
                                    L10n.of(context).startDateBeforeEndDate);
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePickerButton(
                          label: L10n.of(context).endDate,
                          date: _endDate,
                          icon: Iconsax.calendar,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: ThemeColors.primary,
                                      onPrimary: ThemeColors.white,
                                      onSurface: ThemeColors.textPrimary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              if (_startDate == null ||
                                  date.isAfter(_startDate!)) {
                                _setCustomDateRange(_startDate ?? date, date);
                              } else {
                                _showErrorSnackBar(
                                    L10n.of(context).endDateAfterStartDate);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_startDate != null && _endDate != null) {
                          _filterBookings();
                        } else {
                          _showErrorSnackBar(L10n.of(context).selectBothDates);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primary,
                        foregroundColor: ThemeColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(L10n.of(context).applyFilter),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Date picker button
  Widget _buildDatePickerButton({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: ThemeColors.border),
          borderRadius: BorderRadius.circular(8),
          color: ThemeColors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: ThemeColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date == null ? label : DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(
                  fontSize: 14,
                  color: date == null
                      ? ThemeColors.textSecondary
                      : ThemeColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter chip widget
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _dateFilterType == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        avatar: isSelected
            ? const Icon(
                Iconsax.tick_circle,
                size: 16,
                color: ThemeColors.white,
              )
            : null,
        labelStyle: TextStyle(
          color: isSelected ? ThemeColors.white : ThemeColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          fontSize: 13,
        ),
        backgroundColor: ThemeColors.surface,
        selectedColor: ThemeColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? ThemeColors.primary : ThemeColors.border,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            _applyDateFilter(value);
          }
        },
      ),
    );
  }

  // Booking card widget
  Widget _buildBookingCard(BookingWithDetails bookingDetails) {
    final booking = bookingDetails.booking;
    final statusColor = _getStatusColor(booking.status);
    final statusBgColor = statusColor.withOpacity(0.1);
    final nights = booking.checkOutDate.difference(booking.checkInDate).inDays;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with visitor name and status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: ThemeColors.cardHighlight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.user,
                  size: 18,
                  color: ThemeColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bookingDetails.visitorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: ThemeColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(booking.status),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(booking.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Booking details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel and room info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeColors.primaryTransparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Iconsax.building,
                        color: ThemeColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookingDetails.hotelName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${L10n.of(context).room}: ${bookingDetails.roomName}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: ThemeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Check-in/out dates
                Row(
                  children: [
                    // Check-in date
                    Expanded(
                      child: _buildDateInfoCard(
                        title: L10n.of(context).checkIn,
                        date: booking.checkInDate,
                        icon: Iconsax.login,
                        color: ThemeColors.info,
                      ),
                    ),

                    // Arrow between dates
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          const Icon(
                            Iconsax.arrow_right_1,
                            color: ThemeColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$nights ${nights == 1 ? L10n.of(context).night : L10n.of(context).nightsWord}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Check-out date
                    Expanded(
                      child: _buildDateInfoCard(
                        title: L10n.of(context).checkOut,
                        date: booking.checkOutDate,
                        icon: Iconsax.logout,
                        color: ThemeColors.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider with booking date
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: ThemeColors.border,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${L10n.of(context).bookedOn} ${DateFormat('MMM dd, yyyy').format(booking.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: ThemeColors.border,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Payment information
                Row(
                  children: [
                    // Total price
                    Expanded(
                      child: _buildPriceInfoCard(
                        title: L10n.of(context).totalPrice,
                        value: '\$${booking.totalPrice.toStringAsFixed(2)}',
                        icon: Iconsax.wallet,
                        color: ThemeColors.accentDeep,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Commission
                    Expanded(
                      child: _buildPriceInfoCard(
                        title:
                            '${L10n.of(context).commission} (${(_commissionRate * 100).toInt()}%)',
                        value:
                            '\$${bookingDetails.commission.toStringAsFixed(2)}',
                        icon: Iconsax.money,
                        color: ThemeColors.success,
                        valueColor: ThemeColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Date info card for check-in/out
  Widget _buildDateInfoCard({
    required String title,
    required DateTime date,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('MMM dd, yyyy').format(date),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
          ),
          Text(
            DateFormat('EEEE').format(date),
            style: const TextStyle(
              fontSize: 12,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Price info card for total and commission
  Widget _buildPriceInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? ThemeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for status
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return ThemeColors.success;
      case BookingStatus.cancelled:
        return ThemeColors.error;
      case BookingStatus.pending:
      default:
        return ThemeColors.warning;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return Iconsax.tick_circle;
      case BookingStatus.cancelled:
        return Iconsax.close_circle;
      case BookingStatus.pending:
      default:
        return Iconsax.timer;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return L10n.of(context).completed;
      case BookingStatus.cancelled:
        return L10n.of(context).cancelled;
      case BookingStatus.pending:
      default:
        return L10n.of(context).pending;
    }
  }
}
