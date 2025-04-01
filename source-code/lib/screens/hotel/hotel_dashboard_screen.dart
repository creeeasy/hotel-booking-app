import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/enum/hotel_nav_bar.dart';
import 'package:fatiel/helper/timestamp_formatter.dart';
import 'package:fatiel/models/activity_item.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/booking/booking_service.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/services/review/review_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class HotelDashboardScreen extends StatefulWidget {
  final Function(HotelNavBar)? onNavigate;

  const HotelDashboardScreen({super.key, this.onNavigate});

  @override
  State<HotelDashboardScreen> createState() => _HotelDashboardScreenState();
}

class _HotelDashboardScreenState extends State<HotelDashboardScreen> {
  late Function(HotelNavBar) onNavigate;
  late final Hotel hotel;
  late final Future<int> _fetchMonthlyBookingsFuture;
  late final Future<int> _fetchPendingBookingsFuture;
  late final Future<int> _fetchAvailableRoomsCountFuture;
  late final Future<int> _fetchReviewStatisticsFuture;
  late Future<List<ActivityItem>> _recentActivitiesFuture;

  @override
  void initState() {
    super.initState();
    onNavigate = widget.onNavigate!;
    final currentHotel = context.read<AuthBloc>().state.currentUser as Hotel;
    hotel = currentHotel;

    // Initialize futures
    _fetchMonthlyBookingsFuture =
        BookingService.fetchMonthlyBookingsFuture(hotelId: hotel.id);
    _fetchPendingBookingsFuture =
        BookingService.fetchPendingBookingsFuture(hotelId: hotel.id);
    _fetchAvailableRoomsCountFuture =
        ReviewService.fetchAvailableRoomsCountFuture(hotelId: hotel.id);
    _fetchReviewStatisticsFuture =
        ReviewService.fetchReviewStatisticsFuture(hotelId: hotel.id);
    _recentActivitiesFuture =
        HotelService.getRecentActivity(hotelId: currentHotel.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildMetricsSection(),
              const SizedBox(height: 28),
              _buildQuickAccessSection(),
              const SizedBox(height: 28),
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back, ${hotel.hotelName}!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s what\'s happening today',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ThemeColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      children: [
        Row(
          children: [
            _buildMetricCard(
              future: _fetchMonthlyBookingsFuture,
              title: 'Active Bookings',
              icon: Iconsax.book,
              color: ThemeColors.primary,
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              future: _fetchAvailableRoomsCountFuture,
              title: 'Rooms Available',
              icon: Iconsax.home,
              color: ThemeColors.success,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard(
              future: _fetchReviewStatisticsFuture,
              title: 'Total Reviews',
              icon: Iconsax.star,
              color: ThemeColors.star,
              isRating: true,
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              future: _fetchPendingBookingsFuture,
              title: 'Pending Bookings',
              icon: Iconsax.calendar_add,
              color: ThemeColors.accentPink,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required Future<int> future,
    required String title,
    required IconData icon,
    required Color color,
    bool isRating = false,
  }) {
    return Expanded(
      child: FutureBuilder<int>(
        future: future,
        builder: (context, snapshot) {
          return MetricCard(
            title: title,
            value: snapshot.hasData ? '${snapshot.data}' : '--',
            icon: icon,
            color: color,
            isRating: isRating,
            isLoading: snapshot.connectionState == ConnectionState.waiting,
          );
        },
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            NavigationTile(
              icon: Iconsax.home_2,
              title: 'Rooms',
              description: 'Manage room details',
              onTap: () => onNavigate(HotelNavBar.rooms),
            ),
            NavigationTile(
              icon: Iconsax.calendar,
              title: 'Bookings',
              description: 'View all bookings',
              onTap: () => onNavigate(HotelNavBar.bookings),
            ),
            NavigationTile(
              icon: Iconsax.star,
              title: 'Reviews',
              description: 'Check guest feedback',
              onTap: () => onNavigate(HotelNavBar.reviews),
            ),
            NavigationTile(
              icon: Iconsax.profile_2user,
              title: 'Profile',
              description: 'Hotel profile',
              onTap: () => onNavigate(HotelNavBar.profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ThemeColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<ActivityItem>>(
          future: _recentActivitiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: ThemeColors.primary,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                'No recent activity',
                style: TextStyle(color: ThemeColors.textSecondary),
              );
            }

            return Column(
              children: snapshot.data!
                  .map((activity) => ActivityItemWidget(
                        title: activity.title,
                        description: activity.description,
                        time: formatTimeDifference(activity.timestamp),
                        icon: activity.icon,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isRating;
  final bool isLoading;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isRating = false,
    this.isLoading = false,
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
            color: ThemeColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.textSecondary,
                    ),
              ),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ThemeColors.primary,
                  ),
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              if (isRating && !isLoading) ...[
                const SizedBox(width: 4),
                Icon(Iconsax.star1, size: 16, color: ThemeColors.star),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const NavigationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: ThemeColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ThemeColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;

  const ActivityItemWidget({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: ThemeColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.textPrimary,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ThemeColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
