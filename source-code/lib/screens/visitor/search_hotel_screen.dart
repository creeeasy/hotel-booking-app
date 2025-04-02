import 'package:fatiel/l10n/l10n.dart';
import 'dart:async';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/visitor/widget/hotels_list_widget.dart';
import 'package:fatiel/screens/empty_states/no_hotels_found_screen.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';

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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          _searchResults =
              HotelService.findHotelsByKeyword(_searchController.text);
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: CustomBackAppBar(
          title: L10n.of(context).searchHotels,
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ThemeColors.textPrimary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: ThemeColors.white,
          hintText: L10n.of(context).searchHotelsLocations,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: ThemeColors.textSecondary,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: ThemeColors.primary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Iconsax.close_circle,
                    color: ThemeColors.primary,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: ThemeColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        cursorColor: ThemeColors.primary,
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
              child: CircularProgressIndicatorWidget(),
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
            size: 64,
            color: ThemeColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            L10n.of(context).searchForHotels,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              L10n.of(context).enterHotelNameLocation,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
            color: ThemeColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.of(context).searchFailed,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchResults =
                    HotelService.findHotelsByKeyword(_searchController.text);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
            child: Text(
              L10n.of(context).tryAgain,
              style: const TextStyle(
                color: ThemeColors.textOnPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
