import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/screens/visitor/visitor_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ErrorWidgetWithRetry extends StatelessWidget {
  final String errorMessage;
  final String? title;
  final VoidCallback? onRetry;
  final bool showHomeButton;

  const ErrorWidgetWithRetry({
    Key? key,
    required this.errorMessage,
    this.title,
    this.onRetry,
    this.showHomeButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.warning_2,
                    size: 48,
                    color: ThemeColors.error,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  title ?? L10n.of(context).oopsSomethingWentWrong,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Error Message
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ThemeColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Retry Button
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Iconsax.refresh, size: 20),
                      label: Text(L10n.of(context).tryAgain),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: ThemeColors.white,
                        backgroundColor: ThemeColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // Home Button
                if (showHomeButton) ...[
                  if (onRetry != null) const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const VisitorHomeScreen(),
                        ),
                        (route) => false,
                      ),
                      icon: const Icon(Iconsax.home, size: 20),
                      label: Text(L10n.of(context).goToHome),
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
