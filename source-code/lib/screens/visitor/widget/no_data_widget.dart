import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoDataWidget extends StatelessWidget {
  final String message;
  final Map<String, dynamic>? appBarConfig;

  const NoDataWidget({
    Key? key,
    this.message = "No data available at the moment.",
    this.appBarConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.white,
      appBar: (appBarConfig != null && appBarConfig?['title'] != null)
          ? CustomBackAppBar(
              title: appBarConfig!['title'],
              titleColor: ThemeColors.primary,
              iconColor: ThemeColors.primary,
              onBack: () => Navigator.pop(context),
            )
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(
                FontAwesomeIcons.boxOpen,
                color: ThemeColors.grey400,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                L10n.of(context).noDataFound,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
