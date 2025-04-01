import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/services/stream/visitor_favorites_stream.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FavoriteButton extends StatefulWidget {
  final String hotelId;
  final double size;
  final bool showConfirmation;
  final bool showSnackbar;

  const FavoriteButton({
    Key? key,
    required this.hotelId,
    this.size = 24.0,
    this.showConfirmation = true,
    this.showSnackbar = true,
  }) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isLoading = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteState();
  }

  Future<void> _initializeFavoriteState() async {
    final favoritesList = await VisitorFavoritesStream.favoritesStream.first;
    if (!mounted) return;
    setState(() => _isFavorite = favoritesList.contains(widget.hotelId));
  }

  Future<void> _handleFavoriteTap() async {
    if (_isLoading || !mounted) return;

    if (widget.showConfirmation && _isFavorite) {
      final shouldRemove = await showGenericDialog<bool>(
        context: context,
        title: 'Remove from Favorites',
        content:
            'Are you sure you want to remove this hotel from your favorites?',
        showIcon: true,
        icon: Iconsax.heart_slash,
        optionBuilder: () => {'Cancel': false, 'Remove': true},
      );

      if (shouldRemove != true) return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isFavorite) {
        await VisitorFavoritesStream.removeFavorite(widget.hotelId);
      } else {
        await VisitorFavoritesStream.addFavorite(widget.hotelId);
      }

      if (mounted) {
        setState(() => _isFavorite = !_isFavorite);
        if (widget.showSnackbar) {
          _showStatusSnackbar();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showStatusSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        backgroundColor: ThemeColors.darkBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update favorites: $error'),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = ThemeColors.primary;
    const inactiveColor = ThemeColors.textSecondary;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.size),
        onTap: _isLoading ? null : _handleFavoriteTap,
        splashColor: activeColor.withOpacity(0.2),
        highlightColor: activeColor.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.all(widget.size * 0.33),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: activeColor,
                    ),
                  )
                : Icon(
                    _isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    key: ValueKey(_isFavorite),
                    size: widget.size,
                    color: _isFavorite ? activeColor : inactiveColor,
                    semanticLabel: _isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                  ),
          ),
        ),
      ),
    );
  }
}
