// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/facility_icons.dart';
import 'package:flutter/material.dart';
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
    // final hotelId = ModalRoute.of(context)?.settings.arguments as String;
    // log(hotelId.toString());
    final hotel = await Hotel.getHotelById("dHNQ0AKCIrWeqpKR81Q0fbfORZM2");
    // final hotel = await Hotel.getHotelById(hotelId);
    return hotel;
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).canvasColor,
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
    return Scaffold(
      backgroundColor: VisitorThemeColors.lightGrayColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailsImageWithHero(images: hotel.images ?? []),
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
                          color: VisitorThemeColors.blackColor.withOpacity(0.1),
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
                            color:
                                VisitorThemeColors.blackColor.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
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
                                      color: VisitorThemeColors.deepPurpleAccent
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      facility.svgPath,
                                      width: 30,
                                      height: 30,
                                      color:
                                          VisitorThemeColors.deepPurpleAccent,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    facility.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Ensures it wraps if needed
                                    overflow: TextOverflow
                                        .ellipsis, // Handles long text
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          VisitorThemeColors.deepPurpleAccent,
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
          ],
        ),
      ),
    );
  }
}
class DetailsImageWithHero extends StatefulWidget {
  const DetailsImageWithHero({super.key, required this.images});

  final List<String> images;

  @override
  State<DetailsImageWithHero> createState() => _DetailsImageWithHeroState();
}

class _DetailsImageWithHeroState extends State<DetailsImageWithHero> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Hero(
                  tag: widget.images[index], // Ensure each image has a unique tag
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),

        // Thumbnails
        ThumbnailList(
          images: widget.images,
          currentIndex: currentIndex,
          onThumbnailTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ],
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
        itemCount: images.length > 3 ? 3 : images.length, // Handle cases with fewer images
        itemBuilder: (context, index) {
          // No need to check 'isLastVisible' here, simply show thumbnails
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
                      ? VisitorThemeColors.deepPurpleAccent // Highlight border for the current image
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Display thumbnail image
                  ClipRRect(
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
                  // Show remaining count for more than 3 images
                  if (images.length > 3 && index == 2)
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "+${images.length - 3}", // Show remaining images count
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          // Full-screen image
          PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
              );
            },
          ),
          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
