import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/screens/visitor/widget/favorite_button_widget.dart';
import 'package:flutter/material.dart';

class PositionedFavoriteButton extends StatelessWidget {
  final String hotelId;

  const PositionedFavoriteButton({
    Key? key,
    required this.hotelId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: const BoxDecoration(
          color: VisitorThemeColors.whiteColor,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: FavoriteButton(hotelId: hotelId),
          ),
        ),
      ),
    );
  }
}
