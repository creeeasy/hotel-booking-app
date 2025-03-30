import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:flutter/material.dart';

class CardLoadingIndicator extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final Color indicatorColor;
  final EdgeInsets padding;

  const CardLoadingIndicator({
    super.key,
    required this.height,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.padding,
  });

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
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
