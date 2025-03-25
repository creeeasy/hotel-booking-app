import 'package:flutter/material.dart';

class BoutiqueHotelTheme {
  // Primary Colors
  static const Color primary = Color(0xFF673AB7); // Deep Purple
  static const Color secondary = Color(0xFF9C27B0); // Vivid Magenta
  static const Color accent = Color(0xFFFF5722); // Tangerine
  static const Color background =
      Color.fromARGB(255, 255, 255, 255); // Pale Lilac
  static const Color textColor = Color(0xFF311B92); // Deep Indigo
  static const Color primaryBlue = Color(0xFF0D47A1);
  // Button Colors
  static const Color buttonPrimaryBg = primary;
  static const Color buttonPrimaryText = Colors.white;
  static const Color buttonSecondaryBg = secondary;
  static const Color buttonSecondaryText = Colors.white;
  static const Color buttonAccentBg = accent;
  static const Color buttonAccentText = Colors.white;
  static const Color buttonDisabledBg = Color(0xFFE0E0E0);
  static const Color buttonDisabledText = Color(0xFF9E9E9E);

  // Text Colors
  static const Color headlineText = textColor;
  static const Color bodyText = textColor;
  static Color mutedText = const Color(0x009c27b0).withOpacity(0.6);
  static const Color linkText = accent;

  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardBorder = Color(0xFFEDE7F6);
  static const Color cardTitleText = textColor;
  static const Color cardIconAccent = accent;

  // Input Field Colors
  static const Color inputFieldBackground = background;
  static const Color inputFieldBorder = primary;
  static const Color inputFieldPlaceholder = secondary;
  static const Color inputFieldText = textColor;

  // Tab Bar Colors
  static const Color activeTabBackground = primary;
  static const Color activeTabText = Colors.white;
  static const Color inactiveTabBackground = Color(0xFFEDE7F6);
  static const Color inactiveTabText = secondary;

  // Badge/Tag Colors
  static const Color successBadge = Color(0xFF4CAF50); // Green
  static const Color warningBadge = Color(0xFFFFC107); // Amber
  static const Color errorBadge = Color(0xFFF44336); // Red
  static const Color infoBadge = primary;

  // Modal Background
  static const Color modalOverlay = Color(0x66311B92); // 40% opacity overlay
}
