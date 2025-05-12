import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/enum/review_update_type.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/rating.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/services/booking/booking_service.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';

class ReviewService {
  static Future<ReviewingResult> createReview({
    required String visitorId,
    required String hotelId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      final booking = await BookingService.getBookingById(
        bookingId,
      );

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

      await HotelService.updateHotelReview(
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
      Query reviewQuery = FirebaseFirestore.instance
          .collection("reviews")
          .where("hotelId", isEqualTo: hotelId);

      if (currentRatingStar != null) {
        reviewQuery = reviewQuery.where("rating", isEqualTo: currentRatingStar);
      }

      reviewQuery = sortByNewest
          ? reviewQuery.orderBy("createdAt", descending: true)
          : reviewQuery.orderBy("createdAt");

      if (limit != null) {
        reviewQuery = reviewQuery.limit(limit);
      }

      final results = await Future.wait([
        reviewQuery.get(),
        FirebaseFirestore.instance.collection("hotels").doc(hotelId).get(),
        FirebaseFirestore.instance
            .collection("reviews")
            .where("hotelId", isEqualTo: hotelId)
            .count()
            .get(),
      ]);

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
        "hasMore": limit != null ? reviews.length == limit : false,
      };
    } on FirebaseException catch (e) {
      log('FirebaseException: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      log('Error fetching hotel reviews: $e');
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
      log("Error checking if visitor has reviewed: $e");
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

      await HotelService.updateHotelReview(
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

      await HotelService.updateHotelReview(
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
      log('Error fetching available rooms: $e');
      return 0;
    }
  }

  static Future<int> fetchReviewStatisticsFuture({
    required String hotelId,
  }) async {
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
