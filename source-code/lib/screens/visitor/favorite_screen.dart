import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/screens/empty_states/no_favorites_found_screen.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/stream/visitor_favorites_stream.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:fatiel/widgets/hotel_widget.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    VisitorFavoritesStream.listenToFavorites();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      appBar: const CustomBackAppBar(
          title: "Favorites", titleColor: VisitorThemeColors.vibrantOrange),
      body: SafeArea(
        child: _buildFavoriteHotels(),
      ),
    );
  }

  Widget _buildFavoriteHotels() {
    return StreamBuilder<List<String>>(
      stream: VisitorFavoritesStream.favoritesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicatorWidget(
            indicatorColor: VisitorThemeColors.vibrantOrange,
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const NoFavoritesScreen();
        }

        final List<String> favorites = snapshot.data!;
        return ListView.builder(
          itemCount: favorites.length,
          padding: const EdgeInsets.only(top: 8),
          itemBuilder: (context, index) {
            final int count = favorites.length > 10 ? 10 : favorites.length;
            final Animation<double> animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            animationController.forward();

            return HotelRowOneWidget(
              hotelId: favorites[index],
              animation: animation,
              animationController: animationController,
            );
          },
        );
      },
    );
  }
}
