import 'package:fatiel/models/booking_with_details.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/services/booking/booking_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // State variables
  List<BookingWithDetails> _bookings = [];
  List<Hotel> _hotels = [];
  int _totalVisitors = 0;
  bool _isLoading = true;
  String _timeFilter = 'thisMonth';

  // Chart data
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

        // Generate chart data
        _generateChartData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading dashboard data: $e');
    }
  }

  void _generateChartData() {
    // Generate sample data - in a real app, this would come from your backend
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    _earningsData = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final randomEarnings = 500 + (1000 * (index % 7)).toDouble();
      return ChartData(
        x: DateTime(now.year, now.month, day),
        y: randomEarnings,
      );
    });

    _bookingsData = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final randomBookings = 5 + (index % 10).toDouble();
      return ChartData(
        x: DateTime(now.year, now.month, day),
        y: randomBookings,
      );
    });
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

  void _applyTimeFilter(String filter) {
    setState(() {
      _timeFilter = filter;

      switch (filter) {
        case 'today':
          break;
        case 'last7days':
          break;
        case 'thisMonth':
          break;
        case 'lastMonth':
          break;
        case 'custom':
        default:
          // Keep existing dates
          break;
      }

      // In a real app, you would reload data with the new filter
      // _loadDashboardData();
    });
  }

  // Calculate metrics
  int get _totalBookings => _bookings.length;

  double get _totalEarnings {
    return _bookings.fold(0, (sum, booking) => sum + booking.commission);
  }

  int get _activeHotels {
    return _hotels.where((hotel) => hotel.isSubscribed).length;
  }

  double get _monthlyGrowth {
    // Sample growth calculation - in a real app, compare with previous period
    return 12.5; // 12.5% growth
  }

  List<Hotel> get _topPerformingHotels {
    // Sort hotels by bookings (simplified - in a real app you'd have actual booking counts)
    return List.from(_hotels)
      ..sort((a, b) => b.ratings.totalRating.compareTo(a.ratings.totalRating))
      ..take(5).toList();
  }

  List<BookingWithDetails> get _recentBookings {
    return _bookings.take(5).toList();
  }

  void _exportReport() {
    // In a real app, this would generate and download a report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting report...'),
        backgroundColor: ThemeColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        backgroundColor: ThemeColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Iconsax.document_download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time filter controls
                  _buildTimeFilterSection(),
                  const SizedBox(height: 16),

                  // Key metrics overview
                  _buildKeyMetricsSection(),
                  const SizedBox(height: 24),

                  // Charts section
                  _buildChartsSection(),
                  const SizedBox(height: 24),

                  // Top performing hotels
                  _buildTopHotelsSection(),
                  const SizedBox(height: 24),

                  // Recent bookings
                  _buildRecentBookingsSection(),
                  const SizedBox(height: 24),

                  // Admin notifications
                  _buildNotificationsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeFilterSection() {
    return SingleChildScrollView(
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
          const SizedBox(width: 8),
          _buildTimeFilterChip('Custom Range', 'custom'),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip(String label, String value) {
    final isSelected = _timeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _applyTimeFilter(value),
      selectedColor: ThemeColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : ThemeColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildKeyMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMetricCard(
              title: 'Total Bookings',
              value: _totalBookings.toString(),
              icon: Iconsax.calendar,
              color: ThemeColors.accentPurple,
            ),
            _buildMetricCard(
              title: 'Total Earnings',
              value: '\$${_totalEarnings.toStringAsFixed(2)}',
              icon: Iconsax.money,
              color: ThemeColors.success,
            ),
            _buildMetricCard(
              title: 'Active Hotels',
              value: _activeHotels.toString(),
              icon: Iconsax.building,
              color: ThemeColors.info,
            ),
            _buildMetricCard(
              title: 'Total Visitors',
              value: _totalVisitors.toString(),
              icon: Iconsax.user,
              color: ThemeColors.accentDeep,
            ),
            _buildMetricCard(
              title: 'Monthly Growth',
              value: '${_monthlyGrowth.toStringAsFixed(1)}%',
              icon: _monthlyGrowth >= 0
                  ? Iconsax.arrow_up_2
                  : Iconsax.arrow_down_1,
              color:
                  _monthlyGrowth >= 0 ? ThemeColors.success : ThemeColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                if (title == 'Monthly Growth')
                  Icon(
                    _monthlyGrowth >= 0
                        ? Iconsax.arrow_up_2
                        : Iconsax.arrow_down_1,
                    color: color,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildChartToggleButton('Earnings', _showEarningsChart),
                    const SizedBox(width: 8),
                    _buildChartToggleButton('Bookings', !_showEarningsChart),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      dateFormat: DateFormat.MMMd(),
                      intervalType: DateTimeIntervalType.days,
                    ),
                    series: <CartesianSeries>[
                      _showEarningsChart
                          ? LineSeries<ChartData, DateTime>(
                              dataSource: _earningsData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: ThemeColors.primary,
                              width: 3,
                              markerSettings: const MarkerSettings(
                                isVisible: true,
                                shape: DataMarkerType.circle,
                                borderWidth: 2,
                                borderColor: ThemeColors.primary,
                              ),
                            )
                          : ColumnSeries<ChartData, DateTime>(
                              dataSource: _bookingsData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: ThemeColors.accentPurple,
                              width: 0.6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartToggleButton(String label, bool isActive) {
    return InkWell(
      onTap: () => setState(() => _showEarningsChart = label == 'Earnings'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? ThemeColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? ThemeColors.primary : ThemeColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : ThemeColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTopHotelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Performing Hotels',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _topPerformingHotels
                  .map((hotel) => _buildHotelListItem(hotel))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotelListItem(Hotel hotel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Hotel image
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
                  : const DecorationImage(
                      image: AssetImage('assets/hotel_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Hotel details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.hotelName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Iconsax.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      hotel.ratings.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Earnings stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(hotel.ratings.totalRating * 150).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${hotel.ratings.totalRating} bookings',
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _recentBookings
                  .map((booking) => _buildBookingListItem(booking))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingListItem(BookingWithDetails booking) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Visitor avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColors.primary.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                booking.visitorName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Booking details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.visitorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.hotelName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Amount and date
          Column(
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
                DateFormat('MMM dd').format(booking.booking.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    // Sample notifications - in a real app these would come from your backend
    final notifications = [
      _NotificationItem(
        title: 'Low-performing hotel',
        message: 'Hotel Sahara has had no bookings this month',
        icon: Iconsax.warning_2,
        color: ThemeColors.warning,
      ),
      _NotificationItem(
        title: 'Subscription expiring',
        message: 'Golden Tulip subscription ends in 3 days',
        icon: Iconsax.calendar_tick,
        color: ThemeColors.info,
      ),
      _NotificationItem(
        title: 'Unusual activity',
        message: 'Spike in bookings detected for Plaza Hotel',
        icon: Iconsax.activity,
        color: ThemeColors.accentPurple,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: notifications
                  .map((notification) => _buildNotificationItem(notification))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(_NotificationItem notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Notification icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: notification.color.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.textSecondary,
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

class ChartData {
  final DateTime x;
  final double y;

  ChartData({required this.x, required this.y});
}

class _NotificationItem {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}
