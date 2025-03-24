// import 'package:fatiel/models/review.dart';

// double getTotalRating(List<Map<String, double>> ratings) {
//   if (ratings.isEmpty) return 0.0;

//   double total = ratings.map((e) => e.values.first).reduce((a, b) => a + b);
//   return total.clamp(0.0, 5.0);
// }

// double getTotalReviewsRatings(List<Review> reviews) {
//   if (reviews.isEmpty) return 0.0;

//   double average =
//       reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;
//   return average.clamp(0.0, 5.0);
// }
