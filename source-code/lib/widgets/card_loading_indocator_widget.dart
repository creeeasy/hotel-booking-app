import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class CardLoadingIndicator extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final Color indicatorColor;
  final EdgeInsets padding;

  const CardLoadingIndicator({
    Key? key,
    this.height = 250,
    this.backgroundColor = VisitorThemeColors.whiteColor,
    this.indicatorColor = VisitorThemeColors.radiantPink,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          color: indicatorColor,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
