import 'dart:math';
import 'package:fatiel/constants/colors/hotel_theme_colors.dart';
import 'package:fatiel/constants/ratings.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/rating.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/hotel/widget/headline_text_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:fatiel/widgets/no_reviews_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HotelReviewsScreen extends StatefulWidget {
  const HotelReviewsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HotelReviewsScreenState();
}

class _HotelReviewsScreenState extends State<HotelReviewsScreen> {
  int? selectedRating;
  late String hotelId;
  int selectedLimit = 5;
  int currentPage = 1;

  final PageController _pageController = PageController();
  late Future<Map<String, dynamic>> _reviewsFuture;
  final ValueNotifier<int?> _ratingFilterNotifier = ValueNotifier<int?>(null);

  @override
  void initState() {
    hotelId = (context.read<AuthBloc>().state.currentUser as Hotel).id;
    _setupRatingListener();
    _reviewsFuture = Review.getAllHotelReviews(hotelId: hotelId);
    super.initState();
  }

  void _setupRatingListener() {
    _ratingFilterNotifier.addListener(_refreshReviews);
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsFuture = Review.getAllHotelReviews(
        hotelId: hotelId,
        currentRatingStar: _ratingFilterNotifier.value,
      );
      currentPage = 1;
      _pageController.jumpToPage(0);
    });
  }

  @override
  void dispose() {
    _ratingFilterNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoutiqueHotelTheme.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicatorWidget(
              indicatorColor: BoutiqueHotelTheme.primaryBlue,
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {}
          final reviews = snapshot.data!["reviews"] as List<Review>;
          final ratings = (snapshot.data!["ratings"] as Rating);
          final itemCount = reviews.length;
          final totalPages =
              itemCount == 0 ? 1 : ((itemCount - 1) ~/ selectedLimit) + 1;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeadlineText(text: 'Guest Reviews'),
                _buildRatingSummary(ratings),
                const SizedBox(height: 20),
                _buildRatingFilters(),
                const SizedBox(height: 20),
                _buildReviewsHeader(reviews.length),
                const SizedBox(height: 10),
                _buildReviewsList(reviews, totalPages),
                _buildPageIndicator(totalPages),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRatingFilterItem(
            value: null,
            label: 'All',
            isSelected: selectedRating == null,
          ),
          ...ratingFilters.skip(1).map((rating) => _buildRatingFilterItem(
                value: rating.value,
                label: rating.isAll ? "All" : "${rating.label} Stars",
                isSelected: selectedRating == rating.value,
              )),
        ],
      ),
    );
  }

  Widget _buildRatingFilterItem({
    required int? value,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() {
        selectedRating = value;
        currentPage = 1;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
        _ratingFilterNotifier.value = value;
      }),
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? BoutiqueHotelTheme.primaryBlue.withOpacity(0.15)
              : BoutiqueHotelTheme.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? BoutiqueHotelTheme.primaryBlue
                : BoutiqueHotelTheme.primaryBlue.withOpacity(0.2),
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (value != null)
              const Icon(
                Icons.star,
                color: BoutiqueHotelTheme.primaryBlue,
                size: 24,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BoutiqueHotelTheme.primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
                color: BoutiqueHotelTheme.headlineText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BoutiqueHotelTheme.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: BoutiqueHotelTheme.primaryBlue.withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              child: Center(
                // Ensure text inside is fully centered
                child: Text(
                  totalReviews.toString(),
                  style: const TextStyle(
                    color: BoutiqueHotelTheme.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: BoutiqueHotelTheme.primary.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Material(
              color: Colors.transparent,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedLimit,
                  dropdownColor: BoutiqueHotelTheme.background,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: BoutiqueHotelTheme.primary,
                    size: 20,
                  ),
                  iconSize: 24,
                  elevation: 1,
                  style: const TextStyle(
                    color: BoutiqueHotelTheme.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  items: const [5, 10, 20].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Center(
                        // Center text properly inside dropdown
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            '$value per page',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: BoutiqueHotelTheme.textColor,
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
                        selectedLimit = newLimit;
                        currentPage = 1;
                      });
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Center(
                          // Ensures selected text is centered
                          child: Text(
                            '$value per page',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: BoutiqueHotelTheme.textColor,
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
        ),
      ],
    );
  }

  Widget _buildReviewsList(List<Review> reviews, int totalPages) {
    return Expanded(
      child: reviews.isEmpty
          ? const NoReviewsUI()
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalPages,
                    onPageChanged: (index) =>
                        setState(() => currentPage = index + 1),
                    itemBuilder: (context, pageIndex) {
                      final startIndex = pageIndex * selectedLimit;
                      final endIndex =
                          min(startIndex + selectedLimit, reviews.length);
                      final pageReviews = reviews.sublist(startIndex, endIndex);
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: pageReviews.length,
                        itemBuilder: (context, index) {
                          final review = pageReviews[index];
                          return FutureBuilder<Map<String, dynamic>?>(
                            future: Visitor.fetchVisitorDetails(
                                userId: review.visitorId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicatorWidget(
                                        indicatorColor:
                                            BoutiqueHotelTheme.mutedText,
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
                              final avatarUrl =
                                  responseData["avatarURL"] as String?;
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
                ),
              ],
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
                activeDotColor: Colors.black87,
                dotColor: Colors.grey,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildRatingSummary(Rating review) {
    final averageScore = review.rating.toString();
    final totalRatings = review.totalRating.toString();
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Icon(
            Icons.star,
            color: Colors.black,
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            averageScore,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            '$totalRatings Reviews',
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
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
          color: Colors.black26,
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
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        review.formattedDate,
                        style: const TextStyle(
                          color: Colors.black54,
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
                              color: Colors.black54,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(
                            text: fullName,
                            style: const TextStyle(
                              color: Colors.black,
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
        backgroundColor: Colors.black12,
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.black87,
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
              ? Colors.black87
              : Colors.grey.shade400,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildComment() {
    return Text(
      review.comment.isNotEmpty ? review.comment : 'No comment provided',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        height: 1.4,
      ),
    );
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
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
