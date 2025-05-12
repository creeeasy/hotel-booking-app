import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/booking_with_details.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';

class BookingService {
  /// Fetches a booking by its ID
  static Future<Booking> getBookingById(String bookingId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!doc.exists) {
        throw Exception('Booking not found');
      }

      return Booking.fromFirestore(doc);
    } on FirebaseException catch (e) {
      log('Firebase error fetching booking: $e');
      rethrow;
    } catch (e) {
      log('Error fetching booking: $e');
      rethrow;
    }
  }

  /// Creates a new booking with validation
  static Future<BookingResult> createBooking({
    required String hotelId,
    required String roomId,
    required String visitorId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPrice,
  }) async {
    try {
      // Validate dates
      if (checkInDate.isAfter(checkOutDate)) {
        return const BookingFailure(
            'Check-in date must be before check-out date');
      }

      if (checkInDate.isBefore(DateTime.now())) {
        return const BookingFailure('Check-in date cannot be in the past');
      }

      final roomRef =
          FirebaseFirestore.instance.collection("rooms").doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) {
        return const BookingFailure('Room not found');
      }

      final roomData = Room.fromFirestore(roomDoc);

      // Check room availability
      if (!_isRoomAvailable(roomData, checkInDate, checkOutDate)) {
        return const BookingFailure(
            'Room is not available for the selected dates');
      }

      // Create booking document
      final bookingData = {
        'hotelId': hotelId,
        'roomId': roomId,
        'visitorId': visitorId,
        'checkInDate': Timestamp.fromDate(checkInDate),
        'checkOutDate': Timestamp.fromDate(checkOutDate),
        'totalPrice': totalPrice,
        'status': BookingStatus.pending.name,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      // Run transaction to ensure data consistency
      final bookingRef = await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          // Create booking
          final docRef =
              FirebaseFirestore.instance.collection('bookings').doc();
          transaction.set(docRef, bookingData);

          // Update room availability
          transaction.update(roomRef, {
            'availability.nextAvailableDate': Timestamp.fromDate(checkOutDate),
            'availability.isAvailable': false,
          });

          return docRef;
        },
      );

      // Update visitor's bookings list
      await _updateVisitorBookings(visitorId, bookingRef.id);

      final booking = await getBookingById(
        bookingRef.id,
      );
      return BookingSuccess(booking);
    } on FirebaseException catch (e) {
      log('Firebase error creating booking: $e');
      return BookingFailure('Failed to create booking: ${e.message}');
    } catch (e) {
      log('Error creating booking: $e');
      return const BookingFailure('An unexpected error occurred');
    }
  }

  /// Updates a visitor's bookings list with the new booking ID
  static Future<void> _updateVisitorBookings(
      String visitorId, String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection("visitors")
          .doc(visitorId)
          .update({
        'bookings': FieldValue.arrayUnion([bookingId])
      });
    } on FirebaseException catch (e) {
      log('Firebase error updating visitor bookings: $e');
      rethrow;
    } catch (e) {
      log('Error updating visitor bookings: $e');
      rethrow;
    }
  }

  /// Checks if a room is available for the given dates
  static bool _isRoomAvailable(Room room, DateTime checkIn, DateTime checkOut) {
    final availability = room.availability;

    if (availability.isAvailable) {
      return true;
    }

    final nextAvailable = availability.nextAvailableDate;
    if (nextAvailable != null && checkIn.isAfter(nextAvailable)) {
      return true;
    }

    return false;
  }

  /// Fetches monthly bookings count for a hotel
  static Future<int> fetchMonthlyBookingsCount(
      {required String hotelId}) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
              isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
          .get();

      return querySnapshot.size;
    } on FirebaseException catch (e) {
      log('Firebase error fetching monthly bookings: $e');
      return 0;
    } catch (e) {
      log('Error fetching monthly bookings: $e');
      return 0;
    }
  }

  /// Fetches pending bookings count for a hotel
  static Future<int> fetchPendingBookingsCount(
      {required String hotelId}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .where('status', isEqualTo: BookingStatus.pending.name)
          .get();

      return querySnapshot.size;
    } on FirebaseException catch (e) {
      log('Firebase error fetching pending bookings: $e');
      return 0;
    } catch (e) {
      log('Error fetching pending bookings: $e');
      return 0;
    }
  }

  /// Fetches all bookings for a hotel
  static Future<List<Booking>> fetchHotelBookings({
    required String hotelId,
    required bool isAdmin,
  }) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .orderBy('createdAt', descending: true)
          .get();

      final bookings =
          querySnapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();

      // For non-admin users, filter out bookings from unsubscribed hotels
      if (!isAdmin) {
        final isHotelSubscribed = await _isHotelSubscribed(hotelId);
        if (!isHotelSubscribed) {
          return [];
        }
      }

      return bookings;
    } on FirebaseException catch (e) {
      log('Firebase error fetching hotel bookings: $e');
      return [];
    } catch (e) {
      log('Error fetching hotel bookings: $e');
      return [];
    }
  }

  /// Updates booking status and handles related room availability
  static Future<BookingResult> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    try {
      final bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);

      return await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          // Get current booking data
          final bookingDoc = await transaction.get(bookingRef);
          if (!bookingDoc.exists) {
            throw Exception('Booking not found');
          }

          final booking = Booking.fromFirestore(bookingDoc);

          // Update booking status
          transaction.update(bookingRef, {
            'status': newStatus.name,
          });

          // Handle room availability for completed/cancelled bookings
          if (newStatus == BookingStatus.completed ||
              newStatus == BookingStatus.cancelled) {
            final roomRef = FirebaseFirestore.instance
                .collection('rooms')
                .doc(booking.roomId);

            transaction.update(roomRef, {
              'availability.isAvailable': true,
              'availability.nextAvailableDate': null,
            });
          }

          return BookingSuccess(booking);
        },
      );
    } on FirebaseException catch (e) {
      log('Firebase error updating booking status: $e');
      return BookingFailure('Failed to update booking: ${e.message}');
    } catch (e) {
      log('Error updating booking status: $e');
      return const BookingFailure('An unexpected error occurred');
    }
  }

  /// Checks if a hotel is subscribed
  static Future<bool> _isHotelSubscribed(String hotelId) async {
    try {
      final hotelDoc = await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotelId)
          .get();

      if (!hotelDoc.exists) {
        return false;
      }

      return hotelDoc.data()?['isSubscribed'] as bool? ?? false;
    } on FirebaseException catch (e) {
      log('Firebase error checking hotel subscription: $e');
      return false;
    } catch (e) {
      log('Error checking hotel subscription: $e');
      return false;
    }
  }

  /// Fetches bookings for a user filtered by status
  static Future<List<Booking>> getBookingsByUser(
    String visitorId,
    BookingStatus status, {
    required bool isAdmin,
  }) async {
    try {
      final visitor = await VisitorService.getVisitorById(visitorId);
      if (visitor == null ||
          visitor.bookings == null ||
          visitor.bookings!.isEmpty) {
        return [];
      }

      // Fetch all bookings at once for better performance
      final bookingsResults = await Future.wait(
        visitor.bookings!.map((id) => getBookingById(
              id,
            )),
      );

      // Remove null values (bookings from unsubscribed hotels for non-admins)
      final bookings = bookingsResults.whereType<Booking>().toList();

      // Filter by status
      return bookings.where((b) => b.status == status).toList();
    } on FirebaseException catch (e) {
      log('Firebase error fetching user bookings: $e');
      return [];
    } catch (e) {
      log('Error fetching user bookings: $e');
      return [];
    }
  }

  static Future<List<BookingWithDetails>> getRecentBookings({
    required bool isAdmin,
    String? hotelId, // Optional parameter for hotel-specific filtering
    DateTime? startDate, // New parameter for start date filtering
    DateTime? endDate, // New parameter for end date filtering
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .limit(10);

      // Add hotelId filter if provided or if not an admin
      if (hotelId != null || !isAdmin) {
        query = query.where('hotelId', isEqualTo: hotelId ?? '');
      }

      // Add date range filtering
      if (startDate != null && endDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();

      // Convert query results to Booking objects
      List<Booking> bookings = querySnapshot.docs
          .map((doc) => Booking.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      // Filter bookings by hotel subscription status for non-admins
      if (!isAdmin && hotelId == null) {
        final List<Booking> filteredBookings = [];

        for (final booking in bookings) {
          final isSubscribed = await _isHotelSubscribed(booking.hotelId);
          if (isSubscribed) {
            filteredBookings.add(booking);
          }
        }

        bookings = filteredBookings;
      }

      // Fetch additional details for bookings
      final List<BookingWithDetails?> bookingsWithDetails =
          await Future.wait(bookings.map((booking) async {
        try {
          // Fetch visitor details
          final visitor =
              await VisitorService.getVisitorById(booking.visitorId);

          // Fetch hotel details
          final hotelSnapshot = await FirebaseFirestore.instance
              .collection('hotels')
              .doc(booking.hotelId)
              .get();

          // Fetch room details
          final roomSnapshot = await FirebaseFirestore.instance
              .collection('rooms')
              .doc(booking.roomId)
              .get();

          // Validate snapshots exist
          if (!hotelSnapshot.exists || !roomSnapshot.exists) {
            log('Hotel or Room not found for booking: ${booking.id}');
            return null;
          }

          // Extract details
          final hotelName = hotelSnapshot['hotelName'] as String;
          final roomName = roomSnapshot['name'] as String;
          final commission =
              booking.totalPrice * 0.1; // Assuming commission is 10%

          return BookingWithDetails(
            booking: booking,
            visitorName:
                '${visitor?.firstName ?? 'Unknown'} ${visitor?.lastName ?? ''}'
                    .trim(),
            hotelName: hotelName,
            roomName: roomName,
            commission: commission,
          );
        } catch (e) {
          log('Error processing booking ${booking.id}: $e');
          return null;
        }
      }));

      // Remove any null entries (failed to process)
      return bookingsWithDetails.whereType<BookingWithDetails>().toList();
    } on FirebaseException catch (e) {
      log('Firebase error fetching recent bookings: $e');
      return [];
    } catch (e) {
      log('Error fetching recent bookings: $e');
      return [];
    }
  }

  static Future<int> getTotalVisitors() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('visitors').get();

      return querySnapshot.size;
    } on FirebaseException catch (e) {
      log('Firebase error fetching total visitors: $e');
      return 0;
    } catch (e) {
      log('Error fetching total visitors: $e');
      return 0;
    }
  }
}

sealed class BookingResult {
  const BookingResult();
}

class BookingSuccess extends BookingResult {
  final Booking booking;
  const BookingSuccess(this.booking);
}

class BookingFailure extends BookingResult {
  final String message;
  const BookingFailure(this.message);
}
