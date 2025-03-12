import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class SectionHeader extends StatelessWidget {
  final VoidCallback onSeeAllTap;
  final String title;

  const SectionHeader({
    Key? key,
    required this.onSeeAllTap,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: VisitorThemeColors.primaryColor,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: onSeeAllTap,
          splashColor: VisitorThemeColors.primaryColor.withOpacity(0.7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: VisitorThemeColors.primaryColor.withOpacity(0.1), // Light blue background
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Text(
                  "See all",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VisitorThemeColors.primaryColor.withOpacity(0.8), // More visible
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: VisitorThemeColors.primaryColor.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
