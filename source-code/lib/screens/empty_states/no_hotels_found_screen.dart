import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class NoHotelsFoundScreen extends StatelessWidget {
  const NoHotelsFoundScreen({super.key});

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
                        VisitorThemeColors
                            .livelyTurquoise, // Fresh & Cheerful Turquoise
                        VisitorThemeColors.radiantPink, // Vivid & Cheerful Pink
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons
                        .faceSmileBeam, // Happy smiling face for a cheerful touch
                    size: 82,
                    color: VisitorThemeColors.whiteColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No Results Found!",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: VisitorThemeColors.blackColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "We couldn't find any matches. Try adjusting your filters and searching again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: VisitorThemeColors.textGreyColor,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
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
