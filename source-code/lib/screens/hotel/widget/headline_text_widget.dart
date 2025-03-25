import 'package:flutter/material.dart';

class HeadlineText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;

  const HeadlineText({
    Key? key,
    required this.text,
    this.fontSize = 24,
    this.textColor = const Color(0xFF1D3557),
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.start,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }
}
