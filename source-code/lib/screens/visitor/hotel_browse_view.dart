// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/enum/filter_option.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
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

  Widget _buildSortTitle(FilterOption _option) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0), // Add vertical padding for spacing
      child: Text(
        'Sort by ${_option.name}',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20, // Increased font size for better readability
          fontWeight:
              FontWeight.w600, // Slightly lighter than bold for a modern feel
          color: VisitorThemeColors.primaryColor,
          letterSpacing:
              0.5, // Add some letter spacing for better text legibility
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black.withOpacity(0.2), // Subtle shadow for depth
              offset: Offset(0.0, 1.0), // Shadow slightly offset
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptions(FilterOption _option) {
    switch (_option) {
      case FilterOption.rating:
        return Text(
          'Sort by ${_option.displayName}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20, // Adjust font size as needed
            fontWeight: FontWeight.w600,
            color: VisitorThemeColors.primaryColor,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0.0, 1.0),
              ),
            ],
          ),
        );

      case FilterOption.price:
        return Text(
          'Sort by ${_option.displayName}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: VisitorThemeColors.primaryColor,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0.0, 1.0),
              ),
            ],
          ),
        );

      case FilterOption.minPeople:
        return Text(
          'Sort by ${_option.displayName}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: VisitorThemeColors.primaryColor,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0.0, 1.0),
              ),
            ],
          ),
        );

      default:
        return SizedBox
            .shrink(); // Return an empty widget for unexpected options
    }
  }
}
