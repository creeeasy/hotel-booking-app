import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/visitor_nav_bar.dart';
import 'package:fatiel/screens/visitor/booking_screen.dart';
import 'package:fatiel/screens/visitor/explore_screen.dart';
import 'package:fatiel/screens/visitor/favorite_screen.dart';
import 'package:fatiel/screens/visitor/widget/bottom_navigation_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  VisitorNavBar _selectedTab = VisitorNavBar.explore;
  final _pageController = PageController(initialPage: 0);

  void _onTabClick(VisitorNavBar tabType) {
    setState(() {
      _selectedTab = tabType;
      _pageController.jumpToPage(tabType.index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ExploreView(),
          BookingView(),
          FavoritePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return CustomBottomNavigationBar<VisitorNavBar>(
      selectedTab: _selectedTab,
      tabs: VisitorNavBar.values,
      onTabClick: _onTabClick,
      getTabIcon: (tab) {
        switch (tab) {
          case VisitorNavBar.explore:
            return const Icon(Iconsax.search_normal, size: 24);
          case VisitorNavBar.booking:
            return const Icon(Iconsax.calendar, size: 24);
          case VisitorNavBar.favorite:
            return const Icon(Iconsax.heart, size: 24);
        }
      },
      getTabLabel: (tab) {
        switch (tab) {
          case VisitorNavBar.explore:
            return 'Explore';
          case VisitorNavBar.booking:
            return 'Bookings';
          case VisitorNavBar.favorite:
            return 'Favorites';
        }
      },
    );
  }
}
