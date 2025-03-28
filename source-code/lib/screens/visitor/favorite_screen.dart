import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/stream/visitor_favorites_stream.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:fatiel/widgets/hotel_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    VisitorFavoritesStream.listenToFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: const CustomBackAppBar(
        title: "Favorites",
        titleColor: ThemeColors.primary,
        iconColor: ThemeColors.primary,
      ),
      body: _buildFavoriteContent(),
    );
  }

  Widget _buildFavoriteContent() {
    return StreamBuilder<List<String>>(
      stream: VisitorFavoritesStream.favoritesStream,
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Error State
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        // Empty State
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // Content State
        return _buildFavoritesList(snapshot.data!);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicatorWidget(
            indicatorColor: ThemeColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Loading your favorites',
            style: TextStyle(
              color: ThemeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.warning_2,
              size: 48,
              color: ThemeColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Couldn\'t load favorites',
              style: TextStyle(
                fontSize: 18,
                color: ThemeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
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
                Iconsax.heart,
                size: 48,
                color: ThemeColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Favorites Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Save your favorite hotels by tapping the heart icon when browsing",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: ThemeColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, hotelBrowseScreenRoute),
              icon: const Icon(Iconsax.search_normal,
                  size: 20, color: ThemeColors.textOnPrimary),
              label: const Text("Browse Hotels"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<String> favorites) {
    return RefreshIndicator(
      color: ThemeColors.primary,
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: favorites.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return HotelCard(
            hotelId: favorites[index],
            onPressed: () => Navigator.pushNamed(
              context,
              hotelDetailsRoute,
              arguments: favorites[index],
            ),
          );
        },
      ),
    );
  }
}
