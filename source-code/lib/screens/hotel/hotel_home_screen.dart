import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/enum/hotel_nav_bar.dart';
import 'package:fatiel/screens/hotel/bookings_screen.dart';
import 'package:fatiel/screens/hotel/hotel_dashboard_screen.dart';
import 'package:fatiel/screens/hotel/hotel_profile_screen.dart';
import 'package:fatiel/screens/hotel/hotel_reviews_screen.dart';
import 'package:fatiel/screens/hotel/rooms_screen.dart';
import 'package:fatiel/screens/visitor/widget/bottom_navigation_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fatiel/l10n/l10n.dart';

class HotelHomeView extends StatefulWidget {
  const HotelHomeView({
    super.key,
    this.initialTab = HotelNavBar.home,
  });

  final HotelNavBar initialTab;

  @override
  State<HotelHomeView> createState() => _HotelHomeViewState();
}

class _HotelHomeViewState extends State<HotelHomeView> {
  late HotelNavBar selectedTab;

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
  }

  // Public method to navigate to specific tab
  void navigateTo(HotelNavBar tab) {
    if (mounted) {
      setState(() {
        selectedTab = tab;
      });
    }
  }

  void onTabClick(HotelNavBar tabType) {
    navigateTo(tabType);
  }

  Widget getCurrentPage() {
    switch (selectedTab) {
      case HotelNavBar.home:
        return HotelDashboardScreen(
          onNavigate: navigateTo,
        );
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
          onTabClick: onTabClick,
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
                return L10n.of(context).home;
              case HotelNavBar.rooms:
                return L10n.of(context).rooms;
              case HotelNavBar.bookings:
                return L10n.of(context).bookings;
              case HotelNavBar.reviews:
                return L10n.of(context).reviews;
              case HotelNavBar.profile:
                return L10n.of(context).profile;
            }
          },
          elevation: 12.0,
        ),
      ),
    );
  }
}
