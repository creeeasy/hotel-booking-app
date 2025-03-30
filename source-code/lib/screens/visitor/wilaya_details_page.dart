import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WilayaDetailsPageView extends StatefulWidget {
  const WilayaDetailsPageView({super.key});

  @override
  State<WilayaDetailsPageView> createState() => _WilayaDetailsPageViewState();
}

class _WilayaDetailsPageViewState extends State<WilayaDetailsPageView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> appBarColorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    appBarColorAnimation = ColorTween(
      begin: ThemeColors.background.withOpacity(0.5),
      end: ThemeColors.background,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<Hotel>> fetchHotels(BuildContext context, int wilayaId) async {
    return Hotel.getHotelsByWilaya(wilayaId);
  }

  @override
  Widget build(BuildContext context) {
    final wilayaId = ModalRoute.of(context)?.settings.arguments as int;
    final wilaya = Wilaya.fromIndex(wilayaId);
    if (wilaya == null) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Text(
              'Invalid wilaya ID: $wilayaId',
              style: const TextStyle(
                color: ThemeColors.error,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        extendBodyBehindAppBar: true,
        appBar: CustomBackAppBar(
          title: wilaya.name,
          onBack: () => Navigator.pop(context),
        ),
        body: FutureBuilder<List<Hotel>>(
          future: fetchHotels(context, wilayaId),
          builder: (context, snapshot) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: ThemeColors.primary.withOpacity(0.16),
                  automaticallyImplyLeading: false,
                  expandedHeight: 240,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'wilaya-$wilayaId',
                      child: CachedNetworkImage(
                        imageUrl: wilaya.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: ThemeColors.grey200,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: ThemeColors.grey200,
                          child: const Icon(
                            Iconsax.gallery_slash,
                            color: ThemeColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      "Hotels in ${wilaya.name}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicatorWidget(),
                    ),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: ErrorWidgetWithRetry(
                      errorMessage: 'Failed to load hotels',
                      onRetry: () => setState(() {}),
                    ),
                  )
                else if (!snapshot.hasData || snapshot.data!.isEmpty)
                  SliverFillRemaining(
                    child: NoHotelsWidget(
                      wilayaName: wilaya.name,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final hotel = snapshot.data![index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: HotelCard(
                                    hotel: hotel,
                                    onTap: () => _navigateToHotelDetails(hotel),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: snapshot.data!.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToHotelDetails(Hotel hotel) {
    Navigator.pushNamed(
      context,
      hotelDetailsRoute,
      arguments: hotel.id,
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hotel.images.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: hotel.images.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: ThemeColors.grey200,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: ThemeColors.grey200,
                    child: const Icon(
                      Iconsax.gallery_slash,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.hotelName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (hotel.location != null)
                    Row(
                      children: [
                        const Icon(
                          Iconsax.location,
                          size: 16,
                          color: ThemeColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            Wilaya.fromIndex(hotel.location!)?.name ??
                                'Unknown location',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ThemeColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.star1,
                            color: ThemeColors.star,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hotel.ratings.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${hotel.ratings.totalRating})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (hotel.totalRooms != null)
                        Text(
                          '${hotel.totalRooms} rooms',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoHotelsWidget extends StatelessWidget {
  final String wilayaName;
  final VoidCallback? onExploreNearby;

  const NoHotelsWidget({
    super.key,
    required this.wilayaName,
    this.onExploreNearby,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColors.primary.withOpacity(0.1),
            ),
            child: const Icon(
              Iconsax.building_4,
              size: 48,
              color: ThemeColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Hotels Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'There are currently no hotels registered in $wilayaName',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: ThemeColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          if (onExploreNearby != null)
            ElevatedButton(
              onPressed: onExploreNearby,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Text('Explore Nearby Wilayas'),
            ),
        ],
      ),
    );
  }
}
