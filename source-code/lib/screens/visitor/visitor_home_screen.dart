import 'package:fatiel/screens/visitor/explore_screen.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

enum BottomBarType { Explore, Booking, Favorite }

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
        return const BookingPage();
      case BottomBarType.Favorite:
        return const FavoritePage();
      default:
        return ExploreView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventLogOut());
          },
        ),
        title: const Text(
          "Discover & Plan",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: VisitorThemeColors.secondaryColor,
      ),
      body: getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: BottomBarType.values.indexOf(bottomBarType),
        onTap: (index) => onTabClick(BottomBarType.values[index]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
        ],
        selectedItemColor: VisitorThemeColors.primaryColor,
        unselectedItemColor: VisitorThemeColors.blackColor,
        showUnselectedLabels: true,
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Your Journeys, Your Memories",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: VisitorThemeColors.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Personalize Your Experience",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: VisitorThemeColors.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
