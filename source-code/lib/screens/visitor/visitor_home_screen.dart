import 'package:fatiel/screens/visitor/booking_screen.dart';
import 'package:fatiel/screens/visitor/explore_screen.dart';
import 'package:fatiel/screens/visitor/favorite_screen.dart';
import 'package:fatiel/screens/visitor/widget/bottom_navigation_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import '../../enum/visitor_nav_bar.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  VisitorNavBar selectedTab = VisitorNavBar.explore;

  void onTabClick(VisitorNavBar tabType) {
    setState(() {
      selectedTab = tabType;
    });
  }

  Widget getCurrentPage() {
    switch (selectedTab) {
      case VisitorNavBar.explore:
        return ExploreView();
      case VisitorNavBar.booking:
        return const BookingView();
      case VisitorNavBar.favorite:
        return const FavoritePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: VisitorThemeColors.whiteColor,
        body: getCurrentPage(),
        bottomNavigationBar: CustomBottomNavigationBar<VisitorNavBar>(
          selectedTab: selectedTab,
          tabs: VisitorNavBar.values,
          onTabClick: onTabClick,
          getTabIcon: (tab) {
            switch (tab) {
              case VisitorNavBar.explore:
                return const Icon(Icons.travel_explore, size: 28);
              case VisitorNavBar.booking:
                return const Icon(Icons.book_online, size: 28);
              case VisitorNavBar.favorite:
                return const Icon(Icons.favorite, size: 28);
            }
          },
          getTabLabel: (tab) {
            switch (tab) {
              case VisitorNavBar.explore:
                return 'Explore';
              case VisitorNavBar.booking:
                return 'Booking';
              case VisitorNavBar.favorite:
                return 'Favorite';
            }
          },
        ),
      ),
    );
  }
}
