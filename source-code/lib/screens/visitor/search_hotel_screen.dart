import 'package:fatiel/screens/visitor/widget/hotels_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/empty_states/no_hotels_found_screen.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class SearchHotelView extends StatefulWidget {
  const SearchHotelView({super.key});

  @override
  State<SearchHotelView> createState() => _SearchHotelViewState();
}

class _SearchHotelViewState extends State<SearchHotelView> {
  Future<List<Hotel>>? _searchResults;
  final TextEditingController _searchController = TextEditingController();
  void _onSearchChanged() {
    setState(() {
      _searchResults = Hotel.findHotelsByKeyword(_searchController.text);
    });
  }

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);

    super.initState();
  }

  @override
  void dispose() {
    _searchController.addListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: VisitorThemeColors.whiteColor,
        appBar: CustomBackAppBar(
          title: "Search for a hotel",
          iconColor: VisitorThemeColors.cancelTextColor,
          titleColor: VisitorThemeColors.cancelTextColor,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: VisitorThemeColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search hotels, locations...",
                  hintStyle: TextStyle(fontFamily: 'Poppins'),
                  prefixIcon: Icon(Icons.search,
                      color: VisitorThemeColors.cancelTextColor),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Hotel>>(
                future: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicatorWidget(
                        indicatorColor: VisitorThemeColors.cancelTextColor,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
