import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:fatiel/widgets/hotel_widget.dart';
import 'package:flutter/material.dart';

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

  Future<List<Hotel>> fetchHotels(BuildContext context, int wilayaId) async {
    return Hotel.getHotelsByWilaya(wilayaId);
  }

  @override
  Widget build(BuildContext context) {
    final wilayaId = ModalRoute.of(context)?.settings.arguments as int;

    return SafeArea(
      child: Scaffold(
        backgroundColor: VisitorThemeColors.whiteColor,
        appBar: AppBar(
          backgroundColor: VisitorThemeColors.whiteColor,
          elevation: 0,
          leading: IconButton(
            color: VisitorThemeColors.blackColor,
            icon: const Icon(
              Icons.chevron_left,
              size: 32, // Matching Visitor screen
            ),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
          ),
          centerTitle: true,
          title: Text(
            Wilaya.fromIndex(wilayaId)!.name,
            style: TextStyle(
              color: VisitorThemeColors.blackColor,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: FutureBuilder<List<Hotel>>(
          future: fetchHotels(context, wilayaId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicatorWidget(
                indicatorColor:
                    VisitorThemeColors.deepPurpleAccent.withOpacity(0.8),
                containerColor: VisitorThemeColors.whiteColor,
              );
            } else if (snapshot.hasError) {
              return ErrorWidgetWithRetry(
                errorMessage: 'Error: ${snapshot.error}',
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return NoDataWidget(
                message: "No hotels are currently listed in this wilaya.",
              );
            }

            final hotels = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    "Find your perfect hotel in ${Wilaya.fromIndex(wilayaId)!.name}",
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
                    padding: const EdgeInsets.all(16),
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      final count = hotels.length > 10 ? 10 : hotels.length;
                      final animation = Tween<double>(
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
                        hotelId: hotel.id,
                        animation: animation,
                        animationController: animationController,
                      );
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
}
