import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/widgets/hotel/network_image_widget.dart';
import 'package:fatiel/widgets/image_error_widget.dart';
import 'package:flutter/material.dart';

class HotelImageWidget extends StatelessWidget {
  final List<String> images;

  const HotelImageWidget({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? ImageErrorWidget(title: L10n.of(context).noImageAvailable)
        : NetworkImageWithLoader(imageUrl: images.first);
  }
}
