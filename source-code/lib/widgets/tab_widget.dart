import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class TabWidget<T> extends StatelessWidget {
  final T selectedTab;
  final List<T> tabs;
  final Function(T) onTabChange;
  final String Function(T) getTabTitle;

  const TabWidget({
    Key? key,
    required this.selectedTab,
    required this.tabs,
    required this.onTabChange,
    required this.getTabTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: tabs.map((tab) {
            return Expanded(
              child: _buildTabItem(
                title: getTabTitle(tab),
                isSelected: selectedTab == tab,
                onTap: () {
                  onTabChange(tab);
                },
              ),
            );
          }).toList(),
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        ),
      ],
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color:
              isSelected ? VisitorThemeColors.primaryColor : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14.0,
            color: isSelected
                ? VisitorThemeColors.whiteColor
                : VisitorThemeColors.blackColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
