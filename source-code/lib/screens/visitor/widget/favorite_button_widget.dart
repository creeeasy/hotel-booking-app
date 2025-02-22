// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final Future<void> Function() onTap;
  final bool isFavorite;

  const FavoriteButton({
    Key? key,
    required this.onTap,
    required this.isFavorite,
  }) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isLoading = false;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  Future<void> triggerClick() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    await widget.onTap();

    if (mounted) {
      setState(() {
        isLoading = false;
        isFavorite = !isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32.0),
      onTap: isLoading ? null : triggerClick,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (widget, animation) => ScaleTransition(
            scale: animation,
            child: widget,
          ),
          child: isLoading
              ? SizedBox(
                  key: ValueKey<bool>(isLoading),
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      VisitorThemeColors.primaryColor,
                    ),
                  ),
                )
              : Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(isFavorite),
                  color: isFavorite
                      ? VisitorThemeColors.deepPurpleAccent
                      : Colors.grey,
                  semanticLabel:
                      isFavorite ? "Remove from favorites" : "Add to favorites",
                ),
        ),
      ),
    );
  }
}
