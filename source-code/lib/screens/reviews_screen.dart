// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:developer';

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/utils/rating_utils.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  Future<List<Review>> getHotelReviews(BuildContext context) async {
    final hotelId = ModalRoute.of(context)!.settings.arguments as String;
    return await Review.getAllHotelReviews(hotelId: hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Review>>(
        future: getHotelReviews(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicatorWidget(
                indicatorColor:
                    VisitorThemeColors.deepPurpleAccent.withOpacity(0.8),
                containerColor: VisitorThemeColors.whiteColor,
              ),
            );
          } else if (snapshot.hasError) {
            return ErrorWidgetWithRetry(
              errorMessage: 'Error: ${snapshot.error}',
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildNoReviewsUi();
          }

          final reviews = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: reviews.length + 2, // +2 for the header and count text
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeaderCard(reviews);
              if (index == 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DividerWidget(
                      verticalPadding: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        "${reviews.length} reviews",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    DividerWidget(
                      verticalPadding: 5,
                    ),
                  ],
                );
              }
              final review = reviews[index - 2];
              return _buildReviewCard(review);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoReviewsUi() {
    return Center(
      child: Text(
        "No reviews yet.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildHeaderCard(List<Review> reviews) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
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
                    colorFilter:
                        const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    getTotalReviewsRatings(reviews).toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.rotationY(math.pi), // Flipped right laurel
                    child: SvgPicture.asset(
                      "assets/icons/laurel.svg",
                      height: 40,
                      colorFilter:
                          const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Guest Favorite',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This home is a guest favorite based\non ratings, reviews, and reliability.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: VisitorThemeColors.textGreyColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          color: VisitorThemeColors.blackColor,
          icon: const Icon(
            Icons.chevron_left,
            size: 32,
            // Matching Visitor screen
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, String>?>(
            future: Visitor.fetchVisitorDetails(userId: review.visitorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final responseData = snapshot.data ?? {};
              final avatarUrl = responseData["avatarUrl"];
              final fullName =
                  "${responseData["firstName"] ?? ""} ${responseData["lastName"] ?? ""}"
                      .trim();

              return Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: avatarUrl?.isNotEmpty == true
                        ? NetworkImage(avatarUrl!)
                        : const AssetImage(
                                "assets/images/default-avatar-icon.jpg")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fullName.isNotEmpty ? fullName : "Anonymous",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat.yMMMMd().format(review.createdAt),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
                fontSize: 14,
                color: VisitorThemeColors.textGreyColor,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
