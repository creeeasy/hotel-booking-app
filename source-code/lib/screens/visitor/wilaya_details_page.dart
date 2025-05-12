import 'package:cached_network_image/cached_network_image.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';

class WilayaDetailsPageView extends StatefulWidget {
  const WilayaDetailsPageView({super.key});

  @override
  State<WilayaDetailsPageView> createState() => _WilayaDetailsPageViewState();
}

class _WilayaDetailsPageViewState extends State<WilayaDetailsPageView> {
  late Future<List<Hotel>> _hotelsFuture;
  int? _wilayaId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _hotelsFuture = Future.value([]);
  }

  void initializeWilayaId(BuildContext context) {
    if (_wilayaId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        _wilayaId = args is int ? args : -1;
        if (_wilayaId != -1) {
          _hotelsFuture =
              HotelService.getHotelsByWilaya(_wilayaId!, isAdmin: false);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wilayaId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _wilayaId = args is int ? args : -1;

      if (_wilayaId != -1) {
        setState(() {
          _hotelsFuture =
              HotelService.getHotelsByWilaya(_wilayaId!, isAdmin: false);
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (_wilayaId == null || _wilayaId == -1) return;
    setState(() {
      _hotelsFuture =
          HotelService.getHotelsByWilaya(_wilayaId!, isAdmin: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_wilayaId == null) return const SafeArea(child: SizedBox.shrink());

    if (_wilayaId == -1) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Text(
              L10n.of(context).wilayaNotFound,
              style: const TextStyle(
                color: ThemeColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    final wilaya = Wilaya.fromIndex(_wilayaId!);
    if (wilaya == null) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Text(
              L10n.of(context).wilayaDataNotAvailable,
              style: const TextStyle(
                color: ThemeColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        extendBodyBehindAppBar: true,
        appBar: CustomBackAppBar(
          title: wilaya.name,
          onBack: () => Navigator.pop(context),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: ThemeColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeroAppBar(wilaya),
              _buildContentSection(wilaya),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildHeroAppBar(Wilaya wilaya) {
    return SliverAppBar(
      backgroundColor: ThemeColors.primary.withOpacity(0.16),
      automaticallyImplyLeading: false,
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      stretchTriggerOffset: 150,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [StretchMode.zoomBackground],
        background: Hero(
          tag: 'wilaya-${wilaya.ind}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  ThemeColors.primary.withOpacity(0.4),
                ],
              ),
            ),
            child: Image.asset(
              wilaya.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: Container(
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: ThemeColors.grey200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.gallery_slash,
            color: ThemeColors.textSecondary.withOpacity(0.7),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            L10n.of(context).failedToLoadImage,
            style: TextStyle(
              color: ThemeColors.textSecondary.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(Wilaya wilaya) {
    return FutureBuilder<List<Hotel>>(
      future: _hotelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicatorWidget()),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: ErrorWidgetWithRetry(
              errorMessage: L10n.of(context).failedToLoadHotels,
              onRetry: _refreshData,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverFillRemaining(
            child: NoHotelsWidget(wilayaName: wilaya.name),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildAnimatedHotelCard(snapshot.data![index], index),
              childCount: snapshot.data!.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHotelCard(Hotel hotel, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 60.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: HotelCard(
              hotel: hotel,
              onTap: () => _navigateToHotelDetails(hotel),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHotelDetails(Hotel hotel) {
    Navigator.pushNamed(
      context,
      hotelDetailsRoute,
      arguments: hotel.id,
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHotelImage(),
            _buildHotelDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: hotel.images.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: hotel.images.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: ThemeColors.grey200,
              ),
              errorWidget: (context, url, error) => _buildImageError(),
            )
          : _buildImageError(),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: ThemeColors.grey200,
      alignment: Alignment.center,
      child: Icon(
        Iconsax.gallery_slash,
        color: ThemeColors.textSecondary.withOpacity(0.6),
        size: 32,
      ),
    );
  }

  Widget _buildHotelDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHotelName(),
          const SizedBox(height: 10),
          if (hotel.location != null) _buildLocation(context),
          const SizedBox(height: 14),
          _buildRatingAndRooms(context),
        ],
      ),
    );
  }

  Widget _buildHotelName() {
    return Text(
      hotel.hotelName,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: ThemeColors.textPrimary,
        height: 1.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation(BuildContext context) {
    return Row(
      children: [
        Icon(
          Iconsax.location,
          size: 18,
          color: ThemeColors.textSecondary.withOpacity(0.8),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            Wilaya.fromIndex(hotel.location!)?.name ??
                L10n.of(context).unknownLocation,
            style: TextStyle(
              fontSize: 15,
              color: ThemeColors.textSecondary.withOpacity(0.8),
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndRooms(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRating(),
        if (hotel.totalRooms != null) _buildRoomCount(context),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(
          Iconsax.star1,
          color: ThemeColors.star,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          hotel.ratings.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: ThemeColors.textPrimary,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '(${hotel.ratings.totalRating})',
          style: TextStyle(
            fontSize: 13,
            color: ThemeColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCount(BuildContext context) {
    return Text(
      '${hotel.totalRooms} ${L10n.of(context).rooms}',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: ThemeColors.textSecondary.withOpacity(0.8),
        fontSize: 14,
      ),
    );
  }
}

class NoHotelsWidget extends StatelessWidget {
  final String wilayaName;

  const NoHotelsWidget({
    super.key,
    required this.wilayaName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColors.primary.withOpacity(0.12),
            ),
            child: const Icon(
              Iconsax.building_4,
              size: 52,
              color: ThemeColors.primary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            L10n.of(context).noHotelsAvailable,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ThemeColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            L10n.of(context).noHotelsRegistered(wilayaName),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: ThemeColors.textSecondary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
