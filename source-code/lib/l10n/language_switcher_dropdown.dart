import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/providers/locale_provider.dart';

class LanguageSwitcherDropdown extends StatefulWidget {
  const LanguageSwitcherDropdown({super.key});

  @override
  State<LanguageSwitcherDropdown> createState() => _LanguageSwitcherDropdownState();
}

class _LanguageSwitcherDropdownState extends State<LanguageSwitcherDropdown> {
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              width: size.width * 1.5,
              left: offset.dx - (size.width * 0.25),
              top: offset.dy + size.height + 8,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 8),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                  child: _buildLanguageList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isDropdownOpen = true;
  }

  Future<void> _changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    if (mounted) {
      Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
    }
    _removeOverlay();
  }

  Widget _buildLanguageList() {
    final currentLocale = Provider.of<LocaleProvider>(context).locale ?? const Locale('en');
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: L10n.supportedLocales.map((locale) {
        final isSelected = locale.languageCode == currentLocale.languageCode;
        return InkWell(
          onTap: () => _changeLanguage(locale),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected 
                  ? theme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Iconsax.tick_circle, size: 20, color: ThemeColors.primary),
                if (isSelected) const SizedBox(width: 12),
                Text(
                  L10n.getLanguageName(locale.languageCode),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Provider.of<LocaleProvider>(context).locale ?? const Locale('en');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeColors.border.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.global,
                size: 20,
                color: isDark ? ThemeColors.white : ThemeColors.primaryDark,
              ),
              const SizedBox(width: 8),
              Text(
                L10n.getLanguageName(currentLocale.languageCode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? ThemeColors.white : ThemeColors.primaryDark,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isDropdownOpen ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                size: 16,
                color: isDark ? ThemeColors.white : ThemeColors.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}