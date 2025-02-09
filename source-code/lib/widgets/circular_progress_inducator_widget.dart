import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter/material.dart';

Widget circularProgressIndicatorWidget() {
  return Container(
    color: ThemeColors.lightGrayColor,
    child: const Center(
      child: CircularProgressIndicator(
        color: ThemeColors.primaryColor,
      ),
    ),
  );
}
