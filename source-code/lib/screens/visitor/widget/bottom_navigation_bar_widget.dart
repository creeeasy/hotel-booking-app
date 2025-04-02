import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';

class CustomBottomNavigationBar<T> extends StatelessWidget {
  final T selectedTab;
  final List<T> tabs;
  final ValueChanged<T> onTabClick;
  final IconData Function(T) getTabIcon;
  final String Function(T) getTabLabel;
  final double? elevation;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedTab,
    required this.tabs,
    required this.onTabClick,
    required this.getTabIcon,
    required this.getTabLabel,
    this.elevation = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ThemeColors.grey400.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: ThemeColors.white,
        currentIndex: tabs.indexOf(selectedTab),
        onTap: (index) => onTabClick(tabs[index]),
        elevation: elevation,
        items: tabs.map((tab) {
          final isSelected = tab == selectedTab;
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemeColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getTabIcon(tab),
                size: 24,
                color: isSelected
                    ? ThemeColors.primary
                    : ThemeColors.textSecondary,
              ),
            ),
            label: getTabLabel(tab),
          );
        }).toList(),
        selectedItemColor: ThemeColors.primary,
        unselectedItemColor: ThemeColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ThemeColors.primary,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: ThemeColors.textSecondary,
        ),
      ),
    );
  }
}
