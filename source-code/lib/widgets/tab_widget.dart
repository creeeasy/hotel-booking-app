import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/top_bar_type.dart';
import 'package:flutter/material.dart';

class TripsTabView extends StatelessWidget {
  final TopBarType selectedTab;
  final Function(TopBarType) onTabChange;

  const TripsTabView({
    Key? key,
    required this.selectedTab,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _buildTabItem(
                title: 'Popular',
                isSelected: selectedTab == TopBarType.Popular,
                onTap: () {
                  onTabChange(TopBarType.Popular);
                },
              ),
            ),
            Expanded(
              child: _buildTabItem(
                title: 'Near Me',
                isSelected: selectedTab == TopBarType.NearMe,
                onTap: () {
                  onTabChange(TopBarType.NearMe);
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        )
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
          borderRadius: BorderRadius.circular(16.0), // More compact
          color:
              isSelected ? VisitorThemeColors.primaryColor : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "Poppins",

            fontSize: 14.0, // Balanced size for tabs
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
