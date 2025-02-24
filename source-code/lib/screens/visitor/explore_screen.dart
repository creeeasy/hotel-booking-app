// ignore_for_file: prefer_const_constructors
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/screens/visitor/widget/hotels_section_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/widgets/card_loading_indocator_widget.dart';
import 'package:fatiel/widgets/hotel/explore_city_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final wilayasList = Wilaya.wilayasList;

class ExploreView extends StatefulWidget {
  @override
  _ExploreViewState createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentVisitor = state.currentUser as Visitor;
        return Scaffold(
          backgroundColor: VisitorThemeColors.whiteColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: const NetworkImage(
                            "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${currentVisitor.firstName} ${currentVisitor.lastName}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.search,
                          color: VisitorThemeColors.primaryColor, size: 28),
                      onPressed: () {
                        Navigator.pushNamed(context, searchHotelViewRoute);
                      },
                      tooltip: 'Search',
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ExploreSectionWidget(
                  location: currentVisitor.location,
                ),
                SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    "Find hotels in cities. ",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.5,
                      color: VisitorThemeColors.primaryColor,
                    ),
                  ),
                ),
                FutureBuilder<Map<int, int>>(
                  future: Hotel.getHotelStatistics(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CardLoadingIndicator(
                        backgroundColor: VisitorThemeColors.whiteColor,
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final hotelStats = snapshot.data!;
                      return CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          height: 130,
                          viewportFraction: 0.45, // Adjust for better spacing
                          enlargeCenterPage: true,
                          pauseAutoPlayOnTouch: true,
                          autoPlayCurve: Curves.easeInOut,
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                        ),
                        items: wilayasList.map((wilaya) {
                          final hotelsCount = hotelStats[wilaya.ind] ?? 0;
                          return ExploreCityWidget(
                            wilaya: wilaya,
                            count: hotelsCount,
                            onTap: () => Navigator.pushNamed(
                                context, wilayaDetailsViewRoute,
                                arguments: wilaya.ind),
                          );
                        }).toList(),
                      );
                    } else {
                      return const Text('No data available');
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
/*
 final shouldLogout = await showGenericDialog<bool>(
                          context: context,
                          title: 'Log out',
                          content: 'Are you sure you want to log out?',
                          optionBuilder: () =>
                              {'Cancel': false, 'Log Out': true},
                        ).then((value) => value ?? false);

                        if (shouldLogout) {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        }
 */