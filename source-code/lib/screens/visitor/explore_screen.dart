import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/hotel_list_type.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/hotel_browse_view.dart';
import 'package:fatiel/screens/visitor/widget/featured_hotel_card.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utils/user_profile.dart';
import 'package:fatiel/widgets/card_loading_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class ExploreView extends StatefulWidget {
  final int? location;

  const ExploreView({super.key, this.location});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  HotelListType _selectedTab = HotelListType.recommended;
  final _hotelCarouselController = CarouselController();
  final _cityCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final currentVisitor = state.currentUser as Visitor;
          return Scaffold(
            backgroundColor: ThemeColors.background,
            body: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              color: ThemeColors.primary,
              backgroundColor: ThemeColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBarSection(currentVisitor),
                  _buildMainContentSection(currentVisitor.location),
                  _buildCitiesSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: ThemeColors.primaryLight, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const UserProfile(),
                  ),
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

  SliverPadding _buildMainContentSection(int? location) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabSelector(),
            const SizedBox(height: 24),
            FutureBuilder<List<Hotel>>(
              future: _getHotelsBasedOnTab(location),
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
                        ? 'Recommended'
                        : 'Near Me',
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

  Future<List<Hotel>> _getHotelsBasedOnTab(int? location) {
    final params = HotelFilterParameters(location: location);
    return _selectedTab == HotelListType.recommended
        ? Hotel.getRecommendedHotels(params: params, limit: 5)
        : Hotel.getNearbyHotels(location, params: params);
  }

  String _getSectionTitle(int count) {
    return _selectedTab == HotelListType.recommended
        ? 'Recommended Hotels ($count)'
        : 'Hotels Near You ($count)';
  }

  void _navigateToHotelBrowse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelBrowseView(
          filterFunction: (params) => _selectedTab == HotelListType.recommended
              ? Hotel.getRecommendedHotels(params: params)
              : Hotel.getNearbyHotels(widget.location, params: params),
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
        errorMessage: 'Failed to load hotels',
        onRetry: () => setState(() {}),
        // backgroundColor: ThemeColors.error.withOpacity(0.1),
        // textColor: ThemeColors.error,
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
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          const Icon(
            Iconsax.house,
            size: 72,
            color: ThemeColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            "No Hotels Available",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "We couldn't find any hotels matching your criteria.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  SliverPadding _buildCitiesSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: "Find hotels in cities",
              onSeeAllTap: () =>
                  Navigator.pushNamed(context, allWilayaViewRoute),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<int, int>>(
              future: Hotel.getHotelStatistics(),
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
                    errorMessage: 'Failed to load city data',
                    onRetry: () => setState(() {}),
                    // backgroundColor: ThemeColors.error.withOpacity(0.1),
                    // textColor: ThemeColors.error,
                  );
                } else if (snapshot.hasData) {
                  return _buildCitiesCarousel(snapshot.data!);
                } else {
                  return const NoDataWidget(
                    message: "No hotels are currently listed in these cities.",
                    // backgroundColor: ThemeColors.grey50,
                    // textColor: ThemeColors.textSecondary,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitiesCarousel(Map<int, int> hotelStats) {
    return CarouselSlider.builder(
      carouselController: _cityCarouselController,
      itemCount: Wilaya.wilayasList.length,
      options: CarouselOptions(
        height: 140,
        viewportFraction: 0.45,
        enableInfiniteScroll: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      itemBuilder: (context, index, _) {
        final wilaya = Wilaya.wilayasList[index];
        return ExploreCityWidget(
          wilaya: wilaya,
          count: hotelStats[wilaya.ind] ?? 0,
          onTap: () => Navigator.pushNamed(
            context,
            wilayaDetailsViewRoute,
            arguments: wilaya.ind,
          ),
        );
      },
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.primary,
                ),
              ),
              SizedBox(width: 4),
              Icon(
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

class ExploreCityWidget extends StatefulWidget {
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
  State<ExploreCityWidget> createState() => _ExploreCityWidgetState();
}

class _ExploreCityWidgetState extends State<ExploreCityWidget> {
  late Wilaya wilaya;

  @override
  void initState() {
    super.initState();
    wilaya = Wilaya.fromIndex(widget.wilaya.ind)!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        // Scale elements based on height (Adaptive UI)
        final titleFontSize = height * 0.16;
        final hotelCountFontSize = height * 0.12;
        final padding = height * 0.08;
        final borderRadius = height * 0.15;
        final shadowBlur = height * 0.06;
        final hotelBadgePadding = EdgeInsets.symmetric(
          vertical: height * 0.03,
          horizontal: width * 0.04,
        );

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: ThemeColors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: const [
                BoxShadow(
                  color: ThemeColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            margin:
                EdgeInsets.symmetric(vertical: padding, horizontal: padding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: <Widget>[
                  // Background Image with adjusted height
                  SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.asset(
                      wilaya.image,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient Overlay for better text readability
                  Container(
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

                  // City Name with shadow and enhanced readability
                  Positioned(
                    left: padding,
                    bottom: padding * 1.2,
                    child: Text(
                      wilaya.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: ThemeColors.white,
                        shadows: [
                          Shadow(
                            blurRadius: shadowBlur,
                            color: ThemeColors.black.withOpacity(0.5),
                            offset: const Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Hotel Count Badge (Enhanced UI)
                  Positioned(
                    top: padding,
                    right: padding,
                    child: Container(
                      padding: hotelBadgePadding,
                      decoration: BoxDecoration(
                        gradient: ThemeColors.accentGradient,
                        borderRadius: BorderRadius.circular(borderRadius * 0.5),
                        boxShadow: const [
                          BoxShadow(
                            color: ThemeColors.shadowDark,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.count} Hotels',
                        style: TextStyle(
                          color: ThemeColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: hotelCountFontSize,
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
