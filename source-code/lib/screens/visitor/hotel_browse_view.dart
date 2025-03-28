import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/screens/visitor/widget/hotels_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/filter_option.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/empty_states/no_hotels_found_screen.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/filter_hotels_widget.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';

class HotelBrowseView extends StatefulWidget {
  final Future<List<Hotel>> Function(HotelFilterParameters params)?
      filterFunction;
  const HotelBrowseView({super.key, this.filterFunction});
  @override
  State<HotelBrowseView> createState() => _HotelBrowseViewState();
}

class _HotelBrowseViewState extends State<HotelBrowseView>
    with SingleTickerProviderStateMixin {
  int? _selectedPriceRange;
  int? _selectedLocation;
  RangeValues? _selectedRatingRange;
  RangeValues? _selectedPeopleRange;
  late Function fetchFilteredHotels;
  @override
  void initState() {
    fetchFilteredHotels = widget.filterFunction ??
        (HotelFilterParameters params) {
          return Hotel.filterHotels(params: params);
        };
    super.initState();
  }

  void _updateFilter(FilterOption option, dynamic value) {
    setState(() {
      switch (option) {
        case FilterOption.rating:
          _selectedRatingRange = value;
          break;
        case FilterOption.minPeople:
          _selectedPeopleRange = value;
          break;
        case FilterOption.price:
          _selectedPriceRange = value;
          break;
        case FilterOption.location:
          _selectedLocation = value;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: VisitorThemeColors.whiteColor,
        appBar: CustomBackAppBar(
          title: "All Hotels",
          iconColor: VisitorThemeColors.primaryColor,
          titleColor: VisitorThemeColors.primaryColor,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Column(
          children: [
            FilterHotelWidget(onFilterUpdate: _updateFilter),
            Expanded(
              child: FutureBuilder<List<Hotel>>(
                future: fetchFilteredHotels(HotelFilterParameters(
                  minRating: _selectedRatingRange?.start.toInt(),
                  maxRating: _selectedRatingRange?.end.toInt(),
                  minPrice: _selectedPriceRange,
                  minPeople: _selectedPeopleRange?.start.toInt(),
                  maxPeople: _selectedPeopleRange?.end.toInt(),
                  location: _selectedLocation,
                )),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicatorWidget(
                      indicatorColor: VisitorThemeColors.vibrantOrange,
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const NoHotelsFoundScreen();
                  }

                  final hotels = snapshot.data!;

                  return HotelsListWidget(
                    hotels: hotels,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
