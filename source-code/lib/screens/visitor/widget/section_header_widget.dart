import 'package:fatiel/constants/colors/ThemeColorss.dart';
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.primary,
                ),
              ),
              SizedBox(width: 4),
              Icon(
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
