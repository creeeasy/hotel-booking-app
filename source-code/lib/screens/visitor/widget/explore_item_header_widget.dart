import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ExploreItemHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback? onPressed;
  final bool showActionButton;
  final EdgeInsetsGeometry? padding;

  const ExploreItemHeaderWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.animationController,
    this.animation,
    this.onPressed,
    this.showActionButton = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding!,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (showActionButton && subtitle != null)
            TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: ThemeColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 20,
                    color: ThemeColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    if (animation != null && animationController != null) {
      return AnimatedBuilder(
        animation: animationController!,
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: animation!,
            child: Transform(
              transform: Matrix4.translationValues(
                0.0,
                30 * (1.0 - animation!.value),
                0.0,
              ),
              child: content,
            ),
          );
        },
      );
    }

    return content;
  }
}
