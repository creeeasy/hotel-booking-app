import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class NoFavoritesScreen extends StatelessWidget {
  const NoFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        VisitorThemeColors.softPinkAccent,
                        VisitorThemeColors.warningColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.heart,
                    size: 82,
                    color: VisitorThemeColors.whiteColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No Favorites Yet!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: VisitorThemeColors.blackColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Discover amazing stays and save them to your favorites.\nTap the heart icon to get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: VisitorThemeColors.textGreyColor,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 16),
                    backgroundColor: VisitorThemeColors.warningColor,
                    foregroundColor: VisitorThemeColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    shadowColor:
                        VisitorThemeColors.softPinkAccent.withOpacity(0.5),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.magnifyingGlassChart,
                      size: 20),
                  label: const Text(
                    "Find Favorites",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
