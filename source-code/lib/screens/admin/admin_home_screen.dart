import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/enum/admin_nav_bar.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/screens/admin/admin_bookings_page.dart';
import 'package:fatiel/screens/admin/admin_dashboard_page.dart';
import 'package:fatiel/screens/admin/admins_management_page.dart';
import 'package:fatiel/screens/admin/hotels_management_page.dart';
import 'package:fatiel/screens/visitor/widget/bottom_navigation_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  AdminNavBar _selectedTab = AdminNavBar.dashboard;
  final _pageController = PageController(initialPage: 0);

  void _onTabClick(AdminNavBar tabType) {
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
            AdminDashboardPage(),
            HotelsManagementPage(),
            AdminBookingsPage(),
            AdminsManagementPage(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return CustomBottomNavigationBar<AdminNavBar>(
      selectedTab: _selectedTab,
      tabs: AdminNavBar.values,
      onTabClick: _onTabClick,
      getTabIcon: (tab) {
        switch (tab) {
          case AdminNavBar.dashboard:
            return Iconsax.home;
          case AdminNavBar.hotels:
            return Iconsax.building_3;
          case AdminNavBar.bookings:
            return Iconsax.calendar;
          case AdminNavBar.admins:
            return Iconsax.profile_2user;
        }
      },
      getTabLabel: (tab) {
        switch (tab) {
          case AdminNavBar.dashboard:
            return L10n.of(context).dashboard;
          case AdminNavBar.hotels:
            return L10n.of(context).hotels;
          case AdminNavBar.bookings:
            return L10n.of(context).bookings;
          case AdminNavBar.admins:
            return L10n.of(context).admins;
        }
      },
      elevation: 8.0,
    );
  }
}
