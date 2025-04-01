import 'package:flutter/material.dart';
import 'package:fatiel/l10n/app_localizations.dart';

class L10n {
  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
  ];

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return '';
    }
  }
}
