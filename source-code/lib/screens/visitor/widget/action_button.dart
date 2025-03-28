// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/visitor/widget/cancel_button_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingNotifier extends ValueNotifier<bool> {
  BookingNotifier() : super(false);

  void refresh() {
    value = !value;
  }
}

final bookingNotifier = BookingNotifier();

class ActionButton extends StatefulWidget {
  final BookingStatus bookingStatus;
  final String bookingId;
  final String visitorId;
  final String hotelId;
  final VoidCallback? cancelBookingAction;
  const ActionButton(
      {super.key,
      required this.bookingStatus,
      required this.bookingId,
      required this.visitorId,
      required this.hotelId,
      this.cancelBookingAction});

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  late BookingStatus bookingStatus;
  late String bookingId;
  late String visitorId;
  late String hotelId;
  late VoidCallback? cancelBookingAction;

  @override
  void initState() {
    bookingStatus = widget.bookingStatus;
    bookingId = widget.bookingId;
    hotelId = widget.hotelId;
    visitorId = widget.visitorId;
    cancelBookingAction = widget.cancelBookingAction;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (bookingStatus == BookingStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: VisitorThemeColors.vibrantRed.withOpacity(0.16),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          "This hotel booking has been cancelled",
          style: TextStyle(
            fontFamily: "Poppins",
            color: VisitorThemeColors.vibrantRed,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (bookingStatus == BookingStatus.completed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: VisitorThemeColors.secondaryColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              "Booking Completed",
              style: TextStyle(
                fontFamily: "Poppins",
                color: VisitorThemeColors.secondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12), // Added spacing
          ValueListenableBuilder<bool>(
              valueListenable: bookingNotifier,
              builder: (context, _, ___) {
                return FutureBuilder<Review?>(
                  future: Review.hasVisitorReviewed(
                    bookingId: bookingId,
                    visitorId: visitorId,
                  ),
                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicatorWidget(
                        indicatorColor: VisitorThemeColors.secondaryColor,
                      );
                    }

                    bool hasReviewed =
                        reviewSnapshot.hasData && reviewSnapshot.data != null;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => _showReviewDialog(
                            context,
                            visitorId,
                            bookingId,
                            hotelId,
                            existingReview: reviewSnapshot.data,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: hasReviewed
                                  ? VisitorThemeColors.joyfulPurple
                                      .withOpacity(0.16)
                                  : VisitorThemeColors.radiantPink
                                      .withOpacity(0.16),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hasReviewed
                                  ? Icons.mode_edit_outline
                                  : Icons.reviews,
                              color: hasReviewed
                                  ? VisitorThemeColors.joyfulPurple
                                  : VisitorThemeColors.radiantPink,
                              size: 20,
                            ),
                          ),
                        ),
                        if (hasReviewed) SizedBox(width: 8),
                        if (hasReviewed)
                          GestureDetector(
                            onTap: () async {
                              final shouldDelete =
                                  await showGenericDialog<bool>(
                                context: context,
                                title: "Delete Review",
                                content:
                                    "Are you sure you want to delete this review? This action cannot be undone.",
                                optionBuilder: () => {
                                  "Cancel": false,
                                  "Delete": true,
                                },
                              );

                              if (shouldDelete == true) {
                                await Review.deleteReview(
                                  visitorId: visitorId,
                                  reviewId: reviewSnapshot.data!.id,
                                );
                                setState(() {});
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: VisitorThemeColors.vibrantRed
                                    .withOpacity(0.16),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: VisitorThemeColors.vibrantRed,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              }),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CancelButton(
          bookingId: bookingId,
          onCancelBooking: cancelBookingAction!,
        ),
        _viewBookingButton(context),
      ],
    );
  }

  Future<bool> showCancelBookingDialog(BuildContext context) async {
    return await showGenericDialog<bool>(
      context: context,
      title: 'Cancel Booking',
      content: 'Are you sure you want to cancel this booking?',
      optionBuilder: () => {'No': false, 'Yes, Cancel': true},
    ).then((value) => value ?? false);
  }

  Widget _viewBookingButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, bookingDetailsViewRoute,
          arguments: bookingId),
      style: TextButton.styleFrom(
        backgroundColor: VisitorThemeColors.deepBlueAccent,
        foregroundColor: VisitorThemeColors.whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "View Booking",
        style: TextStyle(
            fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showReviewDialog(
    BuildContext context,
    String visitorId,
    String bookingId,
    String hotelId, {
    Review? existingReview,
  }) {
    final TextEditingController commentController = TextEditingController(
      text: existingReview?.comment ?? "",
    );
    double rating = existingReview?.rating ?? 3.0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: VisitorThemeColors.lightGrayColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                existingReview == null ? "Write a Review" : "Edit Your Review",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VisitorThemeColors.primaryColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rating Dropdown
                  DropdownButtonFormField<double>(
                    value: rating,
                    decoration: InputDecoration(
                      labelText: "Rating",
                      labelStyle: TextStyle(
                        color: VisitorThemeColors.textGreyColor,
                        fontFamily: "Poppins",
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: VisitorThemeColors.greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: VisitorThemeColors.deepBlueAccent),
                      ),
                    ),
                    items: [1, 2, 3, 4, 5].map((e) {
                      return DropdownMenuItem(
                        value: e.toDouble(),
                        child: Text(
                          "Rating: $e",
                          style:
                              TextStyle(color: VisitorThemeColors.blackColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          rating = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Comment Input Field
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Write your comment...",
                      hintStyle:
                          TextStyle(color: VisitorThemeColors.textGreyColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: VisitorThemeColors.greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: VisitorThemeColors.deepBlueAccent),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: VisitorThemeColors.greyColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontFamily: "Poppins"),
                  ),
                ),

                // Submit Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final visitorId = (state.currentUser as Visitor).id;
                    return ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (commentController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        "Please write a comment before submitting."),
                                    backgroundColor:
                                        VisitorThemeColors.warningColor,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isSubmitting = true;
                              });

                              dynamic result;
                              if (existingReview == null) {
                                // Create a new review
                                result = await Review.createReview(
                                  visitorId: visitorId,
                                  hotelId: hotelId,
                                  bookingId: bookingId,
                                  rating: rating,
                                  comment: commentController.text.trim(),
                                );
                              } else {
                                // Update existing review
                                result = await Review.updateReview(
                                  visitorId: visitorId,
                                  reviewId: existingReview.id,
                                  newRating: rating,
                                  newComment: commentController.text.trim(),
                                );
                              }
                              Navigator.pop(
                                  context); // Close dialog after submission
                              if (result is ReviewingSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      existingReview == null
                                          ? "Review submitted successfully!"
                                          : "Review updated successfully!",
                                    ),
                                    backgroundColor:
                                        VisitorThemeColors.successColor,
                                  ),
                                );
                              } else if (result is ReviewingFailure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Failed to submit review: ${result.message}"),
                                    backgroundColor:
                                        VisitorThemeColors.vibrantRed,
                                  ),
                                );
                              }

                              setState(() {
                                isSubmitting = false;
                              });
                              bookingNotifier.refresh();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VisitorThemeColors.primaryColor,
                        foregroundColor: VisitorThemeColors.whiteColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              existingReview == null ? "Submit" : "Update",
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
