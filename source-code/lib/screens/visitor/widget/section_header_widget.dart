import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SectionHeader extends StatelessWidget {
  final VoidCallback onSeeAllTap;
  final String title;

  const SectionHeader({
    super.key,
    required this.onSeeAllTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAllTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10n.of(context).seeAll,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: ThemeColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}