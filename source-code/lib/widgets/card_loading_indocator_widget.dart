import 'package:flutter/material.dart';

class CardLoadingIndicator extends StatelessWidget {
  final double height;
  final Color borderColor;
  final Color backgroundColor;
  final Color indicatorColor;
  final double borderWidth;
  final EdgeInsets padding;

  const CardLoadingIndicator({
    Key? key,
    this.height = 100,
    this.borderColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.indicatorColor = Colors.deepPurpleAccent,
    this.borderWidth = 2,
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
          border: Border.all(
              color: borderColor.withOpacity(0.3), width: borderWidth),
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
