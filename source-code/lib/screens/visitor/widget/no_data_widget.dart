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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox,
              color: VisitorThemeColors.greyColor,
              size: 50,
            ),
            const SizedBox(height: 12),
            const Text(
              "No Data Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VisitorThemeColors.blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: VisitorThemeColors.textGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
