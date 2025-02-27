// ignore_for_file: prefer_const_constructors

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/top_bar_type.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/visitor/widget/booking_hotel_details_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:fatiel/widgets/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/widgets/explore_item_header_widget.dart';

class ExploreSectionWidget extends StatefulWidget {
  const ExploreSectionWidget({Key? key, this.location}) : super(key: key);
  final int? location;

  @override
  State<ExploreSectionWidget> createState() => _ExploreSectionWidgetState();
}

class _ExploreSectionWidgetState extends State<ExploreSectionWidget>
    with SingleTickerProviderStateMixin {
  late TopBarType selectedTab;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    selectedTab = TopBarType.Popular;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int hotelsCount = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TripsTabView(
          selectedTab: selectedTab,
          onTabChange: (TopBarType newTab) {
            setState(() {
              selectedTab = newTab;
            });
          },
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Hotel>>(
            future: selectedTab == TopBarType.Popular
                ? Hotel.getPopularHotels()
                : Hotel.getNearbyHotels(widget.location),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CardLoadingIndicator(
                  backgroundColor: VisitorThemeColors.whiteColor,
                );
              } else if (snapshot.hasError) {
                return ErrorWidgetWithRetry(
                  errorMessage: 'Error: ${snapshot.error}',
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<Hotel> hotels = snapshot.data!;

                return Column(
                  children: [
                    ExploreItemHeaderWidget(
                      hotelsCount: hotels.length,
                      titleTxt: selectedTab == TopBarType.Popular
                          ? 'Popular Hotels'
                          : 'Hotels Near You',
                      subTxt: 'See all',
                      animationController: _animationController,
                      animation: _animation,
                      isLeftButton: true,
                      click: () {},
                    ),
                    const SizedBox(height: 20),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 260, // Slightly increased for better visibility
                        viewportFraction:
                            0.8, // Slightly reduced to balance focus
                        enlargeCenterPage: false,
                        scrollPhysics: const BouncingScrollPhysics(),
                      ),
                      items: hotels.map((hotel) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: BookingHotelCard(hotel: hotel),
                        );
                      }).toList(),
                    ),
                  ],
                );
              } else {
                return NoDataWidget(
                  message:
                      "No hotels available. Set your location to get the best recommendations!",
                );
              }
            })
      ],
    );
  }
}
