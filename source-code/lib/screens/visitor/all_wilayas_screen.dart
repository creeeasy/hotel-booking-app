import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AllWilayaScreen extends StatefulWidget {
  const AllWilayaScreen({super.key});

  @override
  State<AllWilayaScreen> createState() => _AllWilayaScreenState();
}

class _AllWilayaScreenState extends State<AllWilayaScreen> {
  late List<Wilaya> wilayas;

  @override
  void initState() {
    super.initState();
    wilayas = Wilaya.values;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBackAppBar(
        title: "All Wilayas",
        titleColor: VisitorThemeColors.playfulLime,
        iconColor: VisitorThemeColors.playfulLime,
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<Map<int, int>>(
        future: Hotel.getHotelStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicatorWidget(
              indicatorColor:
                  VisitorThemeColors.deepBlueAccent.withOpacity(0.8),
              containerColor: VisitorThemeColors.whiteColor,
            );
          } else if (snapshot.hasError) {
            return ErrorWidgetWithRetry(
                errorMessage: 'Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const NoDataWidget(
                message: "No hotels are currently listed in this wilaya.");
          }
          final hotels = snapshot.data;
          return AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: wilayas.length,
              itemBuilder: (context, index) {
                final wilaya = WilayaModel(
                  number: wilayas[index].ind,
                  name: wilayas[index].name,
                );
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            wilayaDetailsViewRoute,
                            arguments: wilaya.number,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(
                                  wilaya.getImage()), // Correct usage
                              fit: BoxFit
                                  .cover, // Ensures the image covers the container
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Text(
                                  wilaya.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${hotels?[wilaya.number] ?? 0} Hotels",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
