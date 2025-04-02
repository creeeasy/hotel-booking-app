import 'package:fatiel/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!L10n.supportedLocales.contains(locale)) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }

  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('languageCode');
      if (languageCode != null) {
        final locale = Locale(languageCode);
        if (L10n.supportedLocales.contains(locale)) {
          _locale = locale;
          notifyListeners();
        }
      }
    } catch (e) {
      _locale = const Locale('en');
      notifyListeners();
    }
  }
}