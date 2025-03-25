// 1. Define a proper model class instead of using Map
import 'package:get/get.dart';

class RatingFilter {
  final String label;
  final int? value;

  const RatingFilter({
    required this.label,
    this.value,
  });

  bool get isAll => value == null;
}

const List<RatingFilter> ratingFilters = [
  RatingFilter(label: 'All', value: null),
  RatingFilter(label: '5', value: 5),
  RatingFilter(label: '4', value: 4),
  RatingFilter(label: '3', value: 3),
  RatingFilter(label: '2', value: 2),
  RatingFilter(label: '1', value: 1),
];

extension RatingFilterUtils on List<RatingFilter> {
  RatingFilter? findByValue(int? value) {
    return firstWhereOrNull((filter) => filter.value == value);
  }

  RatingFilter get defaultFilter => firstWhere((filter) => filter.isAll);
}
