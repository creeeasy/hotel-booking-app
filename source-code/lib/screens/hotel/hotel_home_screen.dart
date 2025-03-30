import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/enum/hotel_nav_bar.dart';
import 'package:fatiel/screens/hotel/bookings_screen.dart';
import 'package:fatiel/screens/hotel/home_screen.dart';
import 'package:fatiel/screens/hotel/hotel_profile_screen.dart';
import 'package:fatiel/screens/hotel/hotel_reviews_screen.dart';
import 'package:fatiel/screens/hotel/rooms_screen.dart';
import 'package:fatiel/screens/visitor/widget/bottom_navigation_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
        return const HotelRoomsPage();
      case HotelNavBar.bookings:
        return const HotelBookingsPage();
      case HotelNavBar.reviews:
        return const HotelReviewsScreen();
      case HotelNavBar.profile:
        return const HotelProfileView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
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
                return Iconsax.home;
              case HotelNavBar.rooms:
                return Iconsax.building_3;
              case HotelNavBar.bookings:
                return Iconsax.calendar;
              case HotelNavBar.reviews:
                return Iconsax.star;
              case HotelNavBar.profile:
                return Iconsax.profile_circle;
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
              case HotelNavBar.profile:
                return 'Profile';
            }
          },
          elevation: 12.0,
        ),
      ),
    );
  }
}
