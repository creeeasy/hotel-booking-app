import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
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
      backgroundColor: VisitorThemeColors.whiteColor,
      appBar: (appBarConfig != null && appBarConfig?['title'] != null)
          ? CustomBackAppBar(
              title: appBarConfig!['title'],
              titleColor: VisitorThemeColors.primaryColor,
              iconColor: VisitorThemeColors.primaryColor,
              onBack: () => Navigator.pop(context),
            )
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.boxOpen, // FontAwesome Icon
                color: VisitorThemeColors.greyColor.withOpacity(0.7),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                "No Data Found",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: VisitorThemeColors.blackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: VisitorThemeColors.textGreyColor.withOpacity(0.9),
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
