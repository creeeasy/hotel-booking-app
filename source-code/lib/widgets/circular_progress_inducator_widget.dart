import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter/material.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final Color? indicatorColor;
  final Color? containerColor;

  const CircularProgressIndicatorWidget(
      {super.key, this.indicatorColor, this.containerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.lightGrayColor,
      child: Center(
        child: CircularProgressIndicator(
          color: ThemeColors.primaryColor,
        ),
      ),
    );
  }
}
