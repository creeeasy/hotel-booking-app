import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:flutter/material.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final double strockWidth;
  final double size;
  const CircularProgressIndicatorWidget({
    super.key,
    this.size = 40,
    this.strockWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: ThemeColors.background),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strockWidth,
            valueColor: const AlwaysStoppedAnimation<Color>(
                ThemeColors.primary), // Updated indicator color
          ),
        ),
      ),
    );
  }
}
