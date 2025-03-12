import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/screens/visitor/visitor_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ErrorWidgetWithRetry extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorWidgetWithRetry({
    Key? key,
    required this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(
                FontAwesomeIcons.triangleExclamation, // FontAwesome error icon
                color: VisitorThemeColors.cancelledTextColor,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                "Oops! Something went wrong.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: VisitorThemeColors.blackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: VisitorThemeColors.textGreyColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 18),
                  label: const Text(
                    "Retry",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: VisitorThemeColors.whiteColor,
                    backgroundColor: VisitorThemeColors.deepBlueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const VisitorHomeScreen(),
                    ),
                    (route) => false),
                icon: const FaIcon(
                  FontAwesomeIcons.house,
                  size: 20,
                  color: VisitorThemeColors.whiteColor, // Matches text color
                ),
                label: const Text(
                  "Go to Home Page",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VisitorThemeColors.whiteColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor:
                      VisitorThemeColors.deepBlueAccent, // Soft background
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
