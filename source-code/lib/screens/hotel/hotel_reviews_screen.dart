import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/ratings.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/rating.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/review/review_service.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:fatiel/widgets/reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    _reviewsFuture = ReviewService.getAllHotelReviews(hotelId: hotelId);
    super.initState();
  }

  void _setupRatingListener() {
    _ratingFilterNotifier.addListener(_refreshReviews);
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsFuture = ReviewService.getAllHotelReviews(
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
    return SafeArea(
      child: Scaffold(
        appBar: const CustomBackAppBar(
          title: 'Guest Reviews',
        ),
        backgroundColor: ThemeColors.background,
        body: FutureBuilder<Map<String, dynamic>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicatorWidget();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: ThemeColors.error)),
              );
            }

            final reviews = snapshot.data!["reviews"] as List<Review>;
            final ratings = (snapshot.data!["ratings"] as Rating);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingSummary(ratings),
                  const SizedBox(height: 20),
                  _buildRatingFilters(),
                  const SizedBox(height: 20),
                  Expanded(
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
                ],
              ),
            );
          },
        ),
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
            color: ThemeColors.star,
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            averageScore,
            style: const TextStyle(
              color: ThemeColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            '$totalRatings Reviews',
            style: const TextStyle(
              color: ThemeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
