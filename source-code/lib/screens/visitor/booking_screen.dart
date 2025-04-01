// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

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
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:fatiel/widgets/card_loading_indicator_widget.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late BookingStatus _selectedTab;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _selectedTab = BookingStatus.pending;
    VisitorBookingsStream.listenToBookings(_selectedTab);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabChange(BookingStatus newTab) {
    if (_selectedTab == newTab) return;

    setState(() {
      _selectedTab = newTab;
      VisitorBookingsStream.listenToBookings(newTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: const CustomBackAppBar(
          title: "Bookings",
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final visitorId = (state.currentUser as Visitor).id;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabView(),
                Expanded(
                  child: FutureBuilder<List<Booking>>(
                    future: BookingService.getBookingsByUser(
                        visitorId, _selectedTab),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicatorWidget();
                      }

                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString());
                      }

                      final bookings = snapshot.data ?? [];
                      return bookings.isEmpty
                          ? NoBookingsWidget()
                          : _buildBookingsList(bookings);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: _tabView(selectedTab: _selectedTab, onTabChange: _onTabChange),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    final itemCount = bookings.length.clamp(1, 10);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DividerWidget(),
        ),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final animation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (1 / itemCount) * index,
                1.0,
                curve: Curves.fastOutSlowIn,
              ),
            ),
          );

          return FadeTransition(
            opacity: animation,
            child: BookingWidget(
              bookingId: bookings[index].id,
              onAction: () => setState(() {}),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(child: Text("Error: $error"));
  }
}

Widget _tabView({
  required BookingStatus selectedTab,
  required Function(BookingStatus) onTabChange,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double totalWidth = 0;
      final List<Widget> tabItems = [
        _buildTabItem(
          title: 'Pending',
          isSelected: selectedTab == BookingStatus.pending,
          onTap: () => onTabChange(BookingStatus.pending),
        ),
        _buildTabItem(
          title: 'Completed',
          isSelected: selectedTab == BookingStatus.completed,
          onTap: () => onTabChange(BookingStatus.completed),
        ),
        _buildTabItem(
          title: 'Cancelled',
          isSelected: selectedTab == BookingStatus.cancelled,
          onTap: () => onTabChange(BookingStatus.cancelled),
        ),
      ];

      bool isScrollable = totalWidth > constraints.maxWidth;

      return Column(
        children: <Widget>[
          if (isScrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: tabItems
                      .map((e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: e,
                          ))
                      .toList()),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tabItems,
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      );
    },
  );
}

Widget _buildTabItem({
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
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
            : Border.all(
                color: ThemeColors.border,
                width: 1,
              ),
      ),
      child: Text(
        title,
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

class NoBookingsWidget extends StatelessWidget {
  const NoBookingsWidget({super.key});

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
                gradient: LinearGradient(
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
                Iconsax.bag_2,
                size: 48,
                color: ThemeColors.textOnPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Bookings Yet!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start your journey today! Find the best hotels\nand book your dream stay effortlessly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ThemeColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(hotelBrowseScreenRoute),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Iconsax.search_normal, size: 20),
              label: const Text("Explore Hotels"),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingWidget extends StatelessWidget {
  final String bookingId;
  final VoidCallback onAction;

  const BookingWidget(
      {Key? key, required this.bookingId, required this.onAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: VisitorService.getBookingAndHotelById(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CardLoadingIndicator(
            height: 280,
            backgroundColor: ThemeColors.surface,
            indicatorColor: ThemeColors.primary,
            padding: EdgeInsets.zero,
          );
        } else if (snapshot.hasError) {
          return ErrorWidgetWithRetry(
            errorMessage: 'Error: ${snapshot.error}',
          );
        } else if (!snapshot.hasData) {
          return NoDataWidget(
            message: "Currently, there are no bookings for this hotel.",
          );
        }

        final Booking booking = snapshot.data!["booking"];
        final Hotel hotel = snapshot.data!["hotel"];
        return HotelBookingCard(
          booking: booking,
          hotel: hotel,
          onAction: onAction,
        );
      },
    );
  }
}

class HotelBookingCard extends StatelessWidget {
  final Hotel hotel;
  final Booking booking;
  final VoidCallback onAction;

  const HotelBookingCard({
    super.key,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Image with Date Cards
          _HotelImageSection(hotel: hotel, booking: booking),

          // Hotel Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.hotelName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _LocationInfo(hotel: hotel),
                const SizedBox(height: 16),
                ActionButton(
                  bookingStatus: booking.status,
                  bookingId: booking.id,
                  visitorId: booking.visitorId,
                  hotelId: booking.hotelId,
                  onCancelBooking: onAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelImageSection extends StatelessWidget {
  final Hotel hotel;
  final Booking booking;

  const _HotelImageSection({
    required this.hotel,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hotel Image
        InkWell(
          onTap: () => Navigator.of(context)
              .pushNamed(hotelDetailsRoute, arguments: hotel.id),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: HotelImageWidget(images: hotel.images),
            ),
          ),
        ),

        // Date Cards
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: _DateCard(
                  label: "Check-In",
                  date: booking.checkInDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateCard(
                  label: "Check-Out",
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
          Icon(
            Iconsax.calendar_1,
            color: ThemeColors.textOnPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textOnPrimary,
                ),
              ),
              Text(
                DateFormat("MMM d, y").format(date),
                style: TextStyle(
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

class _LocationInfo extends StatelessWidget {
  final Hotel hotel;

  const _LocationInfo({
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Iconsax.location,
          size: 18,
          color: ThemeColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hotel.location != null
                ? Wilaya.fromIndex(hotel.location!)?.name ??
                    'Location not available'
                : 'Location not available',
            style: TextStyle(
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

class BookingNotifier extends ValueNotifier<bool> {
  BookingNotifier() : super(false);

  void refresh() {
    value = !value;
  }
}

final bookingNotifier = BookingNotifier();

class ActionButton extends StatelessWidget {
  final BookingStatus bookingStatus;
  final String bookingId;
  final String visitorId;
  final String hotelId;
  final VoidCallback? onCancelBooking;

  const ActionButton({
    super.key,
    required this.bookingStatus,
    required this.bookingId,
    required this.visitorId,
    required this.hotelId,
    this.onCancelBooking,
  });

  @override
  Widget build(BuildContext context) {
    switch (bookingStatus) {
      case BookingStatus.cancelled:
        return _buildCancelledStatus();
      case BookingStatus.completed:
        return _buildCompletedStatus(context);
      case BookingStatus.pending:
      default:
        return _buildPendingActions(context);
    }
  }

  Widget _buildCancelledStatus() {
    return _StatusBadge(
      icon: Iconsax.close_circle,
      text: "Booking Cancelled",
      color: ThemeColors.error,
    );
  }

  Widget _buildCompletedStatus(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatusBadge(
          icon: Iconsax.tick_circle,
          text: "Booking Completed",
          color: ThemeColors.success,
        ),
        const SizedBox(width: 12),
        ValueListenableBuilder<bool>(
          valueListenable: bookingNotifier,
          builder: (context, _, __) {
            return FutureBuilder<Review?>(
              future: ReviewService.hasVisitorReviewed(
                bookingId: bookingId,
                visitorId: visitorId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicatorWidget(
                    size: 20,
                  );
                }

                final hasReviewed = snapshot.hasData && snapshot.data != null;
                return _ReviewActions(
                  hasReviewed: hasReviewed,
                  onEdit: () => _showReviewDialog(
                    context,
                    existingReview: snapshot.data,
                  ),
                  onDelete: hasReviewed
                      ? () => _confirmDeleteReview(context, snapshot.data!)
                      : null,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPendingActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CancelBookingButton(
            bookingId: bookingId,
            onCancelBooking: onCancelBooking!,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              bookingDetailsViewRoute,
              arguments: bookingId,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("View Details"),
          ),
        ),
      ],
    );
  }

  Future<void> _showReviewDialog(
    BuildContext context, {
    Review? existingReview,
  }) async {
    final commentController =
        TextEditingController(text: existingReview?.comment ?? "");
    double rating = existingReview?.rating ?? 3.0;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                existingReview == null ? "Write a Review" : "Edit Review",
                style: TextStyle(
                  color: ThemeColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
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
                      hintText: "Share your experience...",
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
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please write a comment")),
                            );
                            return;
                          }

                          setState(() => isSubmitting = true);

                          try {
                            if (existingReview == null) {
                              await ReviewService.createReview(
                                visitorId: visitorId,
                                hotelId: hotelId,
                                bookingId: bookingId,
                                rating: rating,
                                comment: commentController.text.trim(),
                              );
                            } else {
                              await ReviewService.updateReview(
                                visitorId: visitorId,
                                reviewId: existingReview.id,
                                newRating: rating,
                                newComment: commentController.text.trim(),
                              );
                            }

                            Navigator.pop(context);
                            bookingNotifier.refresh();
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
                      : Text(existingReview == null ? "Submit" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteReview(BuildContext context, Review review) async {
    final shouldDelete = await showGenericDialog<bool>(
      context: context,
      title: "Delete Review",
      content: "Are you sure you want to delete this review?",
      optionBuilder: () => {
        "Cancel": false,
        "Delete": true,
      },
    );

    if (shouldDelete == true) {
      await ReviewService.deleteReview(
        visitorId: visitorId,
        reviewId: review.id,
      );
      bookingNotifier.refresh();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusBadge({
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

class _ReviewActions extends StatelessWidget {
  final bool hasReviewed;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _ReviewActions({
    required this.hasReviewed,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onEdit,
          icon: Icon(
            hasReviewed ? Iconsax.edit_2 : Iconsax.star,
            color: hasReviewed ? ThemeColors.primary : ThemeColors.warning,
          ),
        ),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Iconsax.trash,
              color: ThemeColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _CancelBookingButton extends StatefulWidget {
  final String bookingId;
  final VoidCallback onCancelBooking;

  const _CancelBookingButton({
    required this.bookingId,
    required this.onCancelBooking,
  });

  @override
  State<_CancelBookingButton> createState() => _CancelBookingButtonState();
}

class _CancelBookingButtonState extends State<_CancelBookingButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : _confirmCancel,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: ThemeColors.error),
        foregroundColor: ThemeColors.error,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ThemeColors.error,
              ),
            )
          : const Text("Cancel Booking"),
    );
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await showGenericDialog<bool>(
      context: context,
      title: 'Cancel Booking',
      content: 'Are you sure you want to cancel this booking?',
      optionBuilder: () => {'No': false, 'Yes, Cancel': true},
    );

    if (shouldCancel != true) return;

    setState(() => isLoading = true);

    try {
      await VisitorBookingsStream.cancelBooking(widget.bookingId);
      widget.onCancelBooking();
    } finally {
      setState(() => isLoading = false);
    }
  }
}
