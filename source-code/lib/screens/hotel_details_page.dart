import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/helpers/format_rating.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_outlined_button.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/image_gallery.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/screens/visitor/widget/section_title_widget.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailsView extends StatefulWidget {
  const HotelDetailsView({super.key});

  @override
  State<HotelDetailsView> createState() => _HotelDetailsViewState();
}

class _HotelDetailsViewState extends State<HotelDetailsView> {
  Future<Hotel> _initializeHotelData(BuildContext context) async {
    final hotelId = ModalRoute.of(context)?.settings.arguments as String;
    final hotel = await HotelService.getHotelById(hotelId);
    return hotel!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: ThemeColors.background,
        child: FutureBuilder<Hotel>(
          future: _initializeHotelData(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicatorWidget();
            }

            if (snapshot.hasError) {
              return ErrorWidgetWithRetry(
                errorMessage: L10n.of(context).failedToLoadHotelDetails,
                onRetry: () => setState(() {}),
              );
            }

            if (!snapshot.hasData) {
              return NoDataWidget(
                message: L10n.of(context).noHotelInformationAvailable,
                // icon: Iconsax.house_2,
              );
            }

            return HotelDetailsBody(hotel: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class HotelDetailsBody extends StatelessWidget {
  final Hotel hotel;
  const HotelDetailsBody({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageGallery(
                images: hotel.images,
                hotelId: hotel.id,
              ),
            ),
            backgroundColor: ThemeColors.background,
            automaticallyImplyLeading: false,
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHotelHeader(context),
                const DividerWidget(),
                _buildLocationSection(context),
                const DividerWidget(),
                _buildDescriptionSection(context),
                const DividerWidget(),
                _buildContactSection(context),
                const DividerWidget(),
                _buildRatingsSection(context),
                const DividerWidget(),
                _buildMapSection(context),
                const DividerWidget(),
                _buildRoomOffersSection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotel.hotelName.toUpperCase(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ThemeColors.primary,
            letterSpacing: 1.2,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (hotel.totalRooms != null)
          Text(
            "${hotel.totalRooms} ${hotel.totalRooms == 1 ? L10n.of(context).room : L10n.of(context).rooms} ${L10n.of(context).available}",
            style: const TextStyle(
              fontSize: 14,
              color: ThemeColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: L10n.of(context).location,
          titleColor: ThemeColors.primary,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Iconsax.location,
              color: ThemeColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hotel.location != null
                    ? Wilaya.fromIndex(hotel.location!)?.name ??
                        L10n.of(context).unknownLocation
                    : L10n.of(context).locationNotSpecified,
                style: const TextStyle(
                  fontSize: 16,
                  color: ThemeColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: L10n.of(context).description,
          titleColor: ThemeColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          hotel.description ?? L10n.of(context).noDescriptionAvailable,
          style: const TextStyle(
            fontSize: 15,
            color: ThemeColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: L10n.of(context).contactInformation,
          titleColor: ThemeColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          hotel.contactInfo ?? L10n.of(context).noContactInformationAvailable,
          style: const TextStyle(
            fontSize: 15,
            color: ThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: L10n.of(context).ratingsAndReviews,
          titleColor: ThemeColors.primary,
        ),
        const SizedBox(height: 12),
        hotel.ratings.totalRating == 0
            ? _buildNoRatings(context)
            : Column(
                children: [
                  _buildRatingsSummary(context),
                  const SizedBox(height: 16),
                  CustomOutlinedButton(
                    text:
                        "${L10n.of(context).viewAll} ${hotel.ratings.totalRating} ${L10n.of(context).reviews}",
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        reviewsScreenRoute,
                        arguments: hotel.id,
                      );
                    },
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildNoRatings(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: ThemeColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ThemeColors.primary.withOpacity(0.1),
          ),
        ),
        child: Text(
          L10n.of(context).noReviewsYet,
          style: const TextStyle(
            color: ThemeColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingsSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                formatRating(hotel.ratings.rating).toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                L10n.of(context).averageRating,
                style: const TextStyle(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                hotel.ratings.totalRating.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                L10n.of(context).totalReviews,
                style: const TextStyle(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: L10n.of(context).locationOnMap,
          titleColor: ThemeColors.primary,
        ),
        const SizedBox(height: 12),
        hotel.mapLink != null
            ? CustomOutlinedButton(
                text: L10n.of(context).openInMaps,
                onPressed: () => launchUrl(Uri.parse(hotel.mapLink!)),
              )
            : Text(
                L10n.of(context).mapLocationNotAvailable,
                style: const TextStyle(
                  color: ThemeColors.textSecondary,
                ),
              ),
      ],
    );
  }

  Widget _buildRoomOffersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: L10n.of(context).roomOffers,
          titleColor: ThemeColors.primary,
        ),
        const SizedBox(height: 12),
        Text(
          L10n.of(context).exploreRoomOffers,
          style: const TextStyle(
            color: ThemeColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                roomBookingOffersViewRoute,
                arguments: hotel.id,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.house_2, size: 20),
                const SizedBox(width: 8),
                Text(
                  L10n.of(context).viewRoomOffers,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
