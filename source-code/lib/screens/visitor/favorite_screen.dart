import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/widgets/hotel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentUser = state.currentUser as Visitor;
        final favorites = currentUser.favorites ?? [];
        return SafeArea(
          child: Scaffold(
            backgroundColor: VisitorThemeColors.whiteColor,
            appBar: AppBar(
              backgroundColor: VisitorThemeColors.whiteColor,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Favorites',
                style: TextStyle(
                  color: VisitorThemeColors.blackColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            body: ListView.builder(
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
                  visitorId: currentUser.id,
                  hotelId: favorites[index],
                  animation: animation,
                  animationController: animationController,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
