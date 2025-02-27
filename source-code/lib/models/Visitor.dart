import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/booking.dart';

class Visitor {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String>? favorites;
  final List<String>? bookings;
  final int? location;

  Visitor({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.favorites,
    this.bookings,
    this.location,
  });

  factory Visitor.fromFirebaseUser({
    required String id,
    required String email,
    required bool isEmailVerified,
    String? firstName,
    String? lastName,
    List<String>? favorites,
    List<String>? bookings,
    int? location,
  }) {
    return Visitor(
      id: id,
      email: email,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      favorites: favorites ?? [],
      bookings: bookings ?? [],
      location: location,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'favorites': favorites ?? [],
      'bookings': bookings ?? [],
      'location': location,
    };
  }

  factory Visitor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Visitor(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      favorites: List<String>.from(data['favorites'] ?? []),
      bookings: List<String>.from(data['bookings'] ?? []),
      location: data['location'] as int?,
    );
  }

  static Future<Visitor?> getVisitorById(String visitorId) async {
    log(visitorId);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitorId)
          .get();
      if (doc.exists) {
        return Visitor.fromFirestore(doc);
      }
      return null;
    } catch (e, stackTrace) {
      log('Error fetching visitor by ID: $e\n$stackTrace');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getBookingAndHotelById(
      String bookingId) async {
    try {
      final booking = await Booking.getBookingById(bookingId);
      final hotel = await Hotel.getHotelById(booking.hotelId);

      return {
        "booking": booking,
        "hotel": hotel,
      };
    } catch (e) {
      print('Error fetching booking or hotel: $e');
      return null;
    }
  }
}



 // static Future<void> updateVisitor(Visitor visitor) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('visitors')
  //         .doc(visitor.id)
  //         .update(visitor.toFirestore());
  //   } catch (e) {
  //     print('Error updating visitor: $e');
  //     rethrow;
  //   }
  // }

  // static Future<List<String>> getUserFavorites(String userId) async {
  //   try {
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('visitors')
  //         .doc(userId)
  //         .get();

  //     if (userDoc.exists) {
  //       Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
  //       List<String> favorites = List<String>.from(data?['favorites'] ?? []);
  //       return favorites;
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     log('Error fetching user favorites: $e');
  //     return [];
  //   }
  // }

  // static Future<List<String>> getUserBookings(
  //     String userId, BookingStatus status) async {
  //   try {
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('visitors')
  //         .doc(userId)
  //         .get();
  //     if (!userDoc.exists) return [];

  //     Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
  //     if (data == null || !data.containsKey('bookings')) return [];

  //     List<String> bookingIds = List<String>.from(data['bookings']);

  //     List<String> filteredBookings = [];
  //     for (String bookingId in bookingIds) {
  //       DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
  //           .collection('bookings')
  //           .doc(bookingId)
  //           .get();

  //       if (bookingDoc.exists) {
  //         Map<String, dynamic>? bookingData =
  //             bookingDoc.data() as Map<String, dynamic>?;

  //         if (bookingData != null &&
  //             bookingData.containsKey('status') &&
  //             bookingData['status'].toString() == status.name) {
  //           filteredBookings.add(bookingId);
  //         }
  //       }
  //     }

  //     return filteredBookings;
  //   } catch (e, stackTrace) {
  //     log('Error fetching user bookings: $e', stackTrace: stackTrace);
  //     return [];
  //   }
  // }
