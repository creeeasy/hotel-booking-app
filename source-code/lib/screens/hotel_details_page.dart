// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/models/facility_icons.dart';
import 'package:fatiel/screens/visitor/widget/favorite_button_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/widgets/image_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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
    return hotel;
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).canvasColor,
        child: SafeArea(
          child: FutureBuilder<Hotel>(
              future: initializeHotelData(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        VisitorThemeColors.primaryColor,
                      ),
                    ),
                  ));
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: Text('Hotel not found')),
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
          backgroundColor: VisitorThemeColors.lightGrayColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailsImageWithHero(
                  images: hotel.images ?? [],
                  hotelId: hotel.id,
                ),
                SizedBox(height: 8),
                Text(
                  hotel.hotelName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: VisitorThemeColors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: VisitorThemeColors.pinkAccent, size: 24),
                    SizedBox(width: 8),
                    Text(
                      hotel.location != null
                          ? Wilaya.fromIndex(hotel.location!)?.name ??
                              'Location not available'
                          : 'Location not available',
                      style: TextStyle(
                        fontSize: 16,
                        color: VisitorThemeColors.blackColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VisitorThemeColors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  hotel.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    color: VisitorThemeColors.blackColor,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Facilities",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VisitorThemeColors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 8),
                hotel.facilities != null && hotel.facilities!.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: VisitorThemeColors.whiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: VisitorThemeColors.blackColor
                                  .withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          width: double.infinity, // Full width
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: VisitorThemeColors.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: VisitorThemeColors.blackColor
                                    .withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: hotel.facilities!.map((item) {
                                var facility = FacilityIcons.getFacility(item);
                                return Container(
                                  width: 80,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: VisitorThemeColors.accentColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: VisitorThemeColors
                                              .deepPurpleAccent
                                              .withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: SvgPicture.asset(
                                          facility.svgPath,
                                          width: 30,
                                          height: 30,
                                          color: VisitorThemeColors
                                              .deepPurpleAccent,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        facility.name,
                                        textAlign: TextAlign.center,
                                        maxLines:
                                            2, // Ensures it wraps if needed
                                        overflow: TextOverflow
                                            .ellipsis, // Handles long text
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: VisitorThemeColors
                                              .deepPurpleAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        "No facilities available",
                        style: TextStyle(
                          fontSize: 16,
                          color: VisitorThemeColors.blackColor,
                        ),
                      ),
                SizedBox(height: 20),
                Text(
                  "Contact Info",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VisitorThemeColors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  hotel.contactInfo ?? 'No contact information available',
                  style: TextStyle(
                    fontSize: 16,
                    color: VisitorThemeColors.blackColor,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Check-In / Check-Out",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VisitorThemeColors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        color: VisitorThemeColors.pinkAccent, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Check-In: ${hotel.checkInTime ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 16,
                        color: VisitorThemeColors.blackColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        color: VisitorThemeColors.pinkAccent, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Check-Out: ${hotel.checkOutTime ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 16,
                        color: VisitorThemeColors.blackColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: VisitorThemeColors.deepPurpleAccent,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.phone, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _bookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VisitorThemeColors.pinkAccent,
                          minimumSize: const Size(140, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          "Book now",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: VisitorThemeColors.whiteColor,
                            letterSpacing: 0.5,
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

class DetailsImageWithHero extends StatefulWidget {
  const DetailsImageWithHero(
      {super.key, required this.images, required this.hotelId});

  final List<String> images;
  final String hotelId;

  @override
  State<DetailsImageWithHero> createState() => _DetailsImageWithHeroState();
}

class _DetailsImageWithHeroState extends State<DetailsImageWithHero> {
  late PageController _pageController;
  int currentIndex = 0;
  Future<void> handleFavoriteTap(String visitorId) async {
    await Hotel.addHotelToFav(
      hotelId: widget.hotelId,
      visitorId: visitorId,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final favorites = (state.currentUser as Visitor).favorites ?? [];
        return Column(
          children: [
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.isNotEmpty ? widget.images.length : 1,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Hero(
                      tag: widget.images.isEmpty
                          ? UniqueKey().toString()
                          : widget.images[index],
                      child: Stack(
                        children: [
                          widget.images.isEmpty
                              ? ImageErrorWidget(title: "No image available")
                              : CachedNetworkImage(
                                  imageUrl: widget.images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error,
                                          color: Colors.red),
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
                                  duration: const Duration(milliseconds: 300),
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
                                  child: FavoriteButton(
                                    onTap: () async {
                                      print("object");
                                      await handleFavoriteTap(
                                          (state.currentUser as Visitor).id);
                                    },
                                    isFavorite:
                                        (favorites).contains(favorites[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size:
                                    32, // Slightly increased for better visibility
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            if (widget.images.isNotEmpty)
              ThumbnailList(
                images: widget.images,
                currentIndex: currentIndex,
                onThumbnailTap: (index) {
                  if (currentIndex != index) {
                    setState(() {
                      currentIndex = index;
                    });
                    _pageController.jumpToPage(index);
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

class ThumbnailList extends StatelessWidget {
  const ThumbnailList({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onThumbnailTap,
  });

  final List<String> images;
  final int currentIndex;
  final Function(int) onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Directly navigate to the selected image
              onThumbnailTap(index);
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentIndex == index
                      ? VisitorThemeColors
                          .deepPurpleAccent // Highlight border for the current image
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  height: 64,
                  width: 64,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
