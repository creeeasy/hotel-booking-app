import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/screens/visitor/widget/positioned_favorite_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DetailsImageWithHero extends StatefulWidget {
  const DetailsImageWithHero({
    super.key,
    required this.images,
    required this.hotelId,
    this.onBackPressed,
  });

  final List<String> images;
  final String? hotelId;
  final VoidCallback? onBackPressed;

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
      height: 360,
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
              top: statusBarHeight + 16,
              right: 16,
            ),

          // Image Indicator
          if (multipleImages)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: _buildDotsIndicator(),
            ),

          // Thumbnail List
          if (multipleImages)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildThumbnailList(),
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              color: ThemeColors.grey100,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: _buildImageContent(hasImages, index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: widget.onBackPressed ?? () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ThemeColors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Iconsax.arrow_left_2,
          color: ThemeColors.white,
          size: 22,
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
            color: ThemeColors.primary,
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
      color: ThemeColors.grey200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gallery_slash,
              size: 48,
              color: ThemeColors.grey400,
            ),
            const SizedBox(height: 12),
            Text(
              "No Images Available",
              style: TextStyle(
                fontSize: 16,
                color: ThemeColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.images.length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index
                ? ThemeColors.white
                : ThemeColors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildThumbnailList() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ThemeColors.black.withOpacity(0.7),
            ThemeColors.black.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _handleThumbnailTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentIndex == index
                      ? ThemeColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThemeColors.primary,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: ThemeColors.grey200,
                    child: Center(
                      child: Icon(
                        Iconsax.gallery_slash,
                        color: ThemeColors.grey400,
                        size: 24,
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
