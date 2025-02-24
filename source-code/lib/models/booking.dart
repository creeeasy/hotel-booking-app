import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/booking_status.dart';

class Booking {
  final String id;
  final String hotelId;
  final String visitorId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.hotelId,
    required this.visitorId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
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
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      numberOfGuests: data['numberOfGuests'] as int,
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.byName(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hotelId': hotelId,
      'visitorId': visitorId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'numberOfGuests': numberOfGuests,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!doc.exists) return null;

      return Booking.fromFirestore(doc);
    } catch (e) {
      log('Error fetching booking: $e');
      return null;
    }
  }

  static Future<bool> cancelBooking(String bookingId) async {
    log(bookingId);
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': BookingStatus.cancelled.name,
      });
      return true;
    } catch (e) {
      log('Error canceling booking: $e');
      return false;
    }
  }

  static Future<List<Booking>> getBookingsByUser(String visitorId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('visitorId', isEqualTo: visitorId)
          .get();
      return querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching bookings by user: $e');
      return [];
    }
  }
}

  // static Future<List<Booking>> getBookingsByHotel(String hotelId) async {
  //   try {
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('bookings')
  //         .where('hotelId', isEqualTo: hotelId)
  //         .get();
  //     return querySnapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  //   } catch (e) {
  //     log('Error fetching bookings by hotel: $e');
  //     return [];
  //   }
  // }

  // static Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('bookings')
  //         .doc(bookingId)
  //         .update({'status': newStatus.name});
  //   } catch (e) {
  //     log('Error updating booking status: $e');
  //     rethrow;
  //   }
  // }

