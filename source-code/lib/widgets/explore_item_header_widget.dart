// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class ExploreItemHeaderWidget extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final int? hotelsCount;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback? click;
  final bool isLeftButton;

  const ExploreItemHeaderWidget({
    Key? key,
    this.titleTxt = "",
    this.subTxt = "",
    this.hotelsCount,
    this.animationController,
    this.animation,
    this.click,
    this.isLeftButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - animation!.value)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "$titleTxt ($hotelsCount)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: VisitorThemeColors.primaryColor,
                      ),
                    ),
                  ),
                  if (isLeftButton && (hotelsCount ?? 0) > 0)
                    InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: click,
                      splashColor: VisitorThemeColors.accentColor,
                      child: Container(
                        padding: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              subTxt,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: VisitorThemeColors.secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: VisitorThemeColors.secondaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
