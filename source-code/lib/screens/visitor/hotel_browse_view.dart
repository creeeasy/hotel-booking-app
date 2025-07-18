import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/hotel_price_ranges.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/hotels_list_widget.dart';
import 'package:fatiel/screens/visitor/widget/range_slider_widget.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/enum/filter_option.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/screens/empty_states/no_hotels_found_screen.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:iconsax/iconsax.dart';

class HotelBrowseView extends StatefulWidget {
  final Future<List<Hotel>> Function(HotelFilterParameters params)?
      filterFunction;
  final HotelFilterParameters? initialFilters;
  final bool useUserLocationOnly;
  final String? appBarTitle;

  const HotelBrowseView(
      {super.key,
      this.filterFunction,
      this.initialFilters,
      this.useUserLocationOnly = false,
      this.appBarTitle});

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
  late bool useUserLocationOnly;

  @override
  void initState() {
    useUserLocationOnly = widget.useUserLocationOnly;
    if (widget.initialFilters != null) {
      _selectedPriceRange = widget.initialFilters!.minPrice;
      // Only set location if we're not using user location only
      if (!useUserLocationOnly) {
        _selectedLocation = widget.initialFilters!.location;
      }
      if (widget.initialFilters!.minRating != null &&
          widget.initialFilters!.maxRating != null) {
        _selectedRatingRange = RangeValues(
          widget.initialFilters!.minRating!.toDouble(),
          widget.initialFilters!.maxRating!.toDouble(),
        );
      }
      if (widget.initialFilters!.minPeople != null &&
          widget.initialFilters!.maxPeople != null) {
        _selectedPeopleRange = RangeValues(
          widget.initialFilters!.minPeople!.toDouble(),
          widget.initialFilters!.maxPeople!.toDouble(),
        );
      }
    }

    fetchFilteredHotels = widget.filterFunction ??
        (HotelFilterParameters params) {
          return HotelService.getAllHotels(params: params, isAdmin: false);
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
          if (!useUserLocationOnly) {
            _selectedLocation = value;
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: CustomBackAppBar(
          title: widget.appBarTitle ?? L10n.of(context).allHotels,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Column(
          children: [
            FilterHotelWidget(
              onFilterUpdate: _updateFilter,
              initialFilters: widget.initialFilters,
              showLocationFilter: !useUserLocationOnly, // Pass this flag
            ),
            Expanded(
              child: FutureBuilder<List<Hotel>>(
                future: fetchFilteredHotels(HotelFilterParameters(
                  minRating: _selectedRatingRange?.start.toInt(),
                  maxRating: _selectedRatingRange?.end.toInt(),
                  minPrice: _selectedPriceRange,
                  minPeople: _selectedPeopleRange?.start.toInt(),
                  maxPeople: _selectedPeopleRange?.end.toInt(),
                  location: useUserLocationOnly
                      ? widget.initialFilters
                          ?.location // Use initial location if set
                      : _selectedLocation,
                )),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicatorWidget();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: ThemeColors.error),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const NoHotelsFoundScreen();
                  }

                  final hotels = snapshot.data!;
                  return HotelsListWidget(hotels: hotels);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterHotelWidget extends StatefulWidget {
  final void Function(FilterOption option, dynamic val) onFilterUpdate;
  final HotelFilterParameters? initialFilters;
  final bool showLocationFilter; // New parameter

  const FilterHotelWidget({
    super.key,
    required this.onFilterUpdate,
    this.initialFilters,
    this.showLocationFilter = true, // Default to showing location filter
  });

  @override
  State<FilterHotelWidget> createState() => _FilterHotelWidgetState();
}

class _FilterHotelWidgetState extends State<FilterHotelWidget> {
  late Function(FilterOption option, dynamic val) onFilterUpdate;
  int? _selectedPrice;
  int? _selectedLocation;
  RangeValues? _selectedRating;
  RangeValues? _selectedRequiredPeople;
  late bool showLocationFilter;

  @override
  void initState() {
    onFilterUpdate = widget.onFilterUpdate;
    showLocationFilter = widget.showLocationFilter;

    // Initialize with initial filter values if provided
    if (widget.initialFilters != null) {
      _selectedPrice = widget.initialFilters!.minPrice;
      if (showLocationFilter) {
        _selectedLocation = widget.initialFilters!.location;
      }
      if (widget.initialFilters!.minRating != null &&
          widget.initialFilters!.maxRating != null) {
        _selectedRating = RangeValues(
          widget.initialFilters!.minRating!.toDouble(),
          widget.initialFilters!.maxRating!.toDouble(),
        );
      }
      if (widget.initialFilters!.minPeople != null &&
          widget.initialFilters!.maxPeople != null) {
        _selectedRequiredPeople = RangeValues(
          widget.initialFilters!.minPeople!.toDouble(),
          widget.initialFilters!.maxPeople!.toDouble(),
        );
      }

      // Notify parent about initial values
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedPrice != null) {
          onFilterUpdate(FilterOption.price, _selectedPrice);
        }
        if (showLocationFilter && _selectedLocation != null) {
          onFilterUpdate(FilterOption.location, _selectedLocation);
        }
        if (_selectedRating != null) {
          onFilterUpdate(FilterOption.rating, _selectedRating);
        }
        if (_selectedRequiredPeople != null) {
          onFilterUpdate(FilterOption.minPeople, _selectedRequiredPeople);
        }
      });
    }

    super.initState();
  }

  void _resetFilters() async {
    final shouldReset = await showGenericDialog<bool>(
      context: context,
      title: L10n.of(context).resetFiltersTitle,
      content: L10n.of(context).resetFiltersContent,
      optionBuilder: () => {
        L10n.of(context).resetFiltersCancel: false,
        L10n.of(context).resetFiltersConfirm: true
      },
    );
    if (shouldReset != true) return;
    setState(() {
      _selectedPrice = null;
      _selectedRating = null;
      _selectedRequiredPeople = null;
      if (showLocationFilter) {
        _selectedLocation = null;
      }
      onFilterUpdate(FilterOption.price, null);
      onFilterUpdate(FilterOption.rating, null);
      onFilterUpdate(FilterOption.minPeople, null);
      if (showLocationFilter) {
        onFilterUpdate(FilterOption.location, null);
      }
    });
  }

  void _showFilterOptions(FilterOption filterType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ), // <-- Corrected placement of the closing parenthesis
      builder: (BuildContext context) {
        // <-- Fixed function definition
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
                  const SizedBox(height: 16),
                  _buildApplyButton(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          L10n.of(context).applyFilters,
          style: const TextStyle(
            color: ThemeColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
          const SizedBox(width: 8),
          if (showLocationFilter) ...[
            _filterIcon(
                icon: Iconsax.location,
                label: L10n.of(context).filterLocation,
                onFilter: () => _showFilterOptions(FilterOption.location)),
            const SizedBox(width: 8),
          ],
          _filterIcon(
              icon: Iconsax.dollar_circle,
              label: L10n.of(context).filterPrice,
              onFilter: () => _showFilterOptions(FilterOption.price)),
          const SizedBox(width: 8),
          _filterIcon(
              icon: Iconsax.star1,
              label: L10n.of(context).filterRating,
              onFilter: () => _showFilterOptions(FilterOption.rating)),
          const SizedBox(width: 8),
          _filterIcon(
              icon: Iconsax.profile_2user,
              label: L10n.of(context).filterMinPeople,
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
            decoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: ThemeColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ThemeColors.textPrimary,
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
            decoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.refresh,
                size: 20, color: ThemeColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          L10n.of(context).reset,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTitle(FilterOption option) {
    final title = switch (option) {
      FilterOption.minPeople => L10n.of(context).filterByMinGuests,
      FilterOption.price => L10n.of(context).filterByPriceRange,
      FilterOption.rating => L10n.of(context).filterByCustomerRating,
      FilterOption.location => L10n.of(context).filterByLocation,
    };

    return Text(
      'Filter by $title',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ThemeColors.primary,
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
          label: L10n.of(context).filterRating,
          activeColor: ThemeColors.primary,
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
          label: L10n.of(context).filterMinPeople,
          activeColor: ThemeColors.primary,
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.textPrimary,
                ),
              ),
              value: range['min'],
              groupValue: _selectedPrice,
              onChanged: (val) {
                modalSetState(() {
                  _selectedPrice = val;
                  onFilterUpdate(FilterOption.price, val);
                });
              },
              activeColor: ThemeColors.primary,
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.textPrimary,
                ),
              ),
              value: location.ind,
              groupValue: _selectedLocation,
              onChanged: (val) {
                modalSetState(() {
                  _selectedLocation = val;
                  onFilterUpdate(FilterOption.location, val);
                });
              },
              activeColor: ThemeColors.primary,
            );
          }).toList(),
        ),
      ),
    );
  }
}
