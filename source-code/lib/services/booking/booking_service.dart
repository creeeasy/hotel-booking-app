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

      final booking = await getBookingById(bookingRef.id);
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
  static Future<List<Booking>> fetchHotelBookings(
      {required String hotelId}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
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

  /// Fetches bookings for a user filtered by status
  static Future<List<Booking>> getBookingsByUser(
    String visitorId,
    BookingStatus status,
  ) async {
    try {
      final visitor = await VisitorService.getVisitorById(visitorId);
      if (visitor == null ||
          visitor.bookings == null ||
          visitor.bookings!.isEmpty) {
        return [];
      }

      // Fetch all bookings at once for better performance
      final bookings = await Future.wait(
        visitor.bookings!.map((id) => getBookingById(id)),
      );

      return bookings.where((b) => b.status == status).toList();
    } on FirebaseException catch (e) {
      log('Firebase error fetching user bookings: $e');
      return [];
    } catch (e) {
      log('Error fetching user bookings: $e');
      return [];
    }
  }

  static Future<List<BookingWithDetails>> getRecentBookings() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      List<BookingWithDetails> bookingsWithDetails = [];

      for (var doc in querySnapshot.docs) {
        final booking = Booking.fromFirestore(doc);

        // Fetch visitor, hotel, and room details
        final visitor = await VisitorService.getVisitorById(booking.visitorId);
        final hotelSnapshot = await FirebaseFirestore.instance
            .collection('hotels')
            .doc(booking.hotelId)
            .get();
        final roomSnapshot = await FirebaseFirestore.instance
            .collection('rooms')
            .doc(booking.roomId)
            .get();

        if (hotelSnapshot.exists && roomSnapshot.exists) {
          final hotelName = hotelSnapshot['hotelName'] as String;
          final roomName = roomSnapshot['roomName'] as String;
          final commission = roomSnapshot['commission'] as double;

          bookingsWithDetails.add(
            BookingWithDetails(
              booking: booking,
              visitorName:
                  '${visitor?.firstName ?? 'Unknown'} ${visitor?.lastName ?? ''}',
              hotelName: hotelName,
              roomName: roomName,
              commission: commission,
            ),
          );
        }
      }

      return bookingsWithDetails;
    } on FirebaseException catch (e) {
      print(e);
      log('Firebase error fetching recent bookings: $e');
      return [];
    } catch (e) {
      print(e);
      log('Error fetching recent bookings: $e');
      return [];
    }
  }

  /// Fetches the total number of visitors
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
