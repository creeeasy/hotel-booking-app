import 'package:fatiel/enum/bottom_bar_type.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

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
      backgroundColor: VisitorThemeColors.whiteColor,
      currentIndex: BottomBarType.values.indexOf(bottomBarType),
      onTap: (index) => onTabClick(BottomBarType.values[index]),
      items: const [
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
      unselectedItemColor: VisitorThemeColors.textGreyColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
      ),
    );
  }
}
