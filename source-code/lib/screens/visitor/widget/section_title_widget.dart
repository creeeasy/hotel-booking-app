import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Color titleColor;
  final IconData? icon; // Make icon optional
  final double iconSize;
  final Color iconColor;
  final double spacing;
  final TextStyle? textStyle;
  final CrossAxisAlignment alignment;

  const SectionTitle({
    Key? key,
    required this.title,
    this.titleColor = ThemeColors.accentDeep,
    this.icon,
    this.iconSize = 20,
    this.iconColor = ThemeColors.primary,
    this.spacing = 8,
    this.textStyle,
    this.alignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 18,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: titleColor,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
            SizedBox(width: spacing),
          ],
          Flexible(
            child: Text(
              title,
              style: textStyle ?? defaultStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
