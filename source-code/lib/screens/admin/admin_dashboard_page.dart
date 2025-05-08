import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/admin.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utils/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/booking_with_details.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/services/booking/booking_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<BookingWithDetails> _bookings = [];
  List<Hotel> _hotels = [];
  int _totalVisitors = 0;
  bool _isLoading = true;
  String _timeFilter = 'thisMonth';
  List<ChartData> _earningsData = [];
  List<ChartData> _bookingsData = [];
  bool _showEarningsChart = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        BookingService.getRecentBookings(),
        HotelService.getAllHotels(),
        BookingService.getTotalVisitors(),
      ]);

      setState(() {
        _bookings = results[0] as List<BookingWithDetails>;
        _hotels = results[1] as List<Hotel>;
        _totalVisitors = results[2] as int;
        _hotels.sort((a, b) => b.ratings.rating.compareTo(a.ratings.rating));
        _generateChartData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading dashboard data: $e');
    }
  }

  void _generateChartData() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    Map<int, double> dailyEarnings = {};
    Map<int, double> dailyBookingCounts = {};

    for (int i = 1; i <= daysInMonth; i++) {
      dailyEarnings[i] = 0;
      dailyBookingCounts[i] = 0;
    }

    for (var booking in _bookings) {
      final bookingDate = booking.booking.createdAt;
      if (bookingDate.month == now.month && bookingDate.year == now.year) {
        final day = bookingDate.day;
        dailyEarnings[day] = (dailyEarnings[day] ?? 0) + booking.commission;
        dailyBookingCounts[day] = (dailyBookingCounts[day] ?? 0) + 1;
      }
    }

    _earningsData = dailyEarnings.entries
        .map((entry) => ChartData(
            x: DateTime(now.year, now.month, entry.key), y: entry.value))
        .toList();

    _bookingsData = dailyBookingCounts.entries
        .map((entry) => ChartData(
            x: DateTime(now.year, now.month, entry.key), y: entry.value))
        .toList();

    _earningsData.sort((a, b) => a.x.compareTo(b.x));
    _bookingsData.sort((a, b) => a.x.compareTo(b.x));
  }

  int get _totalBookings => _bookings.length;
  double get _totalEarnings =>
      _bookings.fold(0, (sum, booking) => sum + booking.commission);
  int get _activeHotels => _hotels.where((hotel) => hotel.isSubscribed).length;
  double get _monthlyGrowth => 12.5;
  List<Hotel> get _topPerformingHotels => _hotels.take(5).toList();
  List<BookingWithDetails> get _recentBookings => _bookings.take(10).toList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentAdmin = state.currentUser as Admin;
        return Scaffold(
          backgroundColor: ThemeColors.background,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: ThemeColors.primary))
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 200,
                        floating: false,
                        pinned: true,
                        backgroundColor: ThemeColors.primary,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildHeaderBackground(currentAdmin),
                          titlePadding:
                              const EdgeInsets.only(left: 16, bottom: 16),
                          title: const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: ThemeColors.textOnDark,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: _buildOverviewContent(),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _loadDashboardData(),
            backgroundColor: ThemeColors.primary,
            child: const Icon(Iconsax.refresh, color: ThemeColors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBackground(Admin admin) {
    return Container(
      decoration: const BoxDecoration(
        gradient: ThemeColors.primaryGradient,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/admin_bg_pattern.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, genericProfileRoute),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ThemeColors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.shadow.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const UserProfile(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.of(context).hello,
                          style: TextStyle(
                            color: ThemeColors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          admin.name,
                          style: const TextStyle(
                            color: ThemeColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildOverviewContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor your platform performance',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimeFilterChip('Today', 'today'),
                      const SizedBox(width: 8),
                      _buildTimeFilterChip('Last 7 Days', 'last7days'),
                      const SizedBox(width: 8),
                      _buildTimeFilterChip('This Month', 'thisMonth'),
                      const SizedBox(width: 8),
                      _buildTimeFilterChip('Last Month', 'lastMonth'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildListDelegate([
              _buildMetricCard(
                title: 'Total Bookings',
                value: _totalBookings.toString(),
                icon: Iconsax.calendar,
                color: ThemeColors.accentPurple,
                trend: '+12% from last month',
              ),
              _buildMetricCard(
                title: 'Total Earnings',
                value: '\$${_totalEarnings.toStringAsFixed(2)}',
                icon: Iconsax.money,
                color: ThemeColors.success,
                trend: '+8% from last month',
              ),
              _buildMetricCard(
                title: 'Active Hotels',
                value: _activeHotels.toString(),
                icon: Iconsax.building,
                color: ThemeColors.info,
                trend: 'of ${_hotels.length} total',
              ),
              _buildMetricCard(
                title: 'Total Visitors',
                value: _totalVisitors.toString(),
                icon: Iconsax.user,
                color: ThemeColors.accentDeep,
                trend: '+${_monthlyGrowth.toStringAsFixed(1)}% growth',
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildChartSection(),
        ),
        SliverToBoxAdapter(
          child: _buildTopHotelsSection(),
        ),
        SliverToBoxAdapter(
          child: _buildRecentBookingsSection(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildTimeFilterChip(String label, String value) {
    final isSelected = _timeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _timeFilter = value),
      selectedColor: ThemeColors.primary,
      backgroundColor: ThemeColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? ThemeColors.white : ThemeColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: isSelected ? 2 : 0,
      shadowColor: ThemeColors.shadow,
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (trend != null && trend.contains('+'))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.arrow_up_2,
                          color: ThemeColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trend
                              .replaceAll('+', '')
                              .replaceAll('from last month', ''),
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
            ),
            if (trend != null && !trend.contains('+')) ...[
              const SizedBox(height: 4),
              Text(
                trend,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Performance Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildChartToggleButton('Earnings', _showEarningsChart),
                      const SizedBox(width: 8),
                      _buildChartToggleButton('Bookings', !_showEarningsChart),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 240,
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat.MMMd(),
                    intervalType: DateTimeIntervalType.days,
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: const TextStyle(
                      color: ThemeColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    majorGridLines: const MajorGridLines(
                      width: 0.5,
                      color: ThemeColors.border,
                      dashArray: <double>[5, 5],
                    ),
                    labelStyle: const TextStyle(
                      color: ThemeColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  plotAreaBorderWidth: 0,
                  plotAreaBackgroundColor: ThemeColors.white,
                  legend: Legend(
                    isVisible: false,
                  ),
                  series: <CartesianSeries>[
                    if (_showEarningsChart)
                      AreaSeries<ChartData, DateTime>(
                        dataSource: _earningsData,
                        xValueMapper: (data, _) => data.x,
                        yValueMapper: (data, _) => data.y,
                        color: ThemeColors.primary.withOpacity(0.2),
                        borderColor: ThemeColors.primary,
                        borderWidth: 3,
                        animationDuration: 1000,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                          color: ThemeColors.primary,
                          borderColor: ThemeColors.white,
                          borderWidth: 2,
                        ),
                      )
                    else
                      ColumnSeries<ChartData, DateTime>(
                        dataSource: _bookingsData,
                        xValueMapper: (data, _) => data.x,
                        yValueMapper: (data, _) => data.y,
                        color: ThemeColors.accentPurple,
                        borderRadius: BorderRadius.circular(4),
                        animationDuration: 1000,
                      ),
                  ],
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: ThemeColors.darkBackground,
                    textStyle: const TextStyle(color: ThemeColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _showEarningsChart
                        ? 'Daily Earnings (USD)'
                        : 'Daily Bookings Count',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartToggleButton(String label, bool isActive) {
    return InkWell(
      onTap: () => setState(() => _showEarningsChart = label == 'Earnings'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ThemeColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? ThemeColors.primary : ThemeColors.border,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: ThemeColors.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? ThemeColors.white : ThemeColors.textPrimary,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTopHotelsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Performing Hotels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Iconsax.arrow_right_3,
                      size: 18,
                      color: ThemeColors.primary,
                    ),
                    label: const Text(
                      'View All',
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: ThemeColors.primaryTransparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_topPerformingHotels.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No hotels available',
                    style: TextStyle(color: ThemeColors.textSecondary),
                  ),
                ),
              )
            else
              ..._topPerformingHotels
                  .take(3)
                  .map((hotel) => _buildHotelListItem(hotel)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookingsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Iconsax.arrow_right_3,
                      size: 18,
                      color: ThemeColors.primary,
                    ),
                    label: const Text(
                      'View All',
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: ThemeColors.primaryTransparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_recentBookings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No bookings available',
                    style: TextStyle(color: ThemeColors.textSecondary),
                  ),
                ),
              )
            else
              ..._recentBookings
                  .take(3)
                  .map((booking) => _buildBookingListItem(booking)),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelListItem(Hotel hotel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.cardHighlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: hotel.images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(hotel.images.first),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: ThemeColors.surface,
            ),
            child: hotel.images.isEmpty
                ? const Icon(Iconsax.building, color: ThemeColors.grey400)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.hotelName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Iconsax.star1,
                      color: ThemeColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel.ratings.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${hotel.ratings.totalRating} reviews)',
                      style: const TextStyle(
                        color: ThemeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: hotel.isSubscribed
                  ? ThemeColors.success.withOpacity(0.15)
                  : ThemeColors.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hotel.isSubscribed ? 'Active' : 'Inactive',
              style: TextStyle(
                color: hotel.isSubscribed
                    ? ThemeColors.success
                    : ThemeColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingListItem(BookingWithDetails booking) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ThemeColors.primary.withOpacity(0.1),
          ),
          child: const Icon(Iconsax.receipt, color: ThemeColors.primary),
        ),
        title: Text(
          'Booking #${booking.booking.id.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${dateFormat.format(booking.booking.checkInDate)} - ${dateFormat.format(booking.booking.checkOutDate)}',
              style: const TextStyle(
                color: ThemeColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${booking.booking.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(booking.booking.createdAt),
              style: const TextStyle(
                color: ThemeColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to booking details
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ChartData {
  final DateTime x;
  final double y;

  ChartData({required this.x, required this.y});
}
