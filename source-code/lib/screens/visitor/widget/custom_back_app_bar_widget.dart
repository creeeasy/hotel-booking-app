import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class CustomBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;

  final VoidCallback? onBack;

  const CustomBackAppBar({
    Key? key,
    required this.title,
    this.backgroundColor = VisitorThemeColors.whiteColor,
    this.iconColor = VisitorThemeColors.blackColor,
    this.titleColor = VisitorThemeColors.blackColor,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.chevron_left, size: 32),
              color: iconColor,
              onPressed: onBack)
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Poppins",
          color: titleColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
