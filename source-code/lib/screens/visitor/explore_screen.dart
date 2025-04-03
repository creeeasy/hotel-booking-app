import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/hotel_list_type.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/hotel_browse_view.dart';
import 'package:fatiel/screens/visitor/widget/featured_hotel_card.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
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
  final _cityCarouselController = CarouselController();
  late HotelFilterParameters _currentFilters;
  int? userLocation;

  @override
  void initState() {
    super.initState();
    userLocation =
        (context.read<AuthBloc>().state.currentUser as Visitor).location;
    _currentFilters = widget.initialFilters ?? HotelFilterParameters();
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
                  _buildMainContentSection(),
                  _buildCitiesSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshData() async => setState(() {});

  SliverPadding _buildAppBarSection(Visitor visitor) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
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
                  child: const UserProfile(),
                ),
                const SizedBox(width: 12),
                Text(
                  "${visitor.firstName} ${visitor.lastName}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.textPrimary,
                      ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Iconsax.search_normal,
                    color: ThemeColors.primary, size: 24),
                onPressed: () =>
                    Navigator.pushNamed(context, searchHotelViewRoute),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildMainContentSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabSelector(),
            const SizedBox(height: 24),
            FutureBuilder<List<Hotel>>(
              future: _getHotelsBasedOnTab(),
              builder: (context, snapshot) {
                final hotelsCount = snapshot.data?.length ?? 0;
                return Column(
                  children: [
                    SectionHeader(
                      title: _getSectionTitle(hotelsCount),
                      onSeeAllTap: _navigateToHotelBrowse,
                    ),
                    const SizedBox(height: 16),
                    _buildHotelContent(snapshot),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.border, width: 1),
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
                  gradient: isSelected ? ThemeColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: ThemeColors.shadow,
                            blurRadius: 6,
                            offset: Offset(0, 3),
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
                          ? ThemeColors.textOnPrimary
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
    );
  }

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
          appBackTitle: _selectedTab == HotelListType.recommended
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

  Widget _buildHotelContent(AsyncSnapshot<List<Hotel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CardLoadingIndicator(
        height: 280,
        backgroundColor: ThemeColors.surface,
        indicatorColor: ThemeColors.primary,
        padding: EdgeInsets.zero,
      );
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
    return CarouselSlider.builder(
      carouselController: _hotelCarouselController,
      itemCount: hotels.length,
      options: CarouselOptions(
        height: 280,
        viewportFraction: 0.85,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        autoPlay: hotels.length > 1,
        autoPlayInterval: const Duration(seconds: 4),
      ),
      itemBuilder: (context, index, _) {
        return FeaturedHotelCard(
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
    );
  }

  Widget _buildNoHotelsFound() {
    return CheerfulEmptyState.forHotels();
  }

  SliverPadding _buildCitiesSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SectionHeader(
              title: L10n.of(context).findHotelsInCities,
              onSeeAllTap: () =>
                  Navigator.pushNamed(context, allWilayaViewRoute),
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

  Widget _buildCitiesCarousel(Map<int, int> hotelStats) {
    final filteredWilayas = Wilaya.wilayasList
        .where((wilaya) =>
            hotelStats[wilaya.ind] != null && hotelStats[wilaya.ind]! > 0)
        .toList();

    if (filteredWilayas.isEmpty) {
      return CheerfulEmptyState.forCities();
    }

    return CarouselSlider.builder(
      carouselController: _cityCarouselController,
      itemCount: filteredWilayas.length,
      options: CarouselOptions(
        height: 140,
        viewportFraction: 0.45,
        enableInfiniteScroll: false,
        autoPlay: filteredWilayas.length > 1,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      itemBuilder: (context, index, _) {
        final wilaya = filteredWilayas[index];
        return ExploreCityWidget(
          wilaya: wilaya,
          count: hotelStats[wilaya.ind] ?? 0,
          onTap: () => _navigateToWilayaHotels(wilaya),
        );
      },
    );
  }

  void _navigateToWilayaHotels(Wilaya wilaya) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelBrowseView(
          initialFilters: _currentFilters.copyWith(location: wilaya.ind),
          filterFunction: (params) => HotelService.getRecommendedHotels(
            params: params.copyWith(location: wilaya.ind),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final VoidCallback onSeeAllTap;
  final String title;

  const SectionHeader({
    super.key,
    required this.onSeeAllTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ThemeColors.textPrimary,
              ),
        ),
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
                L10n.of(context).seeAll,
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

class ExploreCityWidget extends StatelessWidget {
  final Wilaya wilaya;
  final VoidCallback? onTap;
  final int count;

  const ExploreCityWidget({
    super.key,
    required this.wilaya,
    this.onTap,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: height * 0.08,
              horizontal: width * 0.08,
            ),
            decoration: BoxDecoration(
              color: ThemeColors.white,
              borderRadius: BorderRadius.circular(height * 0.15),
              boxShadow: const [
                BoxShadow(
                  color: ThemeColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height * 0.15),
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Image.asset(
                      wilaya.image,
                      fit: BoxFit.cover,
                      cacheHeight: height.toInt(),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ThemeColors.darkBackground.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: height * 0.08,
                    bottom: height * 0.1,
                    child: Text(
                      wilaya.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: height * 0.16,
                        color: ThemeColors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.08,
                    right: height * 0.08,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.03,
                        horizontal: width * 0.04,
                      ),
                      decoration: BoxDecoration(
                        gradient: ThemeColors.accentGradient,
                        borderRadius: BorderRadius.circular(height * 0.075),
                      ),
                      child: Text(
                        '$count ${L10n.of(context).hotels}',
                        style: TextStyle(
                          color: ThemeColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: height * 0.12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  // City-specific empty state
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
    // Access localized strings here
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
