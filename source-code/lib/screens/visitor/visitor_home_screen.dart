import 'package:fatiel/constants/colors/theme_colors.dart';
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
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
      ),
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
            return Iconsax.search_normal;
          case VisitorNavBar.booking:
            return Iconsax.calendar;
          case VisitorNavBar.favorite:
            return Iconsax.heart;
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
      elevation: 8.0,
    );
  }
}
