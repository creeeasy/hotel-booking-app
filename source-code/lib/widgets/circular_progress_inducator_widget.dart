import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final Color? indicatorColor;
  final Color? containerColor;
  final double strockWidth;
  final double size;
  const CircularProgressIndicatorWidget({
    super.key,
    this.indicatorColor,
    this.containerColor,
    this.size = 40,
    this.strockWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: containerColor ??
            VisitorThemeColors.whiteColor, // Updated background color
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strockWidth,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor ??
                VisitorThemeColors.playfulLime), // Updated indicator color
          ),
        ),
      ),
    );
  }
}
