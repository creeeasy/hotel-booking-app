import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/models/rating.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:fatiel/widgets/no_reviews_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:iconsax/iconsax.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  Future<Map<String, dynamic>> getHotelReviews(BuildContext context) async {
    const hotelId = "dHNQ0AKCIrWeqpKR81Q0fbfORZM2";
    return await Review.getAllHotelReviews(hotelId: hotelId);
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
          future: getHotelReviews(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicatorWidget(),
              );
            } else if (snapshot.hasError) {
              return ErrorWidgetWithRetry(
                errorMessage: 'Error: ${snapshot.error}',
                onRetry: () => setState(() {}),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const NoReviewsUI();
            }

            final reviews = snapshot.data!["reviews"] as List<Review>;
            final rating = (snapshot.data!["ratings"] as Rating);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildRatingHeader(rating),
                  const DividerWidget(verticalPadding: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReviewsCount(reviews.length),
                        const DividerWidget(verticalPadding: 16),
                        ...reviews
                            .map((review) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ReviewCard(review: review),
                                ))
                            .toList(),
                      ],
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

  Widget _buildRatingHeader(Rating rating) {
    final averageScore = rating.rating.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SvgPicture.asset(
                "assets/icons/laurel.svg",
                height: 40,
                colorFilter: const ColorFilter.mode(
                    ThemeColors.primary, BlendMode.srcIn),
              ),
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
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: SvgPicture.asset(
                  "assets/icons/laurel.svg",
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                      ThemeColors.primary, BlendMode.srcIn),
                ),
              ),
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
          const Text(
            'This home is a guest favorite based on ratings, reviews, and reliability.',
            textAlign: TextAlign.center,
            style: TextStyle(
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

  Widget _buildReviewsCount(int count) {
    return Row(
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            color: ThemeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ThemeColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: ThemeColors.primary.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: ThemeColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>(
      future: Visitor.fetchVisitorDetails(userId: review.visitorId),
      builder: (context, snapshot) {
        final responseData = snapshot.data ?? {};
        final avatarUrl = responseData["avatarURL"];
        final fullName =
            "${responseData["firstName"] ?? ""} ${responseData["lastName"] ?? ""}"
                .trim();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: ThemeColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          color: ThemeColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: ThemeColors.grey200,
                      backgroundImage: avatarUrl?.isNotEmpty == true
                          ? NetworkImage(avatarUrl!)
                          : const AssetImage(
                                  "assets/images/default-avatar-icon.jpg")
                              as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isNotEmpty ? fullName : "Anonymous",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMMd().format(review.createdAt),
                            style: const TextStyle(
                              color: ThemeColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Iconsax.star1,
                          color: index < review.validatedRating.floor()
                              ? ThemeColors.star
                              : ThemeColors.grey300,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ThemeColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
