import 'package:fatiel/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NoReviewsUI extends StatelessWidget {
  const NoReviewsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: Icon(
                Iconsax.message_question,
                size: 48,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              L10n.of(context).noReviewsYet,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
