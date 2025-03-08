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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'favorites': favorites ?? [],
      'bookings': bookings ?? [],
      'location': location,
    };
  }

  static Future<Map<String, String>?> fetchVisitorDetails({
    required String userId,
  }) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('visitors')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;

        if (data == null) return null; // Handle null data safely

        return {
          "avatarUrl": data["avatarUrl"]?.toString() ?? "",
          "firstName": data["firstName"]?.toString() ?? "",
          "lastName": data["lastName"]?.toString() ?? "",
        };
      }
      return null;
    } catch (e) {
      print("Error fetching visitor details: $e"); // Use debugPrint in Flutter
      return null;
    }
  }
}
