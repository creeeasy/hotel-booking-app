import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

import '../../../enum/BottomBarType.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final BottomBarType bottomBarType;
  final Function(BottomBarType) onTabClick;

  const CustomBottomNavigationBar({
    Key? key,
    required this.bottomBarType,
    required this.onTabClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: BottomBarType.values.indexOf(bottomBarType),
      onTap: (index) => onTabClick(BottomBarType.values[index]),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.travel_explore, size: 28),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_online, size: 28),
          label: "Booking",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite, size: 28),
          label: "Favorite",
        ),
      ],
      selectedItemColor: VisitorThemeColors.primaryColor,
      unselectedItemColor: VisitorThemeColors.blackColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    );
  }
}
