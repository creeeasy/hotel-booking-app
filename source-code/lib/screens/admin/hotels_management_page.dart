import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';

class HotelsManagementPage extends StatefulWidget {
  const HotelsManagementPage({Key? key}) : super(key: key);

  @override
  State<HotelsManagementPage> createState() => _HotelsManagementPageState();
}

class _HotelsManagementPageState extends State<HotelsManagementPage> {
  List<Hotel> _allHotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoading = true;
  String _searchQuery = '';
  SubscriptionFilter _subscriptionFilter = SubscriptionFilter.all;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() => _isLoading = true);
    try {
      final hotels = await HotelService.getAllHotels();
      setState(() {
        _allHotels = hotels;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('${L10n.of(context).errorLoadingHotels}: $e');
    }
  }

  void _applyFilters() {
    List<Hotel> filtered = List.from(_allHotels);

    // Apply subscription filter
    if (_subscriptionFilter == SubscriptionFilter.subscribed) {
      filtered = filtered.where((hotel) => hotel.isSubscribed).toList();
    } else if (_subscriptionFilter == SubscriptionFilter.unsubscribed) {
      filtered = filtered.where((hotel) => !hotel.isSubscribed).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((hotel) {
        return hotel.hotelName.toLowerCase().contains(query) ||
            hotel.email.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredHotels = filtered);
  }

  Future<void> _toggleSubscriptionStatus(Hotel hotel) async {
    try {
      // Create updated hotel with toggled subscription status
      final updatedHotel = Hotel(
        id: hotel.id,
        email: hotel.email,
        hotelName: hotel.hotelName,
        location: hotel.location,
        ratings: hotel.ratings,
        images: hotel.images,
        totalRooms: hotel.totalRooms,
        description: hotel.description,
        mapLink: hotel.mapLink,
        contactInfo: hotel.contactInfo,
        searchKeywords: hotel.searchKeywords,
        isSubscribed: !hotel.isSubscribed,
      );

      // Update in Firestore
      await HotelService.updateHotel(hotel: updatedHotel);

      // Refresh the list
      await _loadHotels();

      _showSuccessSnackBar(
        updatedHotel.isSubscribed
            ? L10n.of(context).hotelNowSubscribed(hotel.hotelName)
            : L10n.of(context).hotelNowUnsubscribed(hotel.hotelName),
        updatedHotel.isSubscribed ? ThemeColors.success : ThemeColors.warning,
      );
    } catch (e) {
      _showErrorSnackBar('${L10n.of(context).errorUpdatingSubscription}: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: ThemeColors.textOnPrimary),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: CustomBackAppBar(
        title: L10n.of(context).hotelsManagement,
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          _buildFiltersSection(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ThemeColors.primary,
                    ),
                  )
                : _filteredHotels.isEmpty
                    ? _buildEmptyState()
                    : _buildHotelsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: ThemeColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: L10n.of(context).searchByHotelNameOrEmail,
          hintStyle: TextStyle(color: ThemeColors.grey300),
          prefixIcon:
              const Icon(Iconsax.search_normal, color: ThemeColors.white),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Iconsax.close_circle,
                      color: ThemeColors.white),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: ThemeColors.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        style: const TextStyle(color: ThemeColors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _buildFilterChip(
              label: L10n.of(context).allHotels,
              icon: Iconsax.building_4,
              selected: _subscriptionFilter == SubscriptionFilter.all,
              onSelected: (_) {
                setState(() {
                  _subscriptionFilter = SubscriptionFilter.all;
                  _applyFilters();
                });
              },
            ),
            const SizedBox(width: 12.0),
            _buildFilterChip(
              label: L10n.of(context).subscribed,
              icon: Iconsax.verify,
              selected: _subscriptionFilter == SubscriptionFilter.subscribed,
              onSelected: (_) {
                setState(() {
                  _subscriptionFilter = SubscriptionFilter.subscribed;
                  _applyFilters();
                });
              },
            ),
            const SizedBox(width: 12.0),
            _buildFilterChip(
              label: L10n.of(context).unsubscribed,
              icon: Iconsax.pause_circle,
              selected: _subscriptionFilter == SubscriptionFilter.unsubscribed,
              onSelected: (_) {
                setState(() {
                  _subscriptionFilter = SubscriptionFilter.unsubscribed;
                  _applyFilters();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool selected,
    required void Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: selected ? ThemeColors.white : ThemeColors.primary,
          ),
          const SizedBox(width: 6.0),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: ThemeColors.surface,
      selectedColor: ThemeColors.primary,
      checkmarkColor: ThemeColors.white,
      labelStyle: TextStyle(
        color: selected ? ThemeColors.white : ThemeColors.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: BorderSide(
          color: selected ? ThemeColors.primary : ThemeColors.border,
          width: 1.0,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _allHotels.isEmpty ? Iconsax.building : Iconsax.search_normal,
            size: 64.0,
            color: ThemeColors.grey400,
          ),
          const SizedBox(height: 16.0),
          Text(
            _allHotels.isEmpty
                ? L10n.of(context).noHotelsInDatabase
                : L10n.of(context).noHotelsMatchFilters,
            style: TextStyle(
              color: ThemeColors.textSecondary,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          if (_allHotels.isNotEmpty && _searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _subscriptionFilter = SubscriptionFilter.all;
                  _applyFilters();
                });
              },
              icon: const Icon(Iconsax.refresh, size: 18.0),
              label: Text(L10n.of(context).clearFilters),
              style: TextButton.styleFrom(
                foregroundColor: ThemeColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHotelsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredHotels.length,
      itemBuilder: (context, index) {
        final hotel = _filteredHotels[index];
        return _buildHotelCard(hotel);
      },
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: hotel.isSubscribed
              ? ThemeColors.success.withOpacity(0.3)
              : ThemeColors.border,
          width: hotel.isSubscribed ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel thumbnail
            _buildHotelImage(hotel),
            const SizedBox(width: 16.0),
            // Hotel details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name
                  Text(
                    hotel.hotelName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // Hotel email
                  Row(
                    children: [
                      const Icon(Iconsax.message,
                          size: 14.0, color: ThemeColors.textSecondary),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          hotel.email,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: ThemeColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // Hotel location
                  if (hotel.location != null)
                    Row(
                      children: [
                        const Icon(Iconsax.location,
                            size: 14.0, color: ThemeColors.textSecondary),
                        const SizedBox(width: 4.0),
                        Text(
                          '${Wilaya.fromIndex(hotel.location!)?.name ?? L10n.of(context).unknown}',
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: ThemeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8.0),
                  // Bottom row with status and rating
                  Row(
                    children: [
                      // Subscription status tag
                      _buildStatusTag(hotel),
                      const SizedBox(width: 12.0),
                      // Hotel rating if available
                      if (hotel.ratings.totalRating > 0)
                        _buildRatingBadge(hotel),
                    ],
                  ),
                ],
              ),
            ),
            // Toggle subscription button
            _buildSubscriptionToggle(hotel),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage(Hotel hotel) {
    return Hero(
      tag: 'hotel_image_${hotel.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: SizedBox(
          width: 90,
          height: 90,
          child: hotel.images.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: hotel.images.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: ThemeColors.grey200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: ThemeColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: ThemeColors.primaryTransparent,
                    child: const Icon(
                      Iconsax.building_4,
                      size: 40,
                      color: ThemeColors.primary,
                    ),
                  ),
                )
              : Container(
                  color: ThemeColors.primaryTransparent,
                  child: const Icon(
                    Iconsax.building_4,
                    size: 40,
                    color: ThemeColors.primary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(Hotel hotel) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: hotel.isSubscribed
            ? ThemeColors.success.withOpacity(0.2)
            : ThemeColors.warning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: hotel.isSubscribed ? ThemeColors.success : ThemeColors.warning,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hotel.isSubscribed ? Iconsax.tick_circle : Iconsax.pause_circle,
            size: 14.0,
            color:
                hotel.isSubscribed ? ThemeColors.success : ThemeColors.warning,
          ),
          const SizedBox(width: 4.0),
          Text(
            hotel.isSubscribed
                ? L10n.of(context).subscribed
                : L10n.of(context).inactive,
            style: TextStyle(
              color: hotel.isSubscribed
                  ? ThemeColors.success
                  : ThemeColors.warning,
              fontWeight: FontWeight.w500,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(Hotel hotel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Iconsax.star1,
          size: 16.0,
          color: Color(0xFFFFB300),
        ),
        const SizedBox(width: 4.0),
        Text(
          L10n.of(context).ratingValue(hotel.ratings.rating.toStringAsFixed(1),
              hotel.ratings.totalRating.toString()),
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionToggle(Hotel hotel) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleSubscriptionStatus(hotel),
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hotel.isSubscribed ? Iconsax.close_circle : Iconsax.tick_circle,
                size: 26.0,
                color: hotel.isSubscribed
                    ? ThemeColors.error
                    : ThemeColors.success,
              ),
              const SizedBox(height: 4.0),
              Text(
                hotel.isSubscribed
                    ? L10n.of(context).unsubscribe
                    : L10n.of(context).subscribe,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: hotel.isSubscribed
                      ? ThemeColors.error
                      : ThemeColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SubscriptionFilter {
  all,
  subscribed,
  unsubscribed,
}
