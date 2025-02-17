// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/screens/hotel_details_page.dart';
import 'package:fatiel/utils/rating_utils.dart';
import 'package:fatiel/widgets/hotel/network_image_widget.dart';
import 'package:fatiel/widgets/rating_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HotelRowOneWidget extends StatefulWidget {
  const HotelRowOneWidget({
    super.key,
    required this.visitorId,
    this.isShowDate = false,
    this.callback,
    required this.hotelId,
    this.animationController,
    this.animation,
  });
  final String visitorId;
  final bool isShowDate;
  final VoidCallback? callback;
  final String hotelId;
  final AnimationController? animationController;
  final Animation? animation;
  @override
  State<HotelRowOneWidget> createState() => _HotelRowOneWidgetState();
}

class _HotelRowOneWidgetState extends State<HotelRowOneWidget> {
  bool isRemoved = false;
  bool isLoading = false;
  Future<void> handleFavoriteTap() async {
    setState(() => isLoading = true);

    bool result = await Hotel.removeHotelFromFav(
      hotelId: widget.hotelId,
      visitorId: widget.visitorId,
    );

    setState(() {
      isRemoved = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Hotel.getHotelById(widget.hotelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      VisitorThemeColors.primaryColor,
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final hotel = snapshot.data as Hotel;
            return InkWell(
              onTap: () {
                log(hotel.email.toString());
                Navigator.of(context)
                    .pushNamed(hotelDetailsRoute, arguments: hotel.id);
              },
              child: AnimatedBuilder(
                animation: widget.animationController!,
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                    opacity: widget.animation as Animation<double>,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 50 * (1.0 - widget.animation!.value), 0.0),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 8, bottom: 16),
                        child: Column(
                          children: <Widget>[
                            widget.isShowDate
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, bottom: 12),
                                    child: Text(
                                      "fsdfsdf",
                                      style: TextStyle(
                                        color: VisitorThemeColors.blackColor,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0)),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: VisitorThemeColors.lightGrayColor,
                                    offset: const Offset(4, 4),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0)),
                                child: Stack(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        AspectRatio(
                                            aspectRatio: 2,
                                            child: NetworkImageWithLoader(
                                              // imageUrl: hotelId!.imagePath,
                                              imageUrl: "hotelId!.imagePath",
                                            )),
                                        Container(
                                          color: VisitorThemeColors.whiteColor,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16,
                                                          top: 8,
                                                          bottom: 8),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        hotel.hotelName,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 22,
                                                          color:
                                                              VisitorThemeColors
                                                                  .blackColor,
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            hotel.location !=
                                                                    null
                                                                ? Wilaya.fromIndex(
                                                                            hotel.location!)
                                                                        ?.name ??
                                                                    'Location not available'
                                                                : 'Location not available',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  VisitorThemeColors
                                                                      .greyColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .mapMarkerAlt,
                                                            size: 12,
                                                            color:
                                                                VisitorThemeColors
                                                                    .primaryColor,
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4),
                                                        child: Row(
                                                          children: <Widget>[
                                                            RatingBarWidget(
                                                              rating: getTotalRating(
                                                                  hotel
                                                                      .ratings),
                                                              size: 20,
                                                              activeColor:
                                                                  VisitorThemeColors
                                                                      .primaryColor,
                                                            ),
                                                            Text(
                                                              " ${hotel.ratings.length} Reviews",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: VisitorThemeColors
                                                                      .greyColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 16, top: 8),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                      hotel.pricePerNight !=
                                                              null
                                                          ? '\$${hotel.pricePerNight!.toStringAsFixed(2)} / night'
                                                          : 'Price not available',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15,
                                                        color:
                                                            VisitorThemeColors
                                                                .blackColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      bottom: 0,
                                      left: 0,
                                      child: InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: VisitorThemeColors
                                            .primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                                        onTap: () async {},
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color:
                                                VisitorThemeColors.whiteColor,
                                            shape: BoxShape.circle),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            transitionBuilder: (Widget child,
                                                Animation<double> animation) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: isLoading
                                                ? SizedBox(
                                                    height: 30,
                                                    width: 30,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        VisitorThemeColors
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )
                                                : InkWell(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(32.0),
                                                    ),
                                                    onTap: () async {
                                                      setState(() {
                                                        isLoading = true;
                                                      });

                                                      bool result = await Hotel
                                                          .removeHotelFromFav(
                                                        hotelId: widget.hotelId,
                                                        visitorId:
                                                            widget.visitorId,
                                                      );

                                                      setState(() {
                                                        isRemoved = result;
                                                        isLoading = false;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        Icons.favorite,
                                                        color:
                                                            VisitorThemeColors
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
