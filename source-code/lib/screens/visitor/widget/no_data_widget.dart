import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String message;

  const NoDataWidget({
    Key? key,
    this.message = "No data available at the moment.",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox,
              color: VisitorThemeColors.greyColor.withOpacity(0.7),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              "No Data Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: VisitorThemeColors.blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: VisitorThemeColors.textGreyColor.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
