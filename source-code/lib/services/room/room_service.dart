import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/room.dart';

class RoomService {
  static Future<List<Room>> getHotelRoomsById(String hotelId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .get();

      return querySnapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    } catch (e) {
      log('Error fetching hotel rooms: $e');
      return [];
    }
  }

  static Future<Room?> getRoomById(String roomId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();
      if (doc.exists) {
        return Room.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      log('Error fetching room by ID: $e');
      return null;
    }
  }
}
