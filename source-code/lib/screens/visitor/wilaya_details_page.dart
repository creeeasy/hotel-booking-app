// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/widgets/hotel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WilayaDetailsPageView extends StatefulWidget {
  const WilayaDetailsPageView({super.key});

  @override
  State<WilayaDetailsPageView> createState() => _WilayaDetailsPageViewState();
}

class _WilayaDetailsPageViewState extends State<WilayaDetailsPageView>
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

  Future<List<Hotel>> fetchHotels(BuildContext context) async {
    final wilayaId = ModalRoute.of(context)?.settings.arguments as int;
    return await Hotel.getHotelsByWilaya(wilayaId);
  }

  @override
  Widget build(BuildContext context) {
    final wilayaId = ModalRoute.of(context)?.settings.arguments as int;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentUser = state.currentUser as Visitor;
        final favorites = currentUser.favorites ?? [];
        return SafeArea(
          child: Scaffold(
            backgroundColor: VisitorThemeColors.whiteColor,
            appBar: AppBar(
              leading: IconButton(
                color: VisitorThemeColors.blackColor,
                icon: const Icon(Icons.chevron_left, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: VisitorThemeColors.whiteColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                Wilaya.fromIndex(wilayaId)!.name,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: VisitorThemeColors.blackColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            body: FutureBuilder<List<Hotel>>(
              future: fetchHotels(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          VisitorThemeColors.primaryColor,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hotels found'));
                } else {
                  final hotels = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Text(
                          "Find your perfect hotel in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                            color: VisitorThemeColors.blackColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: hotels.length,
                          itemBuilder: (context, index) {
                            final hotel = hotels[index];
                            final int count =
                                hotels.length > 10 ? 10 : hotels.length;
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
                              isFavorite:
                                  (favorites).contains(favorites[index]),
                              visitorId: currentUser.id,
                              hotelId: hotel.id,
                              animation: animation,
                              animationController: animationController,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
