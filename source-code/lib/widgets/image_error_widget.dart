import 'package:fatiel/l10n/l10n.dart';
import 'package:flutter/material.dart';

class ImageErrorWidget extends StatelessWidget {
  final String? title;
  const ImageErrorWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          const SizedBox(height: 8),
          Text(
            title ?? L10n.of(context).failedToLoadImage,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}