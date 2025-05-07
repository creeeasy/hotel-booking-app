import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/screens/admin/admins_management_page.dart';
import 'package:fatiel/screens/admin/admin_bookings_page.dart';
import 'package:fatiel/screens/admin/dashboard_page.dart';
import 'package:fatiel/screens/admin/hotels_management_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentPageIndex = 0;
  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const HotelsManagementPage(),
    const AdminBookingsPage(),
    const AdminsManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPageIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentPageIndex,
      onTap: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      selectedItemColor: ThemeColors.primary,
      unselectedItemColor: ThemeColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.building_3),
          label: 'Hotels',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.calendar),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.profile_2user),
          label: 'Admins',
        ),
      ],
    );
  }
}
