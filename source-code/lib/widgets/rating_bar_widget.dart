import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingBarWidget extends StatelessWidget {
  const RatingBarWidget({
    Key? key,
    this.rating,
    this.activeColor,
    this.inActiveColor,
    this.size,
  }) : super(key: key);

  final double? rating;
  final Color? activeColor;
  final Color? inActiveColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      itemSize: size ?? 24,
      initialRating: rating ?? 0.0,
      direction: Axis.horizontal,
      minRating: 1,
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Icon(
          Icons.star,
          color: (rating ?? 0.0) > index
              ? (activeColor ?? Theme.of(context).colorScheme.secondary)
              : (inActiveColor ?? Colors.grey.shade300),
        );
      },
      unratedColor: inActiveColor ?? Colors.grey.shade300,
      onRatingUpdate: (rating) {},
      allowHalfRating: true,
    );
  }
}
