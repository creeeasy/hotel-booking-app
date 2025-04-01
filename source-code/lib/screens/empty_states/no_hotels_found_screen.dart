import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NoHotelsFoundScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NoHotelsFoundScreen({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
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
              gradient: LinearGradient(
                colors: [
                  ThemeColors.accentPurple,
                  ThemeColors.accentPink,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.accentPink.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Iconsax.search_normal_1,
              size: 48,
              color: ThemeColors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleText() {
    return Text(
      "No Hotels Found",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: ThemeColors.textPrimary,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescriptionText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        customMessage ??
            "We couldn't find any hotels matching your criteria. "
                "Try adjusting your search filters or exploring nearby locations.",
        style: TextStyle(
          fontSize: 16,
          color: ThemeColors.textSecondary,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
