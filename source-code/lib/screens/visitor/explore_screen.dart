import 'package:fatiel/constants/hotel_price_ranges.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/hotel_list_type.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/hotel_browse_view.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/favorite_button_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/services/room/room_service.dart';
import 'package:fatiel/utils/user_profile.dart';
import 'package:fatiel/widgets/card_loading_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class ExploreView extends StatefulWidget {
  final HotelFilterParameters? initialFilters;

  const ExploreView({super.key, this.initialFilters});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  HotelListType _selectedTab = HotelListType.recommended;
  final _hotelCarouselController = CarouselController();
  final _cityScrollController = ScrollController();
  late HotelFilterParameters _currentFilters;
  int? userLocation;

  @override
  void initState() {
    super.initState();
    userLocation =
        (context.read<AuthBloc>().state.currentUser as Visitor).location;
    _currentFilters = widget.initialFilters ?? const HotelFilterParameters();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final currentVisitor = state.currentUser as Visitor;

          return Scaffold(
            backgroundColor: ThemeColors.background,
            body: RefreshIndicator(
              onRefresh: _refreshData,
              color: ThemeColors.primary,
              backgroundColor: ThemeColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBarSection(currentVisitor),
                  _buildHeroSection(),
                  _buildTabSection(),
                  _buildHotelsSection(),
                  _buildCitiesSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================ Widget Builders ================ //

  SliverPadding _buildAppBarSection(Visitor visitor) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, visitorProfileRoute),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeColors.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const UserProfile(),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.of(context).hello,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: ThemeColors.textSecondary,
                          ),
                    ),
                    Text(
                      "${visitor.firstName} ${visitor.lastName}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ThemeColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.search_normal,
                    color: ThemeColors.primary, size: 24),
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, searchHotelViewRoute),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeroSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.of(context).findYourPerfectStay,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              L10n.of(context).discoverAmazingHotels,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildTabSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: HotelListType.values.map((tab) {
              final isSelected = tab == _selectedTab;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = tab),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? ThemeColors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: ThemeColors.shadow.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        tab == HotelListType.recommended
                            ? L10n.of(context).recommended
                            : L10n.of(context).nearMe,
                        style: TextStyle(
                          color: isSelected
                              ? ThemeColors.primary
                              : ThemeColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildHotelsSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: FutureBuilder<List<Hotel>>(
          future: _getHotelsBasedOnTab(),
          builder: (context, snapshot) {
            final hotelsCount = snapshot.data?.length ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SectionHeader(
                  title: _getSectionTitle(hotelsCount),
                  onSeeAllTap: _navigateToHotelBrowse,
                  actionLabel: L10n.of(context).seeAll,
                ),
                const SizedBox(height: 16),
                _buildHotelContent(snapshot),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverPadding _buildCitiesSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SectionHeader(
              title: L10n.of(context).popularDestinations,
              onSeeAllTap: () =>
                  Navigator.pushNamed(context, allWilayaViewRoute),
              actionLabel: L10n.of(context).exploreAll,
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<int, int>>(
              future: HotelService.getHotelStatistics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CardLoadingIndicator(
                    height: 140,
                    backgroundColor: ThemeColors.surface,
                    indicatorColor: ThemeColors.primary,
                    padding: EdgeInsets.zero,
                  );
                } else if (snapshot.hasError) {
                  return ErrorWidgetWithRetry(
                    errorMessage: L10n.of(context).failedToLoadCityData,
                    onRetry: () => setState(() {}),
                  );
                } else if (snapshot.hasData) {
                  return _buildCitiesCarousel(snapshot.data!);
                } else {
                  return CheerfulEmptyState.forCities();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================ Content Builders ================ //

  Widget _buildHotelContent(AsyncSnapshot<List<Hotel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const HotelListShimmer();
    } else if (snapshot.hasError) {
      return ErrorWidgetWithRetry(
        errorMessage: L10n.of(context).failedToLoadHotels,
        onRetry: () => setState(() {}),
      );
    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
      return _buildHotelsCarousel(snapshot.data!);
    } else {
      return _buildNoHotelsFound();
    }
  }

  Widget _buildHotelsCarousel(List<Hotel> hotels) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _hotelCarouselController,
          itemCount: hotels.length,
          options: CarouselOptions(
            height: 320, // Must match HotelCard height
            viewportFraction: 0.85,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            autoPlay: hotels.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
          ),
          itemBuilder: (context, index, _) {
            return HotelCard(
              hotel: hotels[index],
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  hotelDetailsRoute,
                  arguments: hotels[index].id,
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        _buildPriceFilterChips(),
      ],
    );
  }

  // In _buildPriceFilterChips()
  Widget _buildPriceFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 12),
          ...priceRanges.map((range) {
            final isSelected = _currentFilters.minPrice == range['min'] &&
                _currentFilters.maxPrice == range['max'];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(range['label']),
                selected: isSelected,
                onSelected: (selected) => setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    minPrice: selected ? range['min'] : null,
                    maxPrice: selected ? range['max'] : null,
                  );
                }),
                selectedColor: ThemeColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected
                      ? ThemeColors.primary
                      : ThemeColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color:
                        isSelected ? ThemeColors.primary : ThemeColors.border,
                  ),
                ),
              ),
            );
          }),
          // "Surprise Me" button remains the same
        ],
      ),
    );
  }

  Widget _buildCitiesCarousel(Map<int, int> hotelStats) {
    final filteredWilayas = Wilaya.wilayasList
        .where((wilaya) =>
            hotelStats[wilaya.ind] != null && hotelStats[wilaya.ind]! > 0)
        .toList();

    if (filteredWilayas.isEmpty) {
      return CheerfulEmptyState.forCities();
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        controller: _cityScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: filteredWilayas.length,
        itemBuilder: (context, index) {
          final wilaya = filteredWilayas[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 12,
              right: index == filteredWilayas.length - 1 ? 0 : 12,
            ),
            child: CityCard(
              wilaya: wilaya,
              hotelCount: hotelStats[wilaya.ind] ?? 0,
              onTap: () => _navigateToWilayaHotels(wilaya),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoHotelsFound() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal,
            size: 48,
            color: ThemeColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            L10n.of(context).noHotelsFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ThemeColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.of(context).tryAdjustingFilters,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentFilters = const HotelFilterParameters();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              L10n.of(context).resetFilters,
              style: const TextStyle(
                color: ThemeColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================ Helper Methods ================ //

  Future<List<Hotel>> _getHotelsBasedOnTab() {
    final params = _currentFilters.copyWith(
      location: _selectedTab == HotelListType.nearMe
          ? userLocation
          : _currentFilters.location,
    );
    return _selectedTab == HotelListType.recommended
        ? HotelService.getRecommendedHotels(params: params)
        : HotelService.getNearbyHotels(userLocation, params: params);
  }

  String _getSectionTitle(int count) {
    return _selectedTab == HotelListType.recommended
        ? L10n.of(context).recommendedHotelsCount(count)
        : L10n.of(context).hotelsNearYouCount(count);
  }

  void _navigateToHotelBrowse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelBrowseView(
          useUserLocationOnly: _selectedTab == HotelListType.nearMe,
          appBarTitle: _selectedTab == HotelListType.recommended
              ? L10n.of(context).recommendedHotels
              : L10n.of(context).hotelsNearYou,
          initialFilters: _currentFilters,
          filterFunction: (params) => _selectedTab == HotelListType.recommended
              ? HotelService.getRecommendedHotels(params: params)
              : HotelService.getNearbyHotels(userLocation, params: params),
        ),
      ),
    );
  }

  void _navigateToWilayaHotels(Wilaya wilaya) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelBrowseView(
          appBarTitle: L10n.of(context).hotelsInWilaya(wilaya.name),
          useUserLocationOnly: true,
          initialFilters: _currentFilters.copyWith(location: wilaya.ind),
          filterFunction: (params) => HotelService.getRecommendedHotels(
            params: params.copyWith(location: wilaya.ind),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async => setState(() {});
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onPressed;
  final bool showFavoriteButton;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onPressed,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final locationName =
        hotel.location != null ? Wilaya.fromIndex(hotel.location!)?.name : null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ThemeColors.card,
          boxShadow: const [
            BoxShadow(
              color: ThemeColors.shadow,
              blurRadius: 15,
              spreadRadius: 0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        height: 320, // Fixed height for the entire card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - fixed height
            SizedBox(
              height: 180, // Fixed height for image
              width: double.infinity,
              child: Stack(
                children: [
                  _buildHotelImage(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          ThemeColors.darkTransparent,
                        ],
                        stops: [0.5, 1],
                      ),
                    ),
                  ),
                  if (hotel.ratings.rating >= 4.5)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: ThemeColors.accentGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: ThemeColors.shadowDark,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'PREMIUM',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: ThemeColors.textOnDark,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ThemeColors.darkBackground.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.star1,
                              size: 14, color: ThemeColors.star),
                          const SizedBox(width: 4),
                          Text(
                            hotel.ratings.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: ThemeColors.textOnDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FavoriteButton(
                      hotelId: hotel.id,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            // Content Section - flexible height within remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel Name
                        Text(
                          hotel.hotelName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: ThemeColors.textPrimary,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Row(
                          children: [
                            const Icon(
                              Iconsax.location,
                              size: 14,
                              color: ThemeColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                locationName ??
                                    L10n.of(context).locationNotSpecified,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: ThemeColors.textSecondary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Price & Button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10n.of(context).startingFrom,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: ThemeColors.textSecondary,
                                  ),
                            ),
                            FutureBuilder<String>(
                              future: RoomService.getStartingPrice(hotel),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final price = snapshot.data;
                                  return Column(
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        '${L10n.of(context).currencySymbol} $price',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: ThemeColors.primary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage() {
    if (hotel.images.isEmpty) {
      return Container(
        color: ThemeColors.grey100,
        child: const Center(
          child: Icon(
            Iconsax.gallery_slash,
            size: 40,
            color: ThemeColors.grey400,
          ),
        ),
      );
    }

    return Image.network(
      hotel.images.first,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: ThemeColors.primary,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: ThemeColors.grey100,
        child: const Center(
          child: Icon(
            Iconsax.gallery_slash,
            size: 40,
            color: ThemeColors.grey400,
          ),
        ),
      ),
    );
  }
}

class CityCard extends StatelessWidget {
  final Wilaya wilaya;
  final int hotelCount;
  final VoidCallback onTap;

  const CityCard({
    super.key,
    required this.wilaya,
    required this.hotelCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(wilaya.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient Overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              ThemeColors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Hotel Count
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ThemeColors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$hotelCount ${L10n.of(context).hotels}',
                          style: const TextStyle(
                            color: ThemeColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // City Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                wilaya.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllTap;
  final String actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAllTap,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: ThemeColors.textPrimary,
              fontSize: 16,
            )),
        TextButton(
          onPressed: onSeeAllTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: ThemeColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HotelListShimmer extends StatelessWidget {
  const HotelListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: ThemeColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: ThemeColors.grey100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                // Text placeholders
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 20,
                        color: ThemeColors.grey100,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 16,
                        color: ThemeColors.grey100,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 100,
                        height: 16,
                        color: ThemeColors.grey100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CheerfulEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double iconSize;
  final Color iconColor;

  const CheerfulEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconSize = 48,
    this.iconColor = ThemeColors.textSecondary,
  });

  // Hotel-specific empty state
  factory CheerfulEmptyState.forHotels({
    Key? key,
    String? title,
    String? description,
  }) {
    return CheerfulEmptyState(
      key: key,
      title: title ?? '', // Empty string, to be set in build method
      description: description ?? '', // Empty string, to be set in build method
      icon: Icons.hotel_outlined,
      iconColor: ThemeColors.primary,
    );
  }

  factory CheerfulEmptyState.forCities({
    Key? key,
    String? title,
    String? description,
  }) {
    return CheerfulEmptyState(
      key: key,
      title: title ?? '',
      description: description ?? '',
      icon: Icons.location_city_outlined,
      iconColor: ThemeColors.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String localizedTitle =
        title.isEmpty ? L10n.of(context).noHotelsFound : title;
    final String localizedDescription = description.isEmpty
        ? L10n.of(context).noHotelsDescription
        : description;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(height: 20),
          Text(
            localizedTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            localizedDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.textSecondary,
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
