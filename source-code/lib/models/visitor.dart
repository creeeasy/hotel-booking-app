import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/avatar_action.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/room.dart';

class Visitor {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String>? favorites;
  final List<String>? bookings;
  final int? location;
  final String? avatarURL;

  Visitor(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      this.favorites,
      this.bookings,
      this.location,
      this.avatarURL});

  factory Visitor.fromFirebaseUser({
    required String id,
    required String email,
    required bool isEmailVerified,
    String? firstName,
    String? lastName,
    List<String>? favorites,
    List<String>? bookings,
    int? location,
    String? avatarURL,
  }) {
    return Visitor(
      id: id,
      email: email,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      favorites: favorites ?? [],
      bookings: bookings ?? [],
      location: location,
      avatarURL: avatarURL,
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
      "avatarURL": avatarURL
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
      avatarURL: data['avatarURL'] as String?,
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
      final room = await Room.getRoomById(booking.roomId);
      return {
        "booking": booking,
        "hotel": hotel,
        "room": room,
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
      'avatarURL': avatarURL,
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
          "avatarURL": data["avatarURL"]?.toString() ?? "",
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

  static Future<void> updateUserProfile({
    required String visitorId,
    required int step,
    required String newValue,
  }) async {
    try {
      if (newValue.trim().isEmpty) {
        log("Error: Cannot update with an empty value.");
        return;
      }

      final userRef =
          FirebaseFirestore.instance.collection('visitors').doc(visitorId);

      final Map<int, String> stepFields = {
        0: 'firstName',
        1: 'lastName',
        2: 'location',
      };

      if (!stepFields.containsKey(step)) {
        log("Error: Invalid step value ($step).");
        return;
      }

      final String fieldToUpdate = stepFields[step]!;
      dynamic updateData;

      if (step == 2) {
        final int? parsedLocation = int.tryParse(newValue);
        if (parsedLocation == null) {
          log("Error: Invalid integer value for location.");
          return;
        }
        updateData = parsedLocation;
      } else {
        updateData = newValue;
      }

      final updatePayload = {fieldToUpdate: updateData};

      await userRef.update(updatePayload);
    } catch (e) {
      log('Error updating user profile: $e');
    }
  }

  static Future<void> modifyVisitorAvatar({
    required String visitorId,
    required AvatarAction action,
    String? newAvatarUrl,
  }) async {
    try {
      final String? updatedAvatarUrl =
          (action == AvatarAction.update) ? newAvatarUrl : null;

      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitorId)
          .update({"avatarURL": updatedAvatarUrl});

      log('Visitor avatar ${action == AvatarAction.update ? "updated" : "removed"} successfully.');
    } catch (e, stackTrace) {
      log('Error modifying visitor avatar: $e', stackTrace: stackTrace);
    }
  }
}
