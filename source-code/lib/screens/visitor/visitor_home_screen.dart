import 'package:fatiel/screens/visitor/booking_screen.dart';
import 'package:fatiel/screens/visitor/explore_screen.dart';
import 'package:fatiel/screens/visitor/favorite_screen.dart';
import 'package:fatiel/screens/visitor/widget/bottom_navigation_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

import '../../enum/BottomBarType.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  BottomBarType bottomBarType = BottomBarType.Explore;

  void onTabClick(BottomBarType tabType) {
    setState(() {
      bottomBarType = tabType;
    });
  }

  Widget getCurrentPage() {
    switch (bottomBarType) {
      case BottomBarType.Explore:
        return ExploreView();
      case BottomBarType.Booking:
        return const BookingView();
      case BottomBarType.Favorite:
        return const FavoritePage();
      default:
        return ExploreView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: VisitorThemeColors.whiteColor,
        body: getCurrentPage(),
        bottomNavigationBar: CustomBottomNavigationBar(
          bottomBarType: bottomBarType,
          onTabClick: (selectedTab) {
            setState(() {
              bottomBarType = selectedTab;
            });
          },
        ));
  }
}
