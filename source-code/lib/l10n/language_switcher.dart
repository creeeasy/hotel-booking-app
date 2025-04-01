import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  Future<void> _saveLocale(Locale locale, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    if (context.mounted) {
      Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale =
        Provider.of<LocaleProvider>(context).locale ?? const Locale('en');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<Locale>(
      icon: Icon(
        Iconsax.global,
        size: 24,
        color: isDark ? ThemeColors.white : ThemeColors.primaryDark,
      ),
      tooltip: 'Change Language',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeColors.border.withOpacity(0.2)),
      ),
      elevation: 8,
      color: isDark ? ThemeColors.darkBackground : ThemeColors.background,
      onSelected: (Locale locale) => _saveLocale(locale, context),
      itemBuilder: (BuildContext context) {
        return L10n.supportedLocales.map((Locale locale) {
          final isSelected = locale.languageCode == currentLocale.languageCode;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    child: isSelected
                        ? const Icon(
                            Iconsax.tick_circle,
                            size: 20,
                            color: ThemeColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    L10n.getLanguageName(locale.languageCode),
                    style: TextStyle(
                      color: isSelected
                          ? ThemeColors.primary
                          : ThemeColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }
}
