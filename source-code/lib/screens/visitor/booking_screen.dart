import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// Project imports
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/screens/visitor/widget/divider_widget.dart';
import 'package:fatiel/screens/visitor/widget/error_widget_with_retry.dart';
import 'package:fatiel/screens/visitor/widget/hotel_image_widget.dart';
import 'package:fatiel/screens/visitor/widget/no_data_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/booking/booking_service.dart';
import 'package:fatiel/services/review/review_service.dart';
import 'package:fatiel/services/stream/visitor_bookings_stream.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:fatiel/widgets/card_loading_indicator_widget.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late BookingStatus _selectedTab;
  final _bookingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _selectedTab = BookingStatus.pending;
    _loadBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bookingNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    await _animationController.forward(from: 0);
    VisitorBookingsStream.listenToBookings(_selectedTab);
  }

  void _onTabChange(BookingStatus newTab) {
    if (_selectedTab == newTab) return;

    setState(() {
      _selectedTab = newTab;
      _loadBookings();
    });
  }

  void _refreshBookings() {
    _bookingNotifier.value = !_bookingNotifier.value;
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: CustomBackAppBar(title: L10n.of(context).myBookings),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final visitor = state.currentUser as Visitor;
            return ValueListenableBuilder<bool>(
              valueListenable: _bookingNotifier,
              builder: (context, _, __) {
                return Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: _buildBookingContent(visitor),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: _BookingTabBar(
        selectedTab: _selectedTab,
        onTabChanged: _onTabChange,
      ),
    );
  }

  Widget _buildBookingContent(Visitor visitor) {
    return FutureBuilder<List<Booking>>(
      future: BookingService.getBookingsByUser(visitor.id, _selectedTab,
          isAdmin: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicatorWidget());
        }

        if (snapshot.hasError) {
          return _ErrorView(
            error: snapshot.error.toString(),
            onRetry: _refreshBookings,
          );
        }

        final bookings = snapshot.data ?? [];
        return bookings.isEmpty
            ? _EmptyBookingView(status: _selectedTab)
            : _BookingListView(
                bookings: bookings,
                animationController: _animationController,
                onAction: _refreshBookings,
              );
      },
    );
  }
}

class _BookingTabBar extends StatelessWidget {
  final BookingStatus selectedTab;
  final ValueChanged<BookingStatus> onTabChanged;

  const _BookingTabBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: BookingStatus.values.map((status) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _BookingTab(
              status: status,
              isSelected: selectedTab == status,
              onTap: () => onTabChanged(status),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BookingTab extends StatelessWidget {
  final BookingStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _BookingTab({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? ThemeColors.primary : Colors.transparent,
          border: isSelected
              ? null
              : Border.all(color: ThemeColors.border, width: 1),
        ),
        child: Text(
          displayName(status, context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? ThemeColors.textOnPrimary
                : ThemeColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String displayName(BookingStatus bookingStatus, BuildContext context) {
    switch (bookingStatus) {
      case BookingStatus.pending:
        return L10n.of(context).pending;
      case BookingStatus.completed:
        return L10n.of(context).completed;
      case BookingStatus.cancelled:
        return L10n.of(context).cancelled;
    }
  }
}

class _BookingListView extends StatelessWidget {
  final List<Booking> bookings;
  final AnimationController animationController;
  final VoidCallback onAction;

  const _BookingListView({
    required this.bookings,
    required this.animationController,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onAction(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: DividerWidget(),
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Interval(
                (1 / bookings.length) * index,
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          );

          return FadeTransition(
            opacity: animation,
            child: _BookingCard(
              bookingId: bookings[index].id,
              onAction: onAction,
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String bookingId;
  final VoidCallback onAction;

  const _BookingCard({
    required this.bookingId,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: VisitorService.getBookingAndHotelById(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CardLoadingIndicator(
            height: 280,
            backgroundColor: ThemeColors.surface,
            indicatorColor: ThemeColors.primary,
            padding: EdgeInsets.zero,
          );
        }

        if (snapshot.hasError) {
          return ErrorWidgetWithRetry(
            errorMessage: L10n.of(context).failedToLoadBookingDetails,
            onRetry: () => onAction(),
          );
        }

        if (!snapshot.hasData) {
          return NoDataWidget(
            message: L10n.of(context).bookingDetailsNotAvailable,
          );
        }

        final booking = snapshot.data!["booking"] as Booking;
        final hotel = snapshot.data!["hotel"] as Hotel;

        return _HotelBookingCard(
          booking: booking,
          hotel: hotel,
          onAction: onAction,
        );
      },
    );
  }
}

class _HotelBookingCard extends StatelessWidget {
  final Hotel hotel;
  final Booking booking;
  final VoidCallback onAction;

  const _HotelBookingCard({
    required this.hotel,
    required this.booking,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HotelImageWithDates(hotel: hotel, booking: booking),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hotel.hotelName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _HotelLocationInfo(hotel: hotel),
                const SizedBox(height: 16),
                _BookingActions(
                  booking: booking,
                  hotel: hotel,
                  onAction: onAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelImageWithDates extends StatelessWidget {
  final Hotel hotel;
  final Booking booking;

  const _HotelImageWithDates({
    required this.hotel,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            hotelDetailsRoute,
            arguments: hotel.id,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: HotelImageWidget(images: hotel.images),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: _DateCard(
                  label: L10n.of(context).checkIn,
                  date: booking.checkInDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateCard(
                  label: L10n.of(context).checkOut,
                  date: booking.checkOutDate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateCard({
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.calendar_1,
            color: ThemeColors.textOnPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textOnPrimary,
                ),
              ),
              Text(
                DateFormat("MMM d, y").format(date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HotelLocationInfo extends StatelessWidget {
  final Hotel hotel;

  const _HotelLocationInfo({
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Iconsax.location,
          size: 18,
          color: ThemeColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hotel.location != null
                ? Wilaya.fromIndex(hotel.location!)?.name ??
                    L10n.of(context).unknownLocation
                : L10n.of(context).unknownLocation,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BookingActions extends StatelessWidget {
  final Booking booking;
  final Hotel hotel;
  final VoidCallback onAction;

  const _BookingActions({
    required this.booking,
    required this.hotel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.cancelled:
        return _BookingStatusBadge(
          icon: Iconsax.close_circle,
          text: L10n.of(context).cancelled,
          color: ThemeColors.error,
        );
      case BookingStatus.completed:
        return _CompletedBookingActions(
          booking: booking,
          hotel: hotel,
          onAction: onAction,
        );
      case BookingStatus.pending:
      default:
        return _PendingBookingActions(
          booking: booking,
          onAction: onAction,
        );
    }
  }
}

class _CompletedBookingActions extends StatelessWidget {
  final Booking booking;
  final Hotel hotel;
  final VoidCallback onAction;

  const _CompletedBookingActions({
    required this.booking,
    required this.hotel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BookingStatusBadge(
          icon: Iconsax.tick_circle,
          text: L10n.of(context).completed,
          color: ThemeColors.success,
        ),
        const SizedBox(width: 12),
        FutureBuilder<Review?>(
          future: ReviewService.hasVisitorReviewed(
            bookingId: booking.id,
            visitorId: booking.visitorId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicatorWidget(size: 20);
            }

            final hasReviewed = snapshot.hasData && snapshot.data != null;
            return _ReviewActions(
              hasReviewed: hasReviewed,
              existingReview: snapshot.data,
              booking: booking,
              hotel: hotel,
              onAction: onAction,
            );
          },
        ),
      ],
    );
  }
}

class _PendingBookingActions extends StatelessWidget {
  final Booking booking;
  final VoidCallback onAction;

  const _PendingBookingActions({
    required this.booking,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CancelBookingButton(
            bookingId: booking.id,
            onCancel: onAction,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              bookingDetailsViewRoute,
              arguments: booking.id,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(L10n.of(context).viewDetails),
          ),
        ),
      ],
    );
  }
}

class _ReviewActions extends StatelessWidget {
  final bool hasReviewed;
  final Review? existingReview;
  final Booking booking;
  final Hotel hotel;
  final VoidCallback onAction;

  const _ReviewActions({
    required this.hasReviewed,
    required this.existingReview,
    required this.booking,
    required this.hotel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showReviewDialog(context),
          icon: Icon(
            hasReviewed ? Iconsax.edit_2 : Iconsax.star,
            color: hasReviewed ? ThemeColors.primary : ThemeColors.warning,
          ),
        ),
        if (hasReviewed) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _confirmDeleteReview(context),
            icon: const Icon(
              Iconsax.trash,
              color: ThemeColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showReviewDialog(BuildContext context) async {
    final commentController = TextEditingController(
      text: existingReview?.comment ?? "",
    );
    double rating = existingReview?.rating ?? 3.0;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                existingReview == null
                    ? L10n.of(context).writeAReview
                    : L10n.of(context).editReview,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: rating.toStringAsFixed(1),
                    onChanged: (value) => setState(() => rating = value),
                    activeColor: ThemeColors.primary,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: L10n.of(context).shareYourExperience,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(L10n.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(L10n.of(context).pleaseWriteAComment),
                              ),
                            );
                            return;
                          }

                          setState(() => isSubmitting = true);

                          try {
                            if (existingReview == null) {
                              await ReviewService.createReview(
                                visitorId: booking.visitorId,
                                hotelId: hotel.id,
                                bookingId: booking.id,
                                rating: rating,
                                comment: commentController.text.trim(),
                              );
                            } else {
                              await ReviewService.updateReview(
                                visitorId: booking.visitorId,
                                reviewId: existingReview!.id,
                                newRating: rating,
                                newComment: commentController.text.trim(),
                              );
                            }

                            Navigator.pop(context);
                            onAction();
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primary,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(existingReview == null
                          ? L10n.of(context).submit
                          : L10n.of(context).update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteReview(BuildContext context) async {
    if (existingReview == null) return;

    final shouldDelete = await showGenericDialog<bool>(
      context: context,
      title: L10n.of(context).deleteReview,
      content: L10n.of(context).areYouSureDeleteReview,
      optionBuilder: () => {
        L10n.of(context).cancel: false,
        L10n.of(context).delete: true,
      },
    );

    if (shouldDelete == true) {
      await ReviewService.deleteReview(
        visitorId: booking.visitorId,
        reviewId: existingReview!.id,
      );
      onAction();
    }
  }
}

class _BookingStatusBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _BookingStatusBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelBookingButton extends StatefulWidget {
  final String bookingId;
  final VoidCallback onCancel;

  const _CancelBookingButton({
    required this.bookingId,
    required this.onCancel,
  });

  @override
  State<_CancelBookingButton> createState() => _CancelBookingButtonState();
}

class _CancelBookingButtonState extends State<_CancelBookingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _isLoading ? null : _confirmCancel,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: ThemeColors.error),
        foregroundColor: ThemeColors.error,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ThemeColors.error,
              ),
            )
          : Text(L10n.of(context).cancel),
    );
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await showGenericDialog<bool>(
      context: context,
      title: L10n.of(context).cancelBooking,
      content: L10n.of(context).areYouSureCancelBooking,
      optionBuilder: () =>
          {L10n.of(context).no: false, L10n.of(context).yesCancel: true},
    );

    if (shouldCancel != true) return;

    setState(() => _isLoading = true);

    try {
      await VisitorBookingsStream.cancelBooking(widget.bookingId);
      widget.onCancel();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _EmptyBookingView extends StatelessWidget {
  final BookingStatus status;

  const _EmptyBookingView({required this.status});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ThemeColors.primaryLight,
                    ThemeColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getEmptyIcon(),
                size: 48,
                color: ThemeColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyTitle(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _getEmptyDescription(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, hotelBrowseScreenRoute),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Iconsax.search_normal, size: 20),
              label: Text(L10n.of(context).exploreHotels),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (status) {
      case BookingStatus.pending:
        return Iconsax.bag_2;
      case BookingStatus.completed:
        return Iconsax.calendar_tick;
      case BookingStatus.cancelled:
        return Iconsax.calendar_remove;
    }
  }

  String _getEmptyTitle(BuildContext context) {
    switch (status) {
      case BookingStatus.pending:
        return L10n.of(context).noPendingBookings;
      case BookingStatus.completed:
        return L10n.of(context).noCompletedBookings;
      case BookingStatus.cancelled:
        return L10n.of(context).noCancelledBookings;
    }
  }

  String _getEmptyDescription(BuildContext context) {
    switch (status) {
      case BookingStatus.pending:
        return L10n.of(context).startYourJourney;
      case BookingStatus.completed:
        return L10n.of(context).completedBookingsAppearHere;
      case BookingStatus.cancelled:
        return L10n.of(context).cancelledBookingsAppearHere;
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
              L10n.of(context).failedToLoadBookings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ThemeColors.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
              ),
              child: Text(L10n.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
