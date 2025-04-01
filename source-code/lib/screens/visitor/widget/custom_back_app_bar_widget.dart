import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../constants/colors/theme_colors.dart';

class CustomBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;
  final IconData icon;
  final Widget? action;
  final double titleSize;
  final bool showDivider;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CustomBackAppBar(
      {Key? key,
      required this.title,
      this.backgroundColor = ThemeColors.background,
      this.iconColor = ThemeColors.primaryDark,
      this.titleColor = ThemeColors.primaryDark,
      this.icon = Iconsax.arrow_left_2,
      this.titleSize = 20,
      this.showDivider = true,
      this.onBack,
      this.action,
      this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: onBack != null
          ? IconButton(
              icon: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
              onPressed: onBack,
              splashRadius: 20,
            )
          : const SizedBox(width: 16),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Poppins",
          color: titleColor,
          fontSize: titleSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: actions ?? [],
      automaticallyImplyLeading: false,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: ThemeColors.border.withOpacity(0.2),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
