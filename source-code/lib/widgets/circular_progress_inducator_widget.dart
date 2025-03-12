import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final Color? indicatorColor;
  final Color? containerColor;

  const CircularProgressIndicatorWidget({
    super.key,
    this.indicatorColor,
    this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: containerColor ??
            VisitorThemeColors.whiteColor, // Updated background color
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor ??
              VisitorThemeColors.playfulLime), // Updated indicator color
        ),
      ),
    );
  }
}
