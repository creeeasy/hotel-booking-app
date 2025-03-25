import 'package:fatiel/enum/hotel_nav_bar.dart';
import 'package:fatiel/screens/hotel/bookings_screen.dart';
import 'package:fatiel/screens/hotel/home_screen.dart';
import 'package:fatiel/screens/hotel/hotel_reviews_screen.dart';
import 'package:fatiel/screens/hotel/rooms_screen.dart';
import 'package:fatiel/screens/visitor/widget/bottom_navigation_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class HotelHomeView extends StatefulWidget {
  const HotelHomeView({super.key});

  @override
  State<HotelHomeView> createState() => _HotelHomeViewState();
}

class _HotelHomeViewState extends State<HotelHomeView> {
  HotelNavBar selectedTab = HotelNavBar.home;

  void onTabClick(HotelNavBar tabType) {
    setState(() {
      selectedTab = tabType;
    });
  }

  Widget getCurrentPage() {
    switch (selectedTab) {
      case HotelNavBar.home:
        return const HotelHomeScreen();
      case HotelNavBar.rooms:
        return const RoomsScreen();
      case HotelNavBar.bookings:
        return const BookingsScreen();
      case HotelNavBar.reviews:
        return const HotelReviewsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: VisitorThemeColors.whiteColor,
        body: getCurrentPage(),
        bottomNavigationBar: CustomBottomNavigationBar<HotelNavBar>(
          selectedTab: selectedTab,
          tabs: HotelNavBar.values,
          onTabClick: (tab) {
            setState(() {
              selectedTab = tab;
            });
          },
          getTabIcon: (tab) {
            switch (tab) {
              case HotelNavBar.home:
                return const Icon(Icons.home, size: 28);
              case HotelNavBar.rooms:
                return const Icon(Icons.bed, size: 28);
              case HotelNavBar.bookings:
                return const Icon(Icons.book_online, size: 28);
              case HotelNavBar.reviews:
                return const Icon(Icons.star, size: 28);
            }
          },
          getTabLabel: (tab) {
            switch (tab) {
              case HotelNavBar.home:
                return 'Home';
              case HotelNavBar.rooms:
                return 'Rooms';
              case HotelNavBar.bookings:
                return 'Bookings';
              case HotelNavBar.reviews:
                return 'Reviews';
            }
          },
        ),
      ),
    );
  }
}
