double getTotalRating(List<Map<String, double>> ratings) {
  if (ratings.isEmpty) return 0;
  return ratings.map((e) => e.values.first).reduce((a, b) => a + b);
}
