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
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late List<BookingWithDetails> _bookings;
  late List<Hotel> _hotels;
  late int _totalVisitors;
  bool _isLoading = true;
  String _timeFilter = 'thisMonth';
  late List<ChartData> _earningsData;
  late List<ChartData> _bookingsData;
  bool _showEarningsChart = true;

  @override
  void initState() {
    super.initState();
    _bookings = [];
    _hotels = [];
    _totalVisitors = 0;
    _earningsData = [];
    _bookingsData = [];
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Calculate date range based on current time filter
      late DateTime startDate;
      late DateTime endDate;
      final now = DateTime.now();

      switch (_timeFilter) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
          break;
        case 'last7days':
          startDate = now.subtract(const Duration(days: 7));
          endDate = now;
          break;
        case 'thisMonth':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
          break;
        case 'lastMonth':
          final lastMonth = DateTime(now.year, now.month - 1);
          startDate = DateTime(lastMonth.year, lastMonth.month, 1);
          endDate =
              DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59, 999);
          break;
        default:
          startDate = DateTime(now.year, 1, 1);
          endDate = now;
      }

      final results = await Future.wait([
        BookingService.getRecentBookings(
          isAdmin: true,
          startDate: startDate,
          endDate: endDate,
        ),
        HotelService.getAllHotels(isAdmin: true),
        BookingService.getTotalVisitors(),
      ]);

      if (!mounted) return;

      setState(() {
        _bookings = results[0] as List<BookingWithDetails>;
        _hotels = results[1] as List<Hotel>;
        _totalVisitors = results[2] as int;
        _hotels.sort((a, b) => b.ratings.rating.compareTo(a.ratings.rating));
        _generateChartData();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar(L10n.of(context).errorLoadingDashboard(e.toString()));
    }
  }

  void _generateChartData() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (_timeFilter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case 'last7days':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'thisMonth':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;
      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate =
            DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59, 999);
        break;
      default:
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
    }

    final dailyEarnings = <int, double>{};
    final dailyBookingCounts = <int, double>{};

    // Create a map to store days based on the time filter
    final daysMap = <int, bool>{};
    switch (_timeFilter) {
      case 'today':
        daysMap[now.day] = true;
        break;
      case 'last7days':
        for (int i = 0; i < 7; i++) {
          final day = now.subtract(Duration(days: i)).day;
          daysMap[day] = true;
        }
        break;
      case 'thisMonth':
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        for (int i = 1; i <= daysInMonth; i++) {
          daysMap[i] = true;
        }
        break;
      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1);
        final daysInLastMonth =
            DateTime(lastMonth.year, lastMonth.month + 1, 0).day;
        for (int i = 1; i <= daysInLastMonth; i++) {
          daysMap[i] = true;
        }
        break;
    }

    // Initialize the maps
    daysMap.forEach((day, _) {
      dailyEarnings[day] = 0;
      dailyBookingCounts[day] = 0;
    });

    for (final booking in _bookings) {
      final bookingDate = booking.booking.createdAt;

      // Check if booking is within the selected time range
      if (bookingDate.isAfter(startDate) && bookingDate.isBefore(endDate)) {
        final day = bookingDate.day;

        // Only add if the day is in our allowed days map
        if (daysMap.containsKey(day)) {
          dailyEarnings[day] = (dailyEarnings[day] ?? 0) + booking.commission;
          dailyBookingCounts[day] = (dailyBookingCounts[day] ?? 0) + 1;
        }
      }
    }

    _earningsData = dailyEarnings.entries
        .map((entry) => ChartData(
              x: DateTime(now.year, now.month, entry.key),
              y: entry.value,
            ))
        .toList();

    _bookingsData = dailyBookingCounts.entries
        .map((entry) => ChartData(
              x: DateTime(now.year, now.month, entry.key),
              y: entry.value,
            ))
        .toList();

    _earningsData.sort((a, b) => a.x.compareTo(b.x));
    _bookingsData.sort((a, b) => a.x.compareTo(b.x));
  }

  int get _totalBookings => _bookings.length;
  double get _totalEarnings =>
      _bookings.fold(0, (sum, booking) => sum + booking.commission);
  int get _activeHotels => _hotels.where((hotel) => hotel.isSubscribed).length;
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
                  child: CircularProgressIndicator(color: ThemeColors.primary),
                )
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
                        ),
                      ),
                    ];
                  },
                  body: _buildOverviewContent(),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _loadDashboardData,
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
              child: Icon(
                Iconsax.chart_square,
                color: ThemeColors.white.withOpacity(0.2),
                size: 200,
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
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            admin.name,
                            style: const TextStyle(
                              color: ThemeColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildTimeFilterChip(String label, String value) {
    final isSelected = _timeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() {
        _timeFilter = value;
        _loadDashboardData(); // Reload data when filter changes
      }),
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
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  Text(
                    L10n.of(context).performanceAnalytics,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildChartToggleButton(
                          L10n.of(context).earnings, _showEarningsChart),
                      const SizedBox(width: 8),
                      _buildChartToggleButton(
                          L10n.of(context).bookings, !_showEarningsChart),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 240,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SfCartesianChart(
                      margin: EdgeInsets.zero,
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
                      legend: Legend(isVisible: false),
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _showEarningsChart
                        ? L10n.of(context).dailyEarnings
                        : L10n.of(context).dailyBookings,
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
      onTap: () => setState(
          () => _showEarningsChart = label == L10n.of(context).earnings),
      borderRadius: BorderRadius.circular(20),
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
                  Text(
                    L10n.of(context).topPerformingHotels,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.primaryTransparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      L10n.of(context).top5,
                      style: const TextStyle(
                        color: ThemeColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_topPerformingHotels.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    L10n.of(context).noHotelsAvailable,
                    style: const TextStyle(color: ThemeColors.textSecondary),
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

  Widget _buildOverviewContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.of(context).dashboardOverview,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  L10n.of(context).monitorPerformance,
                  style: const TextStyle(
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
                      _buildTimeFilterChip(L10n.of(context).today, 'today'),
                      const SizedBox(width: 8),
                      _buildTimeFilterChip(
                          L10n.of(context).last7Days, 'last7days'),
                      const SizedBox(width: 8),
                      _buildTimeFilterChip(
                          L10n.of(context).thisMonth, 'thisMonth'),
                      const SizedBox(width: 8),
                      _buildTimeFilterChip(
                          L10n.of(context).lastMonth, 'lastMonth'),
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
              crossAxisCount: 1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildListDelegate([
              _buildMetricCard(
                title: L10n.of(context).totalBookings,
                value: _totalBookings.toString(),
                icon: Iconsax.calendar,
                color: ThemeColors.accentPurple,
              ),
              _buildMetricCard(
                title: L10n.of(context).totalEarnings,
                value: '\$${_totalEarnings.toStringAsFixed(2)}',
                icon: Iconsax.money,
                color: ThemeColors.success,
              ),
              _buildMetricCard(
                title: L10n.of(context).activeHotels,
                value: _activeHotels.toString(),
                icon: Iconsax.building,
                color: ThemeColors.info,
              ),
              _buildMetricCard(
                title: L10n.of(context).totalVisitors,
                value: _totalVisitors.toString(),
                icon: Iconsax.user,
                color: ThemeColors.accentDeep,
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
                  Text(
                    L10n.of(context).recentBookings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (_recentBookings.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    L10n.of(context).noBookingsAvailable,
                    style: const TextStyle(color: ThemeColors.textSecondary),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Flexible(
                        child: Text(
                          '(${hotel.ratings.totalRating} ${L10n.of(context).reviews})',
                          style: const TextStyle(
                            color: ThemeColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                hotel.isSubscribed
                    ? L10n.of(context).active
                    : L10n.of(context).inactive,
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
      ),
    );
  }

  Widget _buildBookingListItem(BookingWithDetails booking) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow.withOpacity(0.05),
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
            '${L10n.of(context).booking} #${booking.booking.id.substring(0, 8)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${dateFormat.format(booking.booking.checkInDate)} - '
                '${dateFormat.format(booking.booking.checkOutDate)}',
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
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ChartData {
  final DateTime x;
  final double y;

  ChartData({required this.x, required this.y});
}
