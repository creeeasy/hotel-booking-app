import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: CustomBackAppBar(
          title: L10n.of(context).allWilayas,
          onBack: () => Navigator.of(context).pop(),
        ),
        backgroundColor: ThemeColors.background,
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<int, int>>(
                future: HotelService.getHotelStatistics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator(context);
                  } else if (snapshot.hasError) {
                    return ErrorWidgetWithRetry(
                      errorMessage: L10n.of(context).failedToLoadWilayaData,
                      onRetry: () => setState(() {}),
                    );
                  } else if (!snapshot.hasData) {
                    return NoDataWidget(
                      message: L10n.of(context).noHotelsListedInAnyWilaya,
                      // icon: Iconsax.map,
                    );
                  }
                  return _buildWilayaGrid(snapshot.data!, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: ThemeColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          Text(
            L10n.of(context).discoveringAmazingPlaces,
            style: const TextStyle(
              color: ThemeColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWilayaGrid(Map<int, int> hotelStats, BuildContext context) {
    return RefreshIndicator(
      color: ThemeColors.primary,
      onRefresh: () async {
        setState(() {});
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: wilayas.length,
        itemBuilder: (context, index) {
          final wilaya = wilayas[index];
          final hotelCount = hotelStats[wilaya.ind] ?? 0;
          return _buildWilayaCard(wilaya, hotelCount, context);
        },
      ),
    );
  }

  Widget _buildWilayaCard(Wilaya wilaya, int hotelCount, BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToWilayaDetails(wilaya.ind, context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Hero(
                tag: 'wilaya-${wilaya.ind}',
                child: Image.asset(
                  wilaya.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      ThemeColors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wilaya.name,
                      style: TextStyle(
                        color: ThemeColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: ThemeColors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${L10n.of(context).wilaya} ${wilaya.ind}',
                      style: TextStyle(
                        color: ThemeColors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.house_2,
                        size: 14,
                        color: ThemeColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$hotelCount",
                        style: const TextStyle(
                          color: ThemeColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWilayaDetails(int wilayaNumber, BuildContext context) {
    Navigator.pushNamed(
      context,
      wilayaDetailsViewRoute,
      arguments: wilayaNumber,
    );
  }
}