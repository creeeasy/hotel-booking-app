import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';

class Booking {
  final String id;
  final String hotelId;
  final String roomId;
  final String visitorId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.hotelId,
    required this.roomId,
    required this.visitorId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Booking data is null');
    }
    return Booking(
      id: doc.id,
      hotelId: data['hotelId'] as String,
      visitorId: data['visitorId'] as String,
      roomId: data['roomId'] as String,
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.byName(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hotelId': hotelId,
      'visitorId': visitorId,
      'roomId': roomId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // static Future<List<Booking>> getBookingsByUser(String visitorId) async {
  //   try {
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('bookings')
  //         .where('visitorId', isEqualTo: visitorId)
  //         .get();
  //     return querySnapshot.docs
  //         .map((doc) => Booking.fromFirestore(doc))
  //         .toList();
  //   } catch (e) {
  //     log('Error fetching bookings by user: $e');
  //     return [];
  //   }
  // }
  static Future<List<Booking>> getBookingsByUser(
      String visitorId, BookingStatus status) async {
    try {
      final visitor = await Visitor.getVisitorById(visitorId);
      if (visitor!.bookings == null) {
        return [];
      }
      final bookingIds = visitor.bookings!;

      List<Booking> filteredBookings = [];

      for (final bookingId in bookingIds) {
        final bookingData = await Booking.getBookingById(bookingId);

        if (bookingData.status == status) {
          filteredBookings.add(bookingData);
        }
      }
      return filteredBookings;
    } catch (e) {
      log('Error fetching bookings by user: $e');
      return [];
    }
  }

  static Future<Booking> getBookingById(String bookingId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      return Booking.fromFirestore(doc);
    } catch (e) {
      log('Error fetching booking: $e');
      rethrow;
    }
  }

  static Future<BookingResult> createBooking({
    required String hotelId,
    required String roomId,
    required String visitorId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required double totalPrice,
  }) async {
    try {
      final roomRef =
          FirebaseFirestore.instance.collection("rooms").doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) {
        return const BookingFailure('Room not found.');
      }

      final roomData = Room.fromFirestore(roomDoc);

      if (!roomData.availability.isAvailable ||
          (roomData.availability.nextAvailableDate != null &&
              roomData.availability.nextAvailableDate!.isAfter(checkInDate))) {
        return const BookingFailure(
            'Room is not available for the selected dates.');
      }

      final docRef =
          await FirebaseFirestore.instance.collection('bookings').add({
        'hotelId': hotelId,
        'roomId': roomId,
        'visitorId': visitorId,
        'checkInDate': Timestamp.fromDate(checkInDate),
        'checkOutDate': Timestamp.fromDate(checkOutDate),
        'totalPrice': totalPrice,
        'status': BookingStatus.pending.name,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      await roomRef.update({
        'availability.nextAvailableDate': Timestamp.fromDate(checkOutDate),
      });

      final doc = await docRef.get();
      await Booking.updateVisitorBooking(
          bookingId: docRef.id, visitorId: visitorId);
      return BookingSuccess(Booking.fromFirestore(doc));
    } catch (e) {
      return BookingFailure('Error creating booking: $e');
    }
  }

  static Future<void> updateVisitorBooking({
    required String visitorId,
    required String bookingId,
  }) async {
    try {
      final visitorDoc =
          FirebaseFirestore.instance.collection("visitors").doc(visitorId);
      final docSnapshot = await visitorDoc.get();

      if (docSnapshot.exists) {
        await visitorDoc.update({
          'bookings': FieldValue.arrayUnion([bookingId])
        });
      }
    } catch (e) {
      print("Error updating visitor booking: $e");
    }
  }

  static Future<int> fetchMonthlyBookingsFuture(
      {required String hotelId}) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .where('createdAt', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('createdAt', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      return querySnapshot.size;
    } catch (e) {
      print(e);
      log('Error fetching monthly bookings: $e');
      return 0;
    }
  }

  static Future<int> fetchPendingBookingsFuture(
      {required String hotelId}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.size;
    } catch (e) {
      log('Error fetching pending bookings: $e');
      return 0;
    }
  }

  static Future<List<Booking>> fetchHotelBookingsById(
      {required String hotelId}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('hotelId', isEqualTo: hotelId)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching hotel bookings: $e');
      return [];
    }
  }

  static Future<BookingResult> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    try {
      final bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);

      // First get the current booking to check roomId
      final bookingDoc = await bookingRef.get();
      if (!bookingDoc.exists) {
        return const BookingFailure('Booking not found');
      }

      final booking = Booking.fromFirestore(bookingDoc);

      // Update the booking status
      await bookingRef.update({
        'status': newStatus.name,
      });

      // If completed or cancelled, update room availability
      if (newStatus == BookingStatus.completed ||
          newStatus == BookingStatus.cancelled) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(booking.roomId)
            .update({
          'availability.isAvailable': true,
          'availability.nextAvailableDate': null,
        });
      }

      return BookingSuccess(booking);
    } catch (e) {
      log('Error updating booking status: $e');
      return BookingFailure('Failed to update booking status: $e');
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
