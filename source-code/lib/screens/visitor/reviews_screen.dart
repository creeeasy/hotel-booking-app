import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/ratings.dart';
import 'package:fatiel/models/rating.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/services/review/review_service.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:fatiel/widgets/reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int selectedLimit = 5;
  int currentPage = 1;
  int? selectedRating;
  late Future<Map<String, dynamic>> _reviewsFuture;
  final PageController _pageController = PageController();
  final ValueNotifier<int?> _ratingFilterNotifier = ValueNotifier<int?>(null);
  final String hotelId = "dHNQ0AKCIrWeqpKR81Q0fbfORZM2";

  @override
  void initState() {
    super.initState();
    _setupRatingListener();
    _loadReviews();
  }

  void _setupRatingListener() {
    _ratingFilterNotifier.addListener(_refreshReviews);
  }

  Future<void> _loadReviews() async {
    _reviewsFuture = ReviewService.getAllHotelReviews(
      hotelId: hotelId,
      currentRatingStar: _ratingFilterNotifier.value,
    );
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _loadReviews();
      currentPage = 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: CustomBackAppBar(
          title: "Guest Reviews",
          onBack: () => Navigator.of(context).pop(),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicatorWidget(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading reviews: ${snapshot.error}',
                    style: const TextStyle(color: ThemeColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No reviews data available',
                  style: TextStyle(color: ThemeColors.textSecondary),
                ),
              );
            }

            final reviews = snapshot.data!["reviews"] as List<Review>;
            final ratings = snapshot.data!["ratings"] as Rating;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRatingHeader(ratings),
                        const DividerWidget(),
                        _buildRatingFilters(),
                        const DividerWidget(),
                      ],
                    ),
                  ),
                ),
                // Convert ReviewsSection to be sliver-compatible
                _buildSliverReviewsSection(reviews),
              ],
            );
          },
        ),
      ),
    );
  }

  // New method to make ReviewsSection work with slivers
  Widget _buildSliverReviewsSection(List<Review> reviews) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height * 0.7, // Adjust height as needed
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ReviewsSection(
            reviews: reviews,
            itemsPerPage: selectedLimit,
            onPageChanged: (page) {
              setState(() => currentPage = page);
            },
            onItemsPerPageChanged: (limit) {
              setState(() => selectedLimit = limit);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRatingHeader(Rating rating) {
    final averageScore = rating.rating.toStringAsFixed(1);
    final totalRatings = rating.totalRating.toString();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildLaurelIcon(),
              const SizedBox(width: 10),
              Text(
                averageScore,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              _buildLaurelIcon(flipped: true),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Guest Favorite',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: ThemeColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Based on $totalRatings reviews',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: ThemeColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaurelIcon({bool flipped = false}) {
    return flipped
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: SvgPicture.asset(
              "assets/icons/laurel.svg",
              height: 40,
              colorFilter:
                  const ColorFilter.mode(ThemeColors.primary, BlendMode.srcIn),
            ),
          )
        : SvgPicture.asset(
            "assets/icons/laurel.svg",
            height: 40,
            colorFilter:
                const ColorFilter.mode(ThemeColors.primary, BlendMode.srcIn),
          );
  }

  Widget _buildRatingFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 16),
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
          const SizedBox(width: 16),
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
              ? ThemeColors.primary.withOpacity(0.15)
              : ThemeColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ThemeColors.primary
                : ThemeColors.primary.withOpacity(0.2),
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (value != null)
              const Icon(
                Icons.star,
                color: ThemeColors.primary,
                size: 24,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
