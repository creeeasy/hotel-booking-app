import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/constants/hotel_price_ranges.dart';
import 'package:fatiel/enum/filter_option.dart';
import 'package:fatiel/screens/visitor/widget/range_slider_widget.dart';

class FilterHotelWidget extends StatefulWidget {
  final void Function(FilterOption option, dynamic val) onFilterUpdate;

  const FilterHotelWidget({super.key, required this.onFilterUpdate});

  @override
  State<FilterHotelWidget> createState() => _FilterHotelWidgetState();
}

class _FilterHotelWidgetState extends State<FilterHotelWidget> {
  late Function(FilterOption option, dynamic val) onFilterUpdate;
  int? _selectedPrice;
  int? _selectedLocation;
  RangeValues? _selectedRating;
  RangeValues? _selectedRequiredPeople;
  @override
  void initState() {
    onFilterUpdate = widget.onFilterUpdate;
    super.initState();
  }

  void _resetFilters() async {
    final shouldReset = await showGenericDialog<bool>(
      context: context,
      title: 'Reset Filters',
      content: 'Are you sure you want to reset all filters?',
      optionBuilder: () => {'No': false, 'Yes, Reset': true},
    );

    if (shouldReset != true) return;
    setState(() {
      _selectedPrice = null;
      _selectedRating = null;
      _selectedRequiredPeople = null;
      _selectedLocation = null;
      onFilterUpdate(FilterOption.price, null);
      onFilterUpdate(FilterOption.rating, null);
      onFilterUpdate(FilterOption.minPeople, null);
      onFilterUpdate(FilterOption.location, null);
    });
  }

  void _showFilterOptions(FilterOption filterType) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterTitle(filterType),
                  const SizedBox(height: 16),
                  _buildFilterOptions(filterType, modalSetState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _resetOptionIcon(),
          _filterIcon(
              icon: FontAwesomeIcons.locationDot,
              label: "Location",
              onFilter: () => _showFilterOptions(FilterOption.location)),
          _filterIcon(
              icon: FontAwesomeIcons.dollarSign,
              label: "Price",
              onFilter: () => _showFilterOptions(FilterOption.price)),
          _filterIcon(
              icon: FontAwesomeIcons.star,
              label: "Rating",
              onFilter: () => _showFilterOptions(FilterOption.rating)),
          _filterIcon(
              icon: FontAwesomeIcons.users,
              label: "Guests",
              onFilter: () => _showFilterOptions(FilterOption.minPeople)),
        ],
      ),
    );
  }

  Widget _filterIcon({
    required IconData icon,
    required String label,
    required VoidCallback onFilter,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onFilter,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: VisitorThemeColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                FaIcon(icon, size: 20, color: VisitorThemeColors.primaryColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _resetOptionIcon() {
    return Column(
      children: [
        GestureDetector(
          onTap: _resetFilters,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            child: const FaIcon(FontAwesomeIcons.rotateLeft,
                size: 20, color: VisitorThemeColors.primaryColor),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Reset",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTitle(FilterOption option) {
    final title = switch (option) {
      FilterOption.minPeople => "Minimum Guests",
      FilterOption.price => "Price Range",
      FilterOption.rating => "Customer Rating",
      FilterOption.location => "Location (Wilaya)",
    };

    return Text(
      'Sort by $title',
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: VisitorThemeColors.primaryColor,
      ),
    );
  }

  Widget _buildFilterOptions(FilterOption option, StateSetter modalSetState) {
    switch (option) {
      case FilterOption.rating:
        return RangeSliderWidget<int>(
          rangeValues: const RangeValues(0, 5),
          divisions: 5,
          defaultValues: _selectedRating,
          label: 'Rating',
          onChanged: (val) {
            modalSetState(() {
              _selectedRating = val;
              onFilterUpdate(FilterOption.rating, val);
            });
          },
        );
      case FilterOption.price:
        return _priceRangeOptions(modalSetState);
      case FilterOption.minPeople:
        return RangeSliderWidget<int>(
          defaultValues: _selectedRequiredPeople,
          divisions: 19,
          label: 'Minimum Guests',
          onChanged: (val) {
            modalSetState(() {
              _selectedRequiredPeople = val;
              onFilterUpdate(FilterOption.minPeople, val);
            });
          },
          rangeValues: const RangeValues(1, 20),
        );
      case FilterOption.location:
        return _locationOptions(modalSetState);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _priceRangeOptions(StateSetter modalSetState) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: SingleChildScrollView(
        child: Column(
          children: priceRanges.map((range) {
            return RadioListTile<int?>(
              title: Text(
                range['label'],
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              value: range['min'],
              groupValue: _selectedPrice,
              onChanged: (val) {
                modalSetState(() {
                  _selectedPrice = val;
                  onFilterUpdate(FilterOption.price, val);
                });
              },
              activeColor: VisitorThemeColors.primaryColor,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _locationOptions(StateSetter modalSetState) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: SingleChildScrollView(
        child: Column(
          children: Wilaya.wilayasList.map((location) {
            final title = "${location.name} ${location.ind}";

            return RadioListTile<int?>(
              title: Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              value: location.ind,
              groupValue: _selectedLocation,
              onChanged: (val) {
                modalSetState(() {
                  _selectedLocation = val;
                  onFilterUpdate(FilterOption.location, val);
                });
              },
              activeColor: VisitorThemeColors.primaryColor,
            );
          }).toList(),
        ),
      ),
    );
  }
}
