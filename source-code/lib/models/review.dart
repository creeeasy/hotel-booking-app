import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Review {
  final String id;
  final String visitorId;
  final String hotelId;
  final String bookingId;
  final double rating;
  final String comment;
  final DateTime createdAt;

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
