import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/widgets/hotel_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/screens/hotel_details_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
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
        final currentVisitor = state.currentUser as Visitor;
        final bookings = currentVisitor.bookings ?? [];
        return Scaffold(
          body: ListView.builder(
            itemCount: bookings.length,
            padding: const EdgeInsets.only(top: 8),
            itemBuilder: (context, index) {
              final int count = bookings.length > 10 ? 10 : bookings.length;
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
              return InkWell(
                  onTap: () => {
                        Navigator.pushNamed(context, hotelDetailsRoute,
                            arguments: "dHNQ0AKCIrWeqpKR81Q0fbfORZM2")
                      },
                  child: HotelRowOneWidget(
                    visitorId: currentVisitor.id,
                    hotelId: bookings[index],
                    animation: animation,
                    animationController: animationController,
                    callback: () {},
                  ));
            },
          ),
        );
      },
    );
  }
}
