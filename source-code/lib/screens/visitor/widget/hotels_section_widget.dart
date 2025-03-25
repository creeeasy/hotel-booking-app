import 'package:carousel_slider/carousel_slider.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/hotel_list_type.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/screens/visitor/hotel_browse_view.dart';
import 'package:fatiel/screens/visitor/widget/booking_hotel_details_widget.dart';
import 'package:fatiel/screens/visitor/widget/section_header_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:fatiel/widgets/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExploreSectionWidget extends StatefulWidget {
  const ExploreSectionWidget({Key? key, this.location}) : super(key: key);
  final int? location;

  @override
  State<ExploreSectionWidget> createState() => _ExploreSectionWidgetState();
}

class _ExploreSectionWidgetState extends State<ExploreSectionWidget>
    with SingleTickerProviderStateMixin {
  late HotelListType selectedTab;
  RangeValues? _selectedRatingRange;

  @override
  void initState() {
    super.initState();
    selectedTab = HotelListType.recommended;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TabWidget<HotelListType>(
          selectedTab: selectedTab,
          onTabChange: (HotelListType newTab) {
            setState(() {
              selectedTab = newTab;
            });
          },
          tabs: HotelListType.values,
          getTabTitle: (tab) {
            switch (tab) {
              case HotelListType.recommended:
                return 'Recommended';
              case HotelListType.nearMe:
                return 'Near Me';
            }
          },
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Hotel>>(
          future: selectedTab == HotelListType.recommended
              ? Hotel.getRecommendedHotels(
                  params: HotelFilterParameters(
                    location: widget.location,
                    minRating: _selectedRatingRange?.start.toInt(),
                    maxRating: _selectedRatingRange?.end.toInt(),
                  ),
                  limit: 5)
              : Hotel.getNearbyHotels(
                  widget.location,
                  params: HotelFilterParameters(
                    minRating: _selectedRatingRange?.start.toInt(),
                    maxRating: _selectedRatingRange?.end.toInt(),
                  ),
                ),
          builder: (context, snapshot) {
            int hotelsCount = snapshot.hasData ? snapshot.data!.length : 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: selectedTab == HotelListType.recommended
                      ? 'Recommended Hotels ($hotelsCount)'
                      : 'Hotels Near You ($hotelsCount)',
                  onSeeAllTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HotelBrowseView(
                        filterFunction: (HotelFilterParameters params) {
                          return selectedTab == HotelListType.recommended
                              ? Hotel.getRecommendedHotels(params: params)
                              : Hotel.getNearbyHotels(widget.location,
                                  params: params);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const CardLoadingIndicator(
                    backgroundColor: VisitorThemeColors.whiteColor,
                  )
                else if (snapshot.hasError)
                  ErrorWidgetWithRetry(
                    errorMessage: 'Error: ${snapshot.error}',
                  )
                else if (snapshot.hasData && snapshot.data!.isNotEmpty)
                  _buildHotelsCarousel(snapshot.data!)
                else
                  _buildNoHotelsFound(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHotelsCarousel(List<Hotel> hotels) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 260,
        viewportFraction: 0.8,
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
    );
  }

  Widget _buildNoHotelsFound() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VisitorThemeColors.lightGrayColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.hotel,
              color: VisitorThemeColors.greyColor.withOpacity(0.75),
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Hotels Available",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: VisitorThemeColors.blackColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "We couldn't find any hotels matching your criteria. Try adjusting your filters or check back later.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: VisitorThemeColors.textGreyColor.withOpacity(0.85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
