import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/avatar_action.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/booking/booking_service.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/services/room/room_service.dart';

class VisitorService {
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
      final booking = await BookingService.getBookingById(bookingId);
      final hotel = await HotelService.getHotelById(booking.hotelId);
      final room = await RoomService.getRoomById(booking.roomId);
      final visitor = await VisitorService.getVisitorById(booking.visitorId);
      return {
        'booking': booking,
        'hotel': hotel,
        'room': room,
        'visitor': visitor,
      };
    } catch (e) {
      print('Error fetching booking or hotel: $e');
      return null;
    }
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

        if (data == null) return null;

        return {
          'avatarURL': data['avatarURL']?.toString() ?? '',
          'firstName': data['firstName']?.toString() ?? '',
          'lastName': data['lastName']?.toString() ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Error fetching visitor details: $e');
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
        log('Error: Cannot update with an empty value.');
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
        log('Error: Invalid step value ($step).');
        return;
      }

      final String fieldToUpdate = stepFields[step]!;
      dynamic updateData;

      if (step == 2) {
        final int? parsedLocation = int.tryParse(newValue);
        if (parsedLocation == null) {
          log('Error: Invalid integer value for location.');
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
          .update({'avatarURL': updatedAvatarUrl});

      log('Visitor avatar ${action == AvatarAction.update ? 'updated' : 'removed'} successfully.');
    } catch (e, stackTrace) {
      log('Error modifying visitor avatar: $e', stackTrace: stackTrace);
    }
  }
}
