import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/screens/visitor/widget/booking_widget.dart';
import 'package:fatiel/services/stream/visitor_bookings_stream.dart';
import 'package:flutter/material.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  BookingStatus _selectedTab = BookingStatus.pending;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    VisitorBookingsStream.listenToBookings(_selectedTab);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabChange(BookingStatus newTab) {
    if (_selectedTab == newTab) return;

    setState(() {
      _selectedTab = newTab;
      VisitorBookingsStream.listenToBookings(newTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildTabView(),
        Expanded(
          key: ValueKey(_selectedTab),
          child: StreamBuilder<List<String>>(
            stream: VisitorBookingsStream.bookingsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              }

              if (snapshot.hasError) {
                return _buildError(snapshot.error.toString());
              }

              final bookings = snapshot.data ?? [];
              return bookings.isEmpty
                  ? _buildNoBookingsUI()
                  : _buildBookingsList(bookings);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Bookings",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            color: VisitorThemeColors.primaryColor,
            onPressed: () {},
            tooltip: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: _tabView(selectedTab: _selectedTab, onTabChange: _onTabChange),
    );
  }

  Widget _buildBookingsList(List<String> bookings) {
    final itemCount =
        bookings.length.clamp(1, 10); // Limits max animation count

    return ListView.builder(
      itemCount: bookings.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (1 / itemCount) * index,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: BookingWidget(bookingId: bookings[index]),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: VisitorThemeColors.deepPurpleAccent.withOpacity(0.8),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(child: Text("Error: $error"));
  }
}

Widget _tabView({
  required BookingStatus selectedTab,
  required Function(BookingStatus) onTabChange,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double totalWidth = 0;
      final List<Widget> tabItems = [
        _buildTabItem(
          title: 'Pending',
          isSelected: selectedTab == BookingStatus.pending,
          onTap: () => onTabChange(BookingStatus.pending),
        ),
        _buildTabItem(
          title: 'Completed',
          isSelected: selectedTab == BookingStatus.completed,
          onTap: () => onTabChange(BookingStatus.completed),
        ),
        _buildTabItem(
          title: 'Cancelled',
          isSelected: selectedTab == BookingStatus.cancelled,
          onTap: () => onTabChange(BookingStatus.cancelled),
        ),
      ];

      for (var item in tabItems) {
        totalWidth += 100; // Approximate width of each tab, adjust if needed
      }

      bool isScrollable = totalWidth > constraints.maxWidth;

      return Column(
        children: <Widget>[
          if (isScrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: tabItems
                      .map((e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: e,
                          ))
                      .toList()),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tabItems,
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      );
    },
  );
}

Widget _buildTabItem({
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: isSelected ? VisitorThemeColors.pinkAccent : Colors.transparent,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          color: isSelected
              ? VisitorThemeColors.whiteColor
              : VisitorThemeColors.blackColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget _buildNoBookingsUI() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.bookmark_border,
          size: 80,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        const Text(
          'No bookings yet!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start booking your favorite hotels now.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black38,
          ),
        ),
      ],
    ),
  );
}
