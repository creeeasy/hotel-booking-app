import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NoHotelsFoundScreen extends StatelessWidget {
  const NoHotelsFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon container
              _buildAnimatedIcon(),
              const SizedBox(height: 32),
              // Title text
              _buildTitleText(),
              const SizedBox(height: 16),
              // Description text
              _buildDescriptionText(),
              const SizedBox(height: 32),
              // Optional action button
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  VisitorThemeColors.livelyTurquoise,
                  VisitorThemeColors.radiantPink,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: VisitorThemeColors.radiantPink.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Iconsax.search_normal_1, // Using Iconsax search icon
              size: 48,
              color: VisitorThemeColors.whiteColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleText() {
    return const Text(
      "No Hotels Found",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: VisitorThemeColors.blackColor,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescriptionText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        "We couldn't find any hotels matching your criteria. "
        "Try adjusting your search filters or exploring nearby locations.",
        style: TextStyle(
          fontSize: 16,
          color: VisitorThemeColors.textGreyColor,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Handle button press (e.g., navigate back or clear filters)
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: VisitorThemeColors.livelyTurquoise,
        foregroundColor: VisitorThemeColors.whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: VisitorThemeColors.livelyTurquoise.withOpacity(0.3),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.filter, size: 20),
          SizedBox(width: 8),
          Text(
            "Adjust Filters",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
