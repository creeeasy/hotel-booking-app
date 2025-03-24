// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/screens/empty_states/no_bookings_found_screen.dart';
import 'package:fatiel/screens/visitor/widget/booking_widget.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/stream/visitor_bookings_stream.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late BookingStatus _selectedTab;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _selectedTab = BookingStatus.pending;
    VisitorBookingsStream.listenToBookings(_selectedTab);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabChange(BookingStatus newTab) {
    if (_selectedTab == newTab) return;

    setState(() {
      _selectedTab = newTab;
      VisitorBookingsStream.listenToBookings(newTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomBackAppBar(
          title: "Bookings",
          titleColor: VisitorThemeColors.vibrantOrange,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final visitorId = (state.currentUser as Visitor).id;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabView(),
                Expanded(
                  child: FutureBuilder<List<Booking>>(
                    future: Booking.getBookingsByUser(visitorId, _selectedTab),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicatorWidget(
                          indicatorColor: VisitorThemeColors.vibrantOrange,
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString());
                      }

                      final bookings = snapshot.data ?? [];
                      return bookings.isEmpty
                          ? NoBookingsWidget()
                          : _buildBookingsList(bookings);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: _tabView(selectedTab: _selectedTab, onTabChange: _onTabChange),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    final itemCount = bookings.length.clamp(1, 10);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      color: VisitorThemeColors.whiteColor,
      child: ListView.separated(
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DividerWidget(),
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final animation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (1 / itemCount) * index,
                1.0,
                curve: Curves.fastOutSlowIn,
              ),
            ),
          );

          return FadeTransition(
            opacity: animation,
            child: BookingWidget(
              bookingId: bookings[index].id,
              onAction: () => setState(() {}),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(child: Text("Error: $error"));
  }
}

Widget _tabView({
  required BookingStatus selectedTab,
  required Function(BookingStatus) onTabChange,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double totalWidth = 0;
      final List<Widget> tabItems = [
        _buildTabItem(
          title: 'Pending',
          isSelected: selectedTab == BookingStatus.pending,
          onTap: () => onTabChange(BookingStatus.pending),
        ),
        _buildTabItem(
          title: 'Completed',
          isSelected: selectedTab == BookingStatus.completed,
          onTap: () => onTabChange(BookingStatus.completed),
        ),
        _buildTabItem(
          title: 'Cancelled',
          isSelected: selectedTab == BookingStatus.cancelled,
          onTap: () => onTabChange(BookingStatus.cancelled),
        ),
      ];

      bool isScrollable = totalWidth > constraints.maxWidth;

      return Column(
        children: <Widget>[
          if (isScrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: tabItems
                      .map((e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: e,
                          ))
                      .toList()),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tabItems,
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      );
    },
  );
}

Widget _buildTabItem({
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color:
            isSelected ? VisitorThemeColors.secondaryColor : Colors.transparent,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 14.0,
          color: isSelected
              ? VisitorThemeColors.whiteColor
              : VisitorThemeColors.greyColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
  );
}
