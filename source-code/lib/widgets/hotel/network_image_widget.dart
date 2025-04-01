import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/widgets/image_error_widget.dart';
import 'package:flutter/material.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double aspectRatio;
  final double height;
  final double width;

  const NetworkImageWithLoader({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.aspectRatio = 16 / 9,
    this.height = 40,
    this.width = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const ImageErrorWidget();
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return AspectRatio(
            aspectRatio: aspectRatio,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height,
                    width: width,
                    child: CircularProgressIndicator(
                      color: ThemeColors.primary,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading image...',
                    style: TextStyle(color: ThemeColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return const ImageErrorWidget();
      },
    );
  }
}
