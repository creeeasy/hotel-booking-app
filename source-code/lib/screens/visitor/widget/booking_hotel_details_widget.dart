import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/screens/visitor/widget/positioned_favorite_button_widget.dart';
import 'package:fatiel/utils/rating_utils.dart';
import 'package:fatiel/widgets/hotel/network_image_widget.dart';
import 'package:fatiel/widgets/image_error_widget.dart';
import 'package:flutter/material.dart';

class BookingHotelCard extends StatelessWidget {
  final Hotel hotel;

  const BookingHotelCard({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          hotelDetailsRoute,
          arguments: hotel.id,
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            (hotel.images?.isEmpty ?? true)
                ? const ImageErrorWidget(title: "No image available")
                : NetworkImageWithLoader(imageUrl: hotel.images?.first ?? ''),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.hotelName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hotel.location != null
                          ? Wilaya.fromIndex(hotel.location!)?.name ??
                              'Location not available'
                          : 'Location not available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              getTotalRating(hotel.ratings).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          hotel.pricePerNight != null
                              ? '\$${(hotel.pricePerNight as num).toDouble().toStringAsFixed(2)} / night'
                              : 'Price not available',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: VisitorThemeColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PositionedFavoriteButton(
              hotelId: hotel.id,
            ),
          ],
        ),
      ),
    );
  }
}
