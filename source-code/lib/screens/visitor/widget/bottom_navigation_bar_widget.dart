import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class CustomBottomNavigationBar<T> extends StatelessWidget {
  final T selectedTab;
  final List<T> tabs;
  final Function(T) onTabClick;
  final Icon Function(T) getTabIcon;
  final String Function(T) getTabLabel;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedTab,
    required this.tabs,
    required this.onTabClick,
    required this.getTabIcon,
    required this.getTabLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: VisitorThemeColors.whiteColor,
      currentIndex: tabs.indexOf(selectedTab),
      onTap: (index) => onTabClick(tabs[index]),
      items: tabs.map((tab) {
        return BottomNavigationBarItem(
          icon: getTabIcon(tab),
          label: getTabLabel(tab),
        );
      }).toList(),
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
