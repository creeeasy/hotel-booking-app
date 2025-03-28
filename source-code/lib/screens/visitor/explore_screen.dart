import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
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
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:fatiel/widgets/hotel/explore_city_item_widget.dart';
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentVisitor = state.currentUser as Visitor;
        return Scaffold(
          backgroundColor: VisitorThemeColors.whiteColor,
          body: RefreshIndicator(
            onRefresh: () async => setState(() {}),
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
    );
  }

  SliverPadding _buildAppBarSection(Visitor visitor) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Iconsax.search_normal,
                  color: VisitorThemeColors.primaryColor, size: 24),
              onPressed: () =>
                  Navigator.pushNamed(context, searchHotelViewRoute),
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
            const SizedBox(height: 20),
            FutureBuilder<List<Hotel>>(
              future: _getHotelsBasedOnTab(location),
              builder: (context, snapshot) {
                final hotelsCount = snapshot.data?.length ?? 0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _sectionHeader(
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
        color: VisitorThemeColors.lightGrayColor.withOpacity(0.1),
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? VisitorThemeColors.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tab == HotelListType.recommended
                        ? 'Recommended'
                        : 'Near Me',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : VisitorThemeColors.textGreyColor,
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
        backgroundColor: VisitorThemeColors.whiteColor,
      );
    } else if (snapshot.hasError) {
      return ErrorWidgetWithRetry(
        errorMessage: 'Failed to load hotels',
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Iconsax.house,
            size: 72,
            color: VisitorThemeColors.greyColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Hotels Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: VisitorThemeColors.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We couldn't find any hotels matching your criteria.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: VisitorThemeColors.textGreyColor,
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
            _sectionHeader(
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
                    backgroundColor: VisitorThemeColors.whiteColor,
                  );
                } else if (snapshot.hasError) {
                  return ErrorWidgetWithRetry(
                    errorMessage: 'Failed to load city data',
                    onRetry: () => setState(() {}),
                  );
                } else if (snapshot.hasData) {
                  return _buildCitiesCarousel(snapshot.data!);
                } else {
                  return const NoDataWidget(
                    message: "No hotels are currently listed in these cities.",
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

class _sectionHeader extends StatelessWidget {
  final VoidCallback onSeeAllTap;
  final String title;

  const _sectionHeader({
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: VisitorThemeColors.blackColor,
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
                  color: VisitorThemeColors.primaryColor,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: VisitorThemeColors.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
