import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/screens/visitor/widget/positioned_favorite_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ImageGallery extends StatefulWidget {
  const ImageGallery({
    super.key,
    required this.images,
    this.hotelId,
    this.onBackPressed,
    this.containerAspectRatio = 16 / 9,
  });

  final List<String> images;
  final String? hotelId;
  final VoidCallback? onBackPressed;
  final double containerAspectRatio;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final Map<int, double?> _imageAspectRatios = {};
  final Map<int, bool> _imageErrorStates = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // Initialize aspect ratios as null (unknown)
    for (int i = 0; i < widget.images.length; i++) {
      _imageAspectRatios[i] = null;
      _imageErrorStates[i] = false;
    }
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

    return AspectRatio(
      aspectRatio: widget.containerAspectRatio,
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
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        return Hero(
          tag: hasImages
              ? 'image_${widget.hotelId}_${widget.images[index]}'
              : 'placeholder_${widget.hotelId}',
          child: Container(
            color: ThemeColors.grey100,
            child: _buildImageContent(hasImages, index),
          ),
        );
      },
    );
  }

  Widget _buildImageContent(bool hasImages, int index) {
    if (!hasImages) return _buildNoImagePlaceholder();
    if (_imageErrorStates[index] == true) return _buildNoImagePlaceholder();

    return InteractiveViewer(
      panEnabled: true,
      minScale: 1.0,
      maxScale: 3.0,
      child: _buildSmartImage(index),
    );
  }

  Widget _buildSmartImage(int index) {
    final imageAspectRatio = _imageAspectRatios[index];

    return Image.network(
      widget.images[index],
      fit: imageAspectRatio != null
          ? _getOptimalFit(imageAspectRatio)
          : BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null && !wasSynchronouslyLoaded) {
          return _buildLoadingIndicator();
        }
        return child;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _imageErrorStates[index] = true);
          }
        });
        return _buildNoImagePlaceholder();
      },
      cacheWidth: (MediaQuery.of(context).size.width * 2).toInt(),
      cacheHeight: (MediaQuery.of(context).size.height * 2).toInt(),
    );
  }

  BoxFit _getOptimalFit(double imageAspectRatio) {
    final containerAspectRatio = widget.containerAspectRatio;

    // If image is wider than container relative to their heights
    if (imageAspectRatio > containerAspectRatio) {
      return BoxFit.fitHeight; // Show full height, crop sides
    } else {
      return BoxFit.fitWidth; // Show full width, crop top/bottom
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: ThemeColors.primary,
      ),
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
        child: const Icon(
          Iconsax.arrow_left_2,
          color: ThemeColors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      color: ThemeColors.grey200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gallery_slash,
              size: 48,
              color: ThemeColors.grey400,
            ),
            SizedBox(height: 12),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index
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
                  color: _currentIndex == index
                      ? ThemeColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildThumbnailImage(index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnailImage(int index) {
    if (_imageErrorStates[index] == true) {
      return Container(
        color: ThemeColors.grey200,
        child: const Center(
          child: Icon(
            Iconsax.gallery_slash,
            color: ThemeColors.grey400,
            size: 24,
          ),
        ),
      );
    }

    return Image.network(
      widget.images[index],
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: ThemeColors.primary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _imageErrorStates[index] = true);
          }
        });
        return Container(
          color: ThemeColors.grey200,
          child: const Center(
            child: Icon(
              Iconsax.gallery_slash,
              color: ThemeColors.grey400,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  void _handleThumbnailTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
