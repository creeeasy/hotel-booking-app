// ignore_for_file: prefer_const_constructors
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/visitor/widget/custom_outlined_button.dart';
import 'package:fatiel/screens/visitor/widget/details_image_with_hero_widget.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/screens/visitor/widget/section_title_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utils/rating_utils.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailsView extends StatefulWidget {
  const HotelDetailsView({super.key});

  @override
  _HotelDetailsViewState createState() => _HotelDetailsViewState();
}

class _HotelDetailsViewState extends State<HotelDetailsView> {
  @override
  void initState() {
    super.initState();
  }

  Future<Hotel> initializeHotelData(BuildContext context) async {
    final hotelId = ModalRoute.of(context)?.settings.arguments as String;
    final hotel = await Hotel.getHotelById(hotelId);
    return hotel!;
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).canvasColor,
        child: SafeArea(
          child: FutureBuilder<Hotel>(
              future: initializeHotelData(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicatorWidget(
                    indicatorColor:
                        VisitorThemeColors.deepPurpleAccent.withOpacity(0.8),
                    containerColor: VisitorThemeColors.whiteColor,
                  );
                } else if (snapshot.hasError) {
                  return ErrorWidgetWithRetry(
                    errorMessage: 'Error: ${snapshot.error}',
                  );
                } else if (!snapshot.hasData) {
                  return NoDataWidget(
                    message: "No hotel listings found.",
                  );
                } else {
                  Hotel hotel = snapshot.data!;
                  return HotelDetailsBody(hotel: hotel);
                }
              }),
        ),
      );
}

class HotelDetailsBody extends StatefulWidget {
  final Hotel hotel;
  const HotelDetailsBody({super.key, required this.hotel});

  @override
  State<HotelDetailsBody> createState() => _HotelDetailsBodyState();
}

class _HotelDetailsBodyState extends State<HotelDetailsBody> {
  late Hotel hotel;
  void _bookNow() {}
  @override
  void initState() {
    super.initState();
    hotel = widget.hotel;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: VisitorThemeColors.whiteColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailsImageWithHero(
                  images: hotel.images,
                  hotelId: hotel.id,
                ),
                DividerWidget(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      hotel.hotelName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: VisitorThemeColors.blackColor,
                        letterSpacing: 1.1,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hotel.rooms.isNotEmpty
                          ? "${hotel.rooms.length} ${hotel.rooms.length == 1 ? 'offer' : 'offers'}"
                          : "No offers available",
                      style: TextStyle(
                        fontSize: 15, // Slightly reduced for better balance
                        fontWeight: FontWeight.w500,
                        color: VisitorThemeColors.textGreyColor,
                      ),
                    ),
                  ],
                ),
                DividerWidget(),
                SectionTitle(
                  title: "Location",
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: VisitorThemeColors.textGreyColor,
                      size: 22,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        (hotel.location != null)
                            ? Wilaya.fromIndex(hotel.location!)?.name ??
                                'Location not available'
                            : 'Location not available',
                        style: TextStyle(
                          fontSize: 16,
                          color: VisitorThemeColors.textGreyColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                DividerWidget(),
                SectionTitle(
                  title: "Description",
                ),
                Text(
                  hotel.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    color: VisitorThemeColors.textGreyColor,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.start,
                ),
                DividerWidget(),
                SectionTitle(
                  title: "Contact Info",
                ),
                Text(
                  hotel.contactInfo ?? 'No contact information available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: VisitorThemeColors.textGreyColor,
                    letterSpacing: 0.3,
                  ),
                ),
                DividerWidget(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: "Ratings",
                    ),
                    hotel.ratings.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: VisitorThemeColors.lightGrayColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'No Reviews Available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: VisitorThemeColors.textGreyColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: VisitorThemeColors.greyColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        getTotalRating(hotel.ratings)
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          5,
                                          (index) => Icon(Icons.star,
                                              color: Colors.black, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.emoji_events,
                                          color: Colors.black,
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "Top Rated",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${hotel.ratings.length}',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Reviews',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 10),
                    CustomOutlinedButton(
                      text: "View all ${hotel.ratings.length} reviews",
                      onPressed: () {
                        // Navigate to reviews page
                      },
                    )
                  ],
                ),
                if (hotel.mapLink != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DividerWidget(),
                      SectionTitle(
                        title: "View Hotel Location on Google Maps",
                      ),
                      CustomOutlinedButton(
                        text: "Open in Google Maps",
                        onPressed: () {
                          launchUrl(Uri.parse(hotel.mapLink!));
                        },
                      )
                    ],
                  ),
                DividerWidget(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hotel,
                            color: Colors.deepPurpleAccent, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "Explore Room Offers",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Find the best deals for your stay and book your preferred room easily.",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, roomBookingOffersViewRoute,
                              arguments: hotel.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                        icon: Icon(Icons.arrow_forward,
                            size: 20, color: Colors.white),
                        label: Text(
                          "View Room Offers",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
