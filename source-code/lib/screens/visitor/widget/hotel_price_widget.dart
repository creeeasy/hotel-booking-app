import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class HotelPriceWidget extends StatelessWidget {
  final double startingPricePerNight;

  const HotelPriceWidget({super.key, required this.startingPricePerNight});

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${startingPricePerNight.toStringAsFixed(2)} / night',
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: VisitorThemeColors.blackColor,
      ),
    );
  }
}
