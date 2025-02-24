import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/booking_status.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:fatiel/enum/user_role.dart';

class Visitor extends AuthUser {
  final String firstName;
  final String lastName;
  final List<String>? favorites;
  final List<String>? bookings;
  final int? location;

  Visitor(
      {required super.id,
      required super.email,
      required super.isEmailVerified,
      required super.role,
      required this.firstName,
      required this.lastName,
      this.favorites,
      this.bookings,
      this.location});

  factory Visitor.fromFirebaseUser(
    AuthUser user, {
    String? firstName,
    String? lastName,
    List<String>? favorites,
    List<String>? bookings,
    int? location,
  }) {
    return Visitor(
      id: user.id,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: user.email,
      role: UserRole.visitor,
      isEmailVerified: user.isEmailVerified,
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
      'role': role?.name,
      'isEmailVerified': isEmailVerified,
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
      role: _parseRole(data['role']),
      isEmailVerified: data['isEmailVerified'] ?? false,
      favorites: List<String>.from(data['favorites'] ?? []),
      bookings: List<String>.from(data['bookings'] ?? []),
      location: data['location'] != null ? data['location'] as int : null,
    );
  }

  static Future<void> updateVisitor(Visitor visitor) async {
    try {
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitor.id)
          .update(visitor.toFirestore());
    } catch (e) {
      print('Error updating visitor: $e');
      rethrow;
    }
  }

  static Future<List<String>> getUserFavorites(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('visitors')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        List<String> favorites = List<String>.from(data?['favorites'] ?? []);
        return favorites;
      } else {
        return [];
      }
    } catch (e) {
      log('Error fetching user favorites: $e');
      return [];
    }
  }

  static Future<List<String>> getUserBookings(
      String userId, BookingStatus status) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('visitors')
          .doc(userId)
          .get();
      if (!userDoc.exists) return [];

      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('bookings')) return [];

      List<String> bookingIds = List<String>.from(data['bookings']);

      List<String> filteredBookings = [];
      for (String bookingId in bookingIds) {
        DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get();

        if (bookingDoc.exists) {
          Map<String, dynamic>? bookingData =
              bookingDoc.data() as Map<String, dynamic>?;

          if (bookingData != null &&
              bookingData.containsKey('status') &&
              bookingData['status'].toString() == status.name) {
            filteredBookings.add(bookingId);
          }
        }
      }

      return filteredBookings;
    } catch (e, stackTrace) {
      log('Error fetching user bookings: $e', stackTrace: stackTrace);
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getBookingAndHotelById(
      String bookingId) async {
    try {
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (!bookingDoc.exists) return null;

      final Booking booking = Booking.fromFirestore(bookingDoc);

      final hotelDoc = await FirebaseFirestore.instance
          .collection('hotels')
          .doc(booking.hotelId)
          .get();

      if (!hotelDoc.exists) return null;

      final Hotel hotel = Hotel.fromFirestore(hotelDoc, booking.hotelId);

      return {
        "booking": booking,
        "hotel": hotel,
      };
    } catch (e) {
      log('Error fetching booking or hotel: $e');
      return null;
    }
  }

  static UserRole _parseRole(dynamic roleString) {
    if (roleString is String) {
      try {
        return UserRole.values.byName(roleString);
      } catch (_) {
        print('Invalid role string: $roleString. Defaulting to visitor.');
      }
    }
    return UserRole.visitor;
  }

  @override
  String toString() {
    return 'Visitor(id: $id, firstName: $firstName, lastName: $lastName, email: $email, role: $role, isEmailVerified: $isEmailVerified, favorites: $favorites, bookings: $bookings)';
  }
}
