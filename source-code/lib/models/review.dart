import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/enum/review_update_type.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/rating.dart';
import 'package:intl/intl.dart';

class Review {
  final String id;
  final String visitorId;
  final String hotelId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String bookingId;

  Review({
    required this.id,
    required this.visitorId,
    required this.hotelId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
  String get initials => comment.isNotEmpty
      ? comment
          .trim()
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0] : '')
          .take(2)
          .join()
          .toUpperCase()
      : '?';

  String get formattedDate => DateFormat('MMM d, yyyy').format(createdAt);

  double get validatedRating => rating.clamp(0.0, 5.0);
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Review(
      id: doc.id,
      visitorId: data['visitorId'] as String? ?? '',
      hotelId: data['hotelId'] as String? ?? '',
      bookingId: data['bookingId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitorId': visitorId,
      'hotelId': hotelId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Future<ReviewingResult> createReview({
    required String visitorId,
    required String hotelId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      final booking = await Booking.getBookingById(bookingId);

      if (booking.status != BookingStatus.completed) {
        return const ReviewingFailure(
            "You can only review a completed booking.");
      }
      if (booking.visitorId != visitorId) {
        return const ReviewingFailure("You can only review your own bookings.");
      }

      final reviewRef =
          await FirebaseFirestore.instance.collection("reviews").add({
        'visitorId': visitorId,
        'hotelId': hotelId,
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
        'createdAt': Timestamp.now(),
      });

      await Hotel.updateHotelReview(
          hotelId: hotelId, action: ReviewUpdateType.add, rating: rating);
      final review = Review(
        id: reviewRef.id,
        visitorId: visitorId,
        hotelId: hotelId,
        bookingId: bookingId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      return ReviewingSuccess(review);
    } catch (e) {
      return const ReviewingFailure(
          "An unexpected error occurred while submitting your review. Please try again.");
    }
  }

  static Future<Map<String, dynamic>> getAllHotelReviews({
    int? limit,
    int? currentRatingStar,
    required String hotelId,
    bool sortByNewest = true,
  }) async {
    try {
      // Initialize base query for fetching reviews
      Query reviewQuery = FirebaseFirestore.instance
          .collection("reviews")
          .where("hotelId", isEqualTo: hotelId);

      // Apply rating filter if a specific rating is provided
      if (currentRatingStar != null) {
        reviewQuery = reviewQuery.where("rating", isEqualTo: currentRatingStar);
      }

      // Apply sorting order based on the flag
      reviewQuery = sortByNewest
          ? reviewQuery.orderBy("createdAt", descending: true)
          : reviewQuery.orderBy("createdAt");

      // Apply pagination limit if provided
      if (limit != null) {
        reviewQuery = reviewQuery.limit(limit);
      }

      // Execute multiple queries in parallel
      final results = await Future.wait([
        reviewQuery.get(), // Fetch reviews
        FirebaseFirestore.instance
            .collection("hotels")
            .doc(hotelId)
            .get(), // Fetch hotel details
        FirebaseFirestore.instance
            .collection("reviews")
            .where("hotelId", isEqualTo: hotelId)
            .count()
            .get(), // Get total reviews count
      ]);

      // Extract the results
      final reviewsSnapshot = results[0] as QuerySnapshot;
      final hotelSnapshot = results[1] as DocumentSnapshot;
      final totalReviewsCount = (results[2] as AggregateQuerySnapshot).count;

      final reviews =
          reviewsSnapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
      final hotel = Hotel.fromFirestore(hotelSnapshot);

      return {
        "reviews": reviews,
        "ratings": hotel.ratings,
        "hotel": hotel,
        "totalReviews": totalReviewsCount,
        "hasMore": limit != null
            ? reviews.length == limit
            : false, // Updated logic for 'hasMore'
      };
    } on FirebaseException catch (e) {
      log(e.message.toString());
      print(e);
      // log("FirebaseException: ${e.message}"); // Print Firebase-specific error
      throw Exception(e.message);
    } catch (e) {
      print(e);
      log(e.toString());
      // log("Error fetching hotel reviews: $e"); // Print general error
      rethrow;
    }
  }

  static Future<Review?> hasVisitorReviewed({
    required String visitorId,
    required String bookingId,
  }) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('reviews')
          .where('visitorId', isEqualTo: visitorId)
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (query.docs.isNotEmpty) {
        return Review.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print("Error checking if visitor has reviewed: $e");
      return null;
    }
  }

  static Future<ReviewingResult> updateReview({
    required String reviewId,
    required String visitorId,
    required double newRating,
    required String newComment,
  }) async {
    try {
      final reviewDoc = await FirebaseFirestore.instance
          .collection("reviews")
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) {
        return const ReviewingFailure("Review not found.");
      }

      final review = Review.fromFirestore(reviewDoc);
      if (review.visitorId != visitorId) {
        return const ReviewingFailure("You can only edit your own review.");
      }

      await FirebaseFirestore.instance
          .collection("reviews")
          .doc(reviewId)
          .update({
        'rating': newRating,
        'comment': newComment,
      });

      await Hotel.updateHotelReview(
        hotelId: review.hotelId,
        action: ReviewUpdateType.update,
        rating: newRating,
        oldRating: review.rating,
      );
      return ReviewingSuccess(
        Review(
          id: reviewId,
          visitorId: review.visitorId,
          hotelId: review.hotelId,
          bookingId: review.bookingId,
          rating: newRating,
          comment: newComment,
          createdAt: review.createdAt,
        ),
      );
    } catch (e) {
      return const ReviewingFailure(
          "An error occurred while updating your review.");
    }
  }

  static Future<ReviewingResult> deleteReview({
    required String reviewId,
    required String visitorId,
  }) async {
    try {
      final reviewDoc = await FirebaseFirestore.instance
          .collection("reviews")
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) {
        return const ReviewingFailure("Review not found.");
      }

      final review = Review.fromFirestore(reviewDoc);
      if (review.visitorId != visitorId) {
        return const ReviewingFailure("You can only delete your own review.");
      }

      await FirebaseFirestore.instance
          .collection("reviews")
          .doc(reviewId)
          .delete();

      // Update the hotel review statistics
      await Hotel.updateHotelReview(
        hotelId: review.hotelId,
        action: ReviewUpdateType.delete,
        rating: review.rating,
      );

      return ReviewingSuccess(review);
    } catch (e) {
      return const ReviewingFailure(
          "An error occurred while deleting your review.");
    }
  }

  static Future<int> fetchAvailableRoomsCountFuture({
    required String hotelId,
  }) async {
    try {
      final hotelFuture =
          FirebaseFirestore.instance.collection('hotels').doc(hotelId).get();

      final now = DateTime.now();
      final bookingsFuture = FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .where('checkInDate', isLessThanOrEqualTo: now)
          .get();

      final results = await Future.wait([hotelFuture, bookingsFuture]);
      final hotelDoc = results[0] as DocumentSnapshot;
      final activeBookingsQuery = results[1] as QuerySnapshot;

      final totalRooms =
          (hotelDoc.data() as Map<String, dynamic>?)?['totalRooms'] as int? ??
              0;

      int activeBookings = 0;
      for (final doc in activeBookingsQuery.docs) {
        final checkOutDate = (doc['checkOutDate'] as Timestamp).toDate();
        if (checkOutDate.isAfter(now)) {
          activeBookings++;
        }
      }

      return totalRooms - activeBookings > 0 ? totalRooms - activeBookings : 0;
    } catch (e) {
      log('Error fetching available rooms: $e',
          stackTrace: StackTrace.current,
          name: 'fetchAvailableRoomsCountFuture');
      return 0;
    }
  }

  static Future<int> fetchReviewStatisticsFuture(
      {required String hotelId}) async {
    try {
      final hotelDoc = await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotelId)
          .get();

      final ratingsMap = hotelDoc.data()?['ratings'] as Map<String, dynamic>?;
      final ratings = ratingsMap != null
          ? Rating(
              rating: (ratingsMap['rating'] as num).toDouble(),
              totalRating: ratingsMap['totalRating'] as int,
            )
          : null;
      return ratings?.totalRating ?? 0;
    } catch (e) {
      log('Error fetching review statistics: $e');
      return 0;
    }
  }
}

sealed class ReviewingResult {
  const ReviewingResult();
}

class ReviewingSuccess extends ReviewingResult {
  final Review review;
  const ReviewingSuccess(this.review);
}

class ReviewingFailure extends ReviewingResult {
  final String message;
  const ReviewingFailure(this.message);
}
