import 'dart:async';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/visitor/widget/hotels_list_widget.dart';
import 'package:fatiel/screens/empty_states/no_hotels_found_screen.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';

class SearchHotelView extends StatefulWidget {
  const SearchHotelView({super.key});

  @override
  State<SearchHotelView> createState() => _SearchHotelViewState();
}

class _SearchHotelViewState extends State<SearchHotelView> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Hotel>>? _searchResults;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many requests
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          _searchResults = Hotel.findHotelsByKeyword(_searchController.text);
        });
      } else {
        setState(() {
          _searchResults = null;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      appBar: CustomBackAppBar(
        title: "Search Hotels",
        iconColor: VisitorThemeColors.cancelTextColor,
        titleColor: VisitorThemeColors.cancelTextColor,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 16),
            // Search Results
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: VisitorThemeColors.lightGrayColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: VisitorThemeColors.blackColor,
        ),
        decoration: InputDecoration(
          hintText: "Search hotels, locations...",
          hintStyle: TextStyle(
            fontSize: 14,
            color: VisitorThemeColors.textGreyColor.withOpacity(0.7),
          ),
          prefixIcon: const Icon(
            Iconsax.search_normal,
            color: VisitorThemeColors.cancelTextColor,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Iconsax.close_circle,
                    color: VisitorThemeColors.cancelTextColor,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        cursorColor: VisitorThemeColors.primaryColor,
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: FutureBuilder<List<Hotel>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (_searchController.text.isEmpty) {
            return _buildInitialState();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicatorWidget(
                indicatorColor: VisitorThemeColors.primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoHotelsFoundScreen();
          }

          return HotelsListWidget(hotels: snapshot.data!);
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.search_normal_1,
            size: 48,
            color: VisitorThemeColors.lightGrayColor,
          ),
          const SizedBox(height: 16),
          Text(
            "Search for hotels",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: VisitorThemeColors.textGreyColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter hotel name, location or amenities",
            style: TextStyle(
              fontSize: 14,
              color: VisitorThemeColors.textGreyColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Iconsax.warning_2,
            size: 48,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Text(
            "Search failed",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: VisitorThemeColors.textGreyColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: VisitorThemeColors.textGreyColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchResults =
                    Hotel.findHotelsByKeyword(_searchController.text);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VisitorThemeColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Try Again",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
