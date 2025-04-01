import 'dart:math';

import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:fatiel/widgets/no_reviews_ui.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ReviewsSection extends StatefulWidget {
  final List<Review> reviews;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;

  const ReviewsSection({
    super.key,
    required this.reviews,
    this.itemsPerPage = 5,
    this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  late final PageController _pageController;
  late int currentPage;
  late int _selectedLimit;

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    _selectedLimit = widget.itemsPerPage;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = widget.reviews.isEmpty
        ? 1
        : ((widget.reviews.length - 1) ~/ _selectedLimit) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewsHeader(widget.reviews.length),
        const SizedBox(height: 10),
        _buildReviewsList(totalPages),
        _buildPageIndicator(totalPages),
      ],
    );
  }

  Widget _buildReviewsHeader(int totalReviews) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                color: ThemeColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ThemeColors.primary.withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  totalReviews.toString(),
                  style: const TextStyle(
                    color: ThemeColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildItemsPerPageDropdown(),
      ],
    );
  }

  Widget _buildItemsPerPageDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: ThemeColors.primary.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Material(
          color: Colors.transparent,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedLimit,
              dropdownColor: ThemeColors.background,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ThemeColors.primary,
                size: 20,
              ),
              iconSize: 24,
              elevation: 1,
              style: const TextStyle(
                color: ThemeColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              items: const [5, 10, 20].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        '$value per page',
                        style: const TextStyle(
                          color: ThemeColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newLimit) {
                if (newLimit != null) {
                  setState(() {
                    _selectedLimit = newLimit;
                    currentPage = 1;
                  });
                  widget.onItemsPerPageChanged?.call(newLimit);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(0);
                    }
                  });
                }
              },
              selectedItemBuilder: (BuildContext context) {
                return const [5, 10, 20].map((value) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Center(
                      child: Text(
                        '$value per page',
                        style: const TextStyle(
                          color: ThemeColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(int totalPages) {
    return Expanded(
      child: widget.reviews.isEmpty
          ? const NoReviewsUI()
          : PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() => currentPage = index + 1);
                widget.onPageChanged?.call(index + 1);
              },
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * _selectedLimit;
                final endIndex =
                    min(startIndex + _selectedLimit, widget.reviews.length);
                final pageReviews =
                    widget.reviews.sublist(startIndex, endIndex);

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: pageReviews.length,
                  itemBuilder: (context, index) {
                    final review = pageReviews[index];
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: VisitorService.fetchVisitorDetails(
                          userId: review.visitorId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicatorWidget(
                                  size: 20,
                                  strockWidth: 1.9,
                                ),
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const _ReviewErrorWidget();
                        }
                        final responseData = snapshot.data ?? {};
                        final avatarUrl = responseData["avatarURL"] as String?;
                        final firstName =
                            responseData["firstName"] as String? ?? "";
                        final lastName =
                            responseData["lastName"] as String? ?? "";
                        final fullName = "$firstName $lastName".trim();
                        return _ReviewCard(
                          review: review,
                          avatarUrl: avatarUrl,
                          fullName: fullName,
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildPageIndicator(int totalPages) {
    final validPageCount = totalPages.clamp(1, totalPages);
    return validPageCount > 1
        ? Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: validPageCount,
              effect: const WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: ThemeColors.primary,
                dotColor: ThemeColors.border,
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

class _ReviewErrorWidget extends StatelessWidget {
  const _ReviewErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Failed to load reviewer details',
          style: TextStyle(color: ThemeColors.error),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final String? avatarUrl;
  final String fullName;

  const _ReviewCard({
    required this.review,
    this.avatarUrl,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: ThemeColors.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRatingStars(),
                      const SizedBox(width: 8),
                      Text(
                        review.validatedRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: ThemeColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        review.formattedDate,
                        style: const TextStyle(
                          color: ThemeColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildComment(),
                  if (fullName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Reviewed by: ',
                            style: TextStyle(
                              color: ThemeColors.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(
                            text: fullName,
                            style: const TextStyle(
                              color: ThemeColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: ThemeColors.surface,
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: ThemeColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        review.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star,
          color: index < review.validatedRating.floor()
              ? ThemeColors.star
              : ThemeColors.border,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildComment() {
    return Text(
      review.comment.isNotEmpty ? review.comment : 'No comment provided',
      style: const TextStyle(
        color: ThemeColors.textPrimary,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }
}
