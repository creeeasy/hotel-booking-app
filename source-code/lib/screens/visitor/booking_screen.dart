import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/screens/visitor/widget/booking_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late BookingStatus selectedTab;

  @override
  void initState() {
    super.initState();
    selectedTab = BookingStatus.pending;
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
                icon: const Icon(
                  Icons.search,
                  size: 28,
                ),
                color: VisitorThemeColors.primaryColor,
                onPressed: () {},
                tooltip: 'Search',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _tabView(
            selectedTab: selectedTab,
            onTabChange: (BookingStatus newTab) {
              setState(() {
                selectedTab = newTab;
              });
            },
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final currentUserId = (state.currentUser as Visitor).id;
            return Expanded(
              child: FutureBuilder<List<String>>(
                future: Visitor.getUserBookings(currentUserId, selectedTab),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color:
                          VisitorThemeColors.deepPurpleAccent.withOpacity(0.8),
                    ));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildNoBookingsUI();
                  }
                  final bookings = snapshot.data!;

                  return ListView.builder(
                    itemCount: bookings.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemBuilder: (context, index) {
                      final count = bookings.length > 10 ? 10 : bookings.length;
                      final animation = Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: animationController,
                          curve: Interval(
                            (1 / count) * index,
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
                },
              ),
            );
          },
        ),
      ],
    );
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
