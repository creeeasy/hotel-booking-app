import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
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
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - animation!.value),
              0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "$titleTxt ($hotelsCount)",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.5,
                        color: VisitorThemeColors.primaryColor,
                      ),
                    ),
                  ),
                  isLeftButton && (hotelsCount ?? 0) > 0
                      ? InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: click,
                          splashColor: VisitorThemeColors.accentColor,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  subTxt,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: VisitorThemeColors.secondaryColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 38,
                                  width: 26,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 18,
                                    color: VisitorThemeColors.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
