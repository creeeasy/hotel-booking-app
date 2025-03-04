import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/screens/visitor/widget/positioned_favorite_button_widget.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';

class DetailsImageWithHero extends StatefulWidget {
  const DetailsImageWithHero({
    super.key,
    required this.images,
    required this.hotelId,
  });

  final List<String> images;
  final String? hotelId;

  @override
  State<DetailsImageWithHero> createState() => _DetailsImageWithHeroState();
}

class _DetailsImageWithHeroState extends State<DetailsImageWithHero> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.images.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          height: hasImages ? 400 : 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: hasImages ? widget.images.length : 1,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Hero(
                  tag:
                      hasImages ? widget.images[index] : UniqueKey().toString(),
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.grey.shade100,
                        child: hasImages
                            ? Image.network(
                                widget.images[index],
                                fit: BoxFit
                                    .contain, // Ensures full width or height without cropping/stretching
                                width: double
                                    .infinity, // Allows the width to expand while maintaining aspect ratio
                                height: double
                                    .infinity, // Allows height to expand while maintaining aspect ratio
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 48,
                                ),
                              )
                            : _buildNoImagePlaceholder(),
                      ),
                      if (widget.hotelId != null)
                        PositionedFavoriteButton(hotelId: widget.hotelId!),
                      if (widget.hotelId != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                      if (hasImages)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: _buildImageIndicator(index),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        if (hasImages)
          ThumbnailList(
            images: widget.images,
            currentIndex: currentIndex,
            onThumbnailTap: (index) {
              if (currentIndex != index) {
                setState(() {
                  currentIndex = index;
                });
                _pageController.jumpToPage(index);
              }
            },
          ),
      ],
    );
  }

  /// Placeholder when there are no images
  Widget _buildNoImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 60,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 12),
          Text(
            "No Images Available",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Image indicator (index / total count)
  Widget _buildImageIndicator(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "${index + 1} / ${widget.images.length}",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ThumbnailList extends StatelessWidget {
  const ThumbnailList({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onThumbnailTap,
  });

  final List<String> images;
  final int currentIndex;
  final Function(int) onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onThumbnailTap(index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentIndex == index
                      ? VisitorThemeColors.deepPurpleAccent
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    images[index],
                    fit: BoxFit
                        .contain, // Ensures the image is fully visible without distortion
                    width: double
                        .infinity, // Allows width to expand, but fit keeps proportions
                    height: double
                        .infinity, // Allows height to expand, but fit keeps proportions
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicatorWidget(
                          containerColor: VisitorThemeColors.whiteColor,
                          indicatorColor: VisitorThemeColors.secondaryColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child:
                          const Icon(Icons.error, color: Colors.red, size: 32),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
