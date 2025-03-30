import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/screens/visitor/widget/favorite_button_widget.dart';
import 'package:flutter/material.dart';

class PositionedFavoriteButton extends StatelessWidget {
  final String hotelId;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const PositionedFavoriteButton({
    Key? key,
    required this.hotelId,
    this.top,
    this.right,
    this.bottom,
    this.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ?? 16,
      right: right ?? 16,
      bottom: bottom,
      left: left,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ThemeColors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1), // For the border effect
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: null, // Let FavoriteButton handle the tap
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOutBack,
              switchOutCurve: Curves.easeInOutBack,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: FavoriteButton(
                hotelId: hotelId,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
