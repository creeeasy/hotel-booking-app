import 'package:flutter/material.dart';

class ThemeColors {
  // Primary Palette
  static const Color primary = Color(0xFF6A1B9A);
  static const Color primaryDark = Color(0xFF4A148C);
  static const Color primaryLight = Color(0xFF9C27B0);
  static const Color primaryAccent = Color(0xFFAB47BC);

  // Secondary Palette
  static const Color secondary = Color(0xFF7B1FA2);
  static const Color secondaryDark = Color(0xFF5E35B1);
  static const Color secondaryLight = Color(0xFFBA68C8);

  // Accent Colors
  static const Color accentPink = Color(0xFFE91E63);
  static const Color accentPurple = Color(0xFF9575CD);
  static const Color accentDeep = Color(0xFF673AB7);

  // Background Colors
  static const Color background = Color(0xFFF3E5F5);
  static const Color surface = Color(0xFFEDE7F6);
  static const Color darkBackground = Color(0xFF311B92);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textAccent = Color(0xFF9C27B0);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF9C27B0);
  static const Color buttonSecondary = Color(0xFF7E57C2);
  static const Color buttonDisabled = Color(0xFFB39DDB);

  // Border Colors
  static const Color border = Color(0xFFD1C4E9);
  static const Color borderDark = Color(0xFF5E35B1);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Interactive Colors
  static const Color link = Color(0xFF7E57C2);
  static const Color hover = Color(0xFFD1C4E9);
  static const Color focus = Color(0xFFB39DDB);
  static const Color splash = Color(0xFFE1BEE7);

  // Special UI Elements
  static const Color star = Color(0xFF101010);
  static const Color heart = Color(0xFFE91E63);
  static const Color marker = Color(0xFF2196F3);
  static const Color active = Color(0xFF4CAF50);

  // Neutral Shades
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Transparent Variants
  static const Color primaryTransparent = Color(0x1A6A1B9A);
  static const Color accentTransparent = Color(0x1AE91E63);
  static const Color darkTransparent = Color(0x80311B92);

  // Gradient Combinations
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [secondaryLight, accentDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [accentPink, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Card Colors
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF4527A0);
  static const Color cardHighlight = Color(0xFFF3E5F5);

  // Shadow Colors
  static const Color shadow = Color(0x407B1FA2);
  static const Color shadowDark = Color(0x406A1B9A);
}
