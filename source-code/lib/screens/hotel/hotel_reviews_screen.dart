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
import 'package:fatiel/l10n/l10n.dart';

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
    return Scaffold(
      appBar: CustomBackAppBar(
        title: L10n.of(context).guestReviews,
      ),
      backgroundColor: ThemeColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicatorWidget();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(L10n.of(context).errorLoadingReviews,
                  style: const TextStyle(color: ThemeColors.error)),
            );
          }

          final reviews = snapshot.data!["reviews"] as List<Review>;
          final ratings = (snapshot.data!["ratings"] as Rating);

          return Column(
            children: [
              // Top section with fixed height
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingSummary(ratings),
                        const SizedBox(height: 20),
                        _buildRatingFilters(),
                      ],
                    ),
                  ),
                ),
              ),
              // Reviews section that takes remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingFilters() {
    return SizedBox(
      height: 100, // Fixed height for the filter row
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 4),
            _buildRatingFilterItem(
              value: null,
              label: L10n.of(context).all,
              isSelected: selectedRating == null,
            ),
            ...ratingFilters.skip(1).map((rating) => _buildRatingFilterItem(
                  value: rating.value,
                  label: rating.isAll
                      ? L10n.of(context).all
                      : L10n.of(context).stars(rating.label),
                  isSelected: _ratingFilterNotifier.value == rating.value,
                )),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingFilterItem({
    required int? value,
    required String label,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() {
          selectedRating = value;
          currentPage = 1;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
          _ratingFilterNotifier.value = value;
        }),
        child: Container(
          width: 90,
          height: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColors.primary.withOpacity(0.15)
                : ThemeColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ThemeColors.primary
                  : ThemeColors.primary.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (value != null)
                const Icon(
                  Icons.star,
                  color: ThemeColors.primary,
                  size: 20,
                ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ThemeColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
          Flexible(
            child: Text(
              L10n.of(context).reviewsCount(totalRatings),
              style: const TextStyle(
                color: ThemeColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
