// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
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
                        VisitorThemeColors.deepBlueAccent.withOpacity(0.8),
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
                    /// **Hotel Name** - Bold & eye-catching
                    Expanded(
                      child: Text(
                        hotel.hotelName
                            .toUpperCase(), // Converts to uppercase for luxury feel
                        style: TextStyle(
                          fontSize: 20, // Slightly larger for a premium look
                          fontFamily: 'Poppins',
                          fontWeight:
                              FontWeight.bold, // Increased for brand identity
                          color: VisitorThemeColors.primaryColor,
                          letterSpacing: 1.5, // More spacing = more elegance
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis, // Prevents overflow issues
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// **Offers Count** - Dynamic & Subtle
                    Text(
                      hotel.totalRooms != 0
                          ? "${hotel.totalRooms} ${hotel.totalRooms == 1 ? 'Offer' : 'Offers'}"
                          : "No Offers Available",
                      style: TextStyle(
                        fontSize: 14.5, // Adjusted for better balance
                        fontWeight:
                            FontWeight.w600, // Slightly bold for readability
                        letterSpacing: 0.8,
                        color: hotel.totalRooms != 0
                            ? VisitorThemeColors.textGreyColor
                            : VisitorThemeColors.textGreyColor
                                .withOpacity(0.6), // Faded for no offers
                      ),
                    ),
                  ],
                ),
                DividerWidget(),
                SectionTitle(
                  titleColor: Colors.deepOrange,
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
                      ),
                    ),
                  ],
                ),
                DividerWidget(),
                SectionTitle(
                  titleColor: Colors.deepOrange,
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
                  titleColor: Colors.deepOrange,
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
                      titleColor: Colors.deepOrange,
                      title: "Ratings",
                    ),
                    hotel.ratings.totalRating == 0
                        ? Center(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: VisitorThemeColors.primaryColor
                                    .withOpacity(0.16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'No Reviews Available',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: VisitorThemeColors.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: VisitorThemeColors.primaryColor
                                  .withOpacity(0.06),
                              border: Border.all(
                                color: VisitorThemeColors.primaryColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        hotel.ratings.rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              VisitorThemeColors.primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          5,
                                          (index) => Icon(Icons.star,
                                              color: VisitorThemeColors
                                                  .primaryColor,
                                              size: 20),
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
                                            color:
                                                VisitorThemeColors.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.emoji_events,
                                          color:
                                              VisitorThemeColors.primaryColor,
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "Top Rated",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              VisitorThemeColors.primaryColor,
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
                                        hotel.ratings.totalRating.toString(),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              VisitorThemeColors.primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Reviews',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: VisitorThemeColors
                                                .primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 10),
                    if ((hotel.ratings.totalRating) > 0)
                      CustomOutlinedButton(
                        text: "View all ${hotel.ratings.totalRating} reviews",
                        onPressed: () {
                          Navigator.pushNamed(context, reviewsScreenRoute,
                              arguments: hotel.id);
                        },
                      )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DividerWidget(),
                    SectionTitle(
                      titleColor: Colors.deepOrange,
                      title: "View Hotel Location on Google Maps",
                    ),
                    hotel.mapLink != null
                        ? CustomOutlinedButton(
                            text: "Open in Google Maps",
                            onPressed: () {
                              launchUrl(Uri.parse(hotel.mapLink!));
                            },
                          )
                        : Center(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: VisitorThemeColors.primaryColor
                                    .withOpacity(0.16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Map link unavailable for this hotel.",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: VisitorThemeColors.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ],
                ),
                DividerWidget(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hotel, color: Colors.deepOrange, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "Explore Room Offers",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Find the best deals for your stay and book your preferred room easily.",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: VisitorThemeColors.blackColor),
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
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.arrow_forward,
                            size: 20, color: Colors.white),
                        label: Text(
                          "View Room Offers",
                          style: TextStyle(
                            fontFamily: 'Poppins',
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
