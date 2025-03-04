// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/favorite_button_widget.dart';
import 'package:fatiel/screens/visitor/widget/hotel_image_widget.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/utils/rating_utils.dart';
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:fatiel/widgets/rating_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HotelRowOneWidget extends StatefulWidget {
  const HotelRowOneWidget({
    super.key,
    this.isShowDate = false,
    required this.hotelId,
    this.animationController,
    this.animation,
  });
  final bool isShowDate;
  final String hotelId;
  final AnimationController? animationController;
  final Animation? animation;
  @override
  State<HotelRowOneWidget> createState() => _HotelRowOneWidgetState();
}

class _HotelRowOneWidgetState extends State<HotelRowOneWidget> {
  bool isRemoved = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Hotel.getHotelById(widget.hotelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CardLoadingIndicator();
          }
          if (snapshot.hasError) {
            return ErrorWidgetWithRetry(
              errorMessage: 'Error: ${snapshot.error}',
            );
          } else if (snapshot.hasData) {
            // if (snapshot.data is Hotel) {
            //   log('HOtel');
            //   log(snapshot.data.runtimeType.toString());
            // } else {
            //   log(snapshot.data.runtimeType.toString());
            // }

            final hotel = snapshot.data as Hotel;
            return InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(hotelDetailsRoute, arguments: hotel.id);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: AnimatedBuilder(
                  animation: widget.animationController!,
                  builder: (BuildContext context, Widget? child) {
                    return FadeTransition(
                      opacity: widget.animation as Animation<double>,
                      child: Transform(
                        transform: Matrix4.translationValues(
                            0.0, 50 * (1.0 - widget.animation!.value), 0.0),
                        child: Column(
                          children: <Widget>[
                            if (widget.isShowDate)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "fsdfsdf",
                                  style: TextStyle(
                                      color: VisitorThemeColors.blackColor),
                                ),
                              ),
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16.0)),
                              child: Stack(
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child:
                                        HotelImageWidget(images: hotel.images),
                                  ),
                                  // Optional: Add a gradient overlay for better text visibility
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.6),
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hotel.hotelName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              FontAwesomeIcons.mapMarkerAlt,
                                              size: 12,
                                              color: VisitorThemeColors
                                                  .primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                hotel.location != null
                                                    ? Wilaya.fromIndex(
                                                                hotel.location!)
                                                            ?.name ??
                                                        'Location not available'
                                                    : 'Location not available',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: VisitorThemeColors
                                                        .whiteColor),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: <Widget>[
                                            RatingBarWidget(
                                              rating:
                                                  getTotalRating(hotel.ratings),
                                              size: 20,
                                              activeColor: VisitorThemeColors
                                                  .primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              " ${hotel.ratings.length} Reviews",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: VisitorThemeColors
                                                      .whiteColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: VisitorThemeColors.whiteColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          transitionBuilder: (Widget child,
                                              Animation<double> animation) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                  scale: animation,
                                                  child: child),
                                            );
                                          },
                                          child: FavoriteButton(
                                              hotelId: widget.hotelId),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return NoDataWidget(
              message: "We couldn't find any hotel data.",
            );
          }
        });
  }
}
