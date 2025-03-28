import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/screens/visitor/widget/positioned_favorite_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImages = widget.images.isNotEmpty;
    final bool multipleImages = hasImages && widget.images.length > 1;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 400, // Fixed height for the entire widget
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Image Content
          _buildPageView(hasImages),

          // Back Button
          if (widget.hotelId != null)
            Positioned(
              top: statusBarHeight + 16,
              left: 16,
              child: _buildBackButton(),
            ),

          // Favorite Button
          if (widget.hotelId != null)
            PositionedFavoriteButton(
              hotelId: widget.hotelId!,
              top: statusBarHeight + 16, // Pass position as parameters
              right: 16,
            ),

          // Image Indicator
          if (multipleImages)
            Positioned(
              bottom: 88, // Above thumbnails
              right: 16,
              child: _buildImageIndicator(),
            ),

          // Thumbnail List
          if (multipleImages)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ThumbnailList(
                images: widget.images,
                currentIndex: currentIndex,
                onThumbnailTap: _handleThumbnailTap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageView(bool hasImages) {
    return PageView.builder(
      controller: _pageController,
      itemCount: hasImages ? widget.images.length : 1,
      onPageChanged: (index) => setState(() => currentIndex = index),
      itemBuilder: (context, index) {
        return Hero(
          tag: hasImages
              ? 'image_${widget.hotelId}_${widget.images[index]}'
              : 'placeholder_${widget.hotelId}',
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: _buildImageContent(hasImages, index),
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Iconsax.arrow_left_2,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildImageContent(bool hasImages, int index) {
    if (!hasImages) return _buildNoImagePlaceholder();

    return Image.network(
      widget.images[index],
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: VisitorThemeColors.primaryColor,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildNoImagePlaceholder(),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      color: VisitorThemeColors.lightGrayColor.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gallery_slash,
              size: 48,
              color: VisitorThemeColors.textGreyColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              "No Images Available",
              style: TextStyle(
                fontSize: 16,
                color: VisitorThemeColors.textGreyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "${currentIndex + 1}/${widget.images.length}",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleThumbnailTap(int index) {
    if (currentIndex != index) {
      setState(() => currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
  final ValueChanged<int> onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < images.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => onThumbnailTap(index),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentIndex == index
                        ? VisitorThemeColors.primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: VisitorThemeColors.primaryColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: VisitorThemeColors.lightGrayColor,
                      child: const Center(
                        child: Icon(
                          Iconsax.gallery_slash,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
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
