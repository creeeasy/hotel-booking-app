import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/enum/review_update_type.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';

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

  static Future<List<Review>> getAllHotelReviews(
      {required String hotelId}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("reviews")
          .where("hotelId", isEqualTo: hotelId)
          .orderBy("createdAt", descending: true) // Sorting by createdAt
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }

  static Future<bool> hasVisitorReviewed(
      {required String visitorId, required String bookingId}) async {
    final query = await FirebaseFirestore.instance
        .collection('reviews')
        .where('visitorId', isEqualTo: visitorId)
        .where('bookingId', isEqualTo: bookingId)
        .get();
    return query.docs.isNotEmpty;
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
