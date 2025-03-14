// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/filter_option.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/range_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilterNotifier extends ValueNotifier<bool> {
  FilterNotifier() : super(false);

  void refresh() {
    value = !value;
  }
}

final filterNotifier = FilterNotifier();

class HotelBrowseView extends StatefulWidget {
  const HotelBrowseView({super.key});

  @override
  State<HotelBrowseView> createState() => _HotelBrowseViewState();
}

class _HotelBrowseViewState extends State<HotelBrowseView> {
  void showSortOptions(FilterOption filterType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSortTitle(filterType),
              const SizedBox(height: 16),
              _buildSortOptions(filterType)
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorThemeColors.whiteColor,
      appBar: CustomBackAppBar(
        title: "All Hotels",
        iconColor: VisitorThemeColors.primaryColor,
        titleColor: VisitorThemeColors.primaryColor,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _iconButton(
                  icon: FontAwesomeIcons.dollarSign,
                  onSort: () => showSortOptions(FilterOption.price)),
              const SizedBox(width: 8), // Add spacing between the icons
              _iconButton(
                  icon: FontAwesomeIcons.star,
                  onSort: () => showSortOptions(FilterOption.rating)),
              const SizedBox(width: 8), // Add spacing between the icons
              _iconButton(
                  icon: FontAwesomeIcons.users,
                  onSort: () => showSortOptions(FilterOption.minPeople)),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onSort}) {
    return MaterialButton(
      onPressed: onSort,
      padding: EdgeInsets.zero, // Remove default padding
      child: Container(
        padding: const EdgeInsets.all(8.0), // Custom padding for the icon
        decoration: BoxDecoration(
          color: VisitorThemeColors.primaryColor
              .withOpacity(0.1), // Light background color with opacity
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: FaIcon(
          icon,
          size: 20, // Adjusted icon size for better visibility
          color: VisitorThemeColors.primaryColor, // Icon color from theme
        ),
      ),
    );
  }

  Widget _buildSortTitle(FilterOption option) {
    final title = switch (option) {
      FilterOption.minPeople => "Minimum People Required",
      FilterOption.price => "Price Range",
      FilterOption.rating => "Customer Rating",
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Sort by $title',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: VisitorThemeColors.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSortOptions(FilterOption option) {
    switch (option) {
      case FilterOption.rating:
        return RangeSliderWidget<int>(
          minValue: 0,
          maxValue: 5,
          divisions: 5,
          label: 'Rating',
          onChanged: (val) => print("Rating filter set to: $val"),
        );

      case FilterOption.price:
        return RangeSliderWidget<int>(
          minValue: 0,
          maxValue: 1000,
          divisions: 20,
          label: 'Price',
          onChanged: (val) => print("Price filter set to: $val"),
        );

      case FilterOption.minPeople:
        return RangeSliderWidget<int>(
          minValue: 1,
          maxValue: 20,
          divisions: 19,
          label: 'Minimum People',
          onChanged: (val) => print("Minimum people filter set to: $val"),
        );

      default:
        return const SizedBox.shrink(); // Handles unexpected cases
    }
  }
}
