import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/services/stream/visitor_favorites_stream.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final String hotelId;

  const FavoriteButton({Key? key, required this.hotelId}) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isLoading = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteState();
  }

  Future<void> _initializeFavoriteState() async {
    final favoritesList = await VisitorFavoritesStream.favoritesStream.first;
    if (mounted) {
      setState(() {
        isFavorite = favoritesList.contains(widget.hotelId);
      });
    }
  }

  Future<void> handleFavoriteTap() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    if (isFavorite) {
      await VisitorFavoritesStream.removeFavorite(widget.hotelId);
    } else {
      await VisitorFavoritesStream.addFavorite(widget.hotelId);
    }

    if (mounted) {
      setState(() {
        isFavorite = !isFavorite;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: isLoading ? null : handleFavoriteTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey("loading"),
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
                  key: ValueKey(isFavorite),
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
