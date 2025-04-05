import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/hotel.dart';
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

  static Future<String> getStartingPrice(Hotel hotel) async {
    try {
      final rooms = await RoomService.getHotelRoomsById(hotel.id);

      if (rooms.isEmpty) {
        return '--';
      }

      double lowestPrice = rooms.first.pricePerNight;
      for (final room in rooms) {
        if (room.pricePerNight < lowestPrice) {
          lowestPrice = room.pricePerNight;
        }
      }

      return lowestPrice.toStringAsFixed(2);
    } catch (e) {
      log('Error getting starting price: $e');
      return '--';
    }
  }

  static Future<void> addOrUpdateRoom({
    required String hotelId,
    required String name,
    required String description,
    required double pricePerNight,
    required int capacity,
    required List<String> amenities,
    required List<String> images,
    bool isAvailable = false,
    String? roomId,
  }) async {
    try {
      final roomData = {
        'hotelId': hotelId,
        'name': name,
        'description': description,
        'pricePerNight': pricePerNight,
        'capacity': capacity,
        'amenities': amenities,
        'images': images,
        'availability': {
          'isAvailable': isAvailable,
          'nextAvailableDate': null,
        },
      };

      if (roomId != null) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .update(roomData);
      } else {
        await FirebaseFirestore.instance.collection('rooms').add(roomData);
        final roomCount = await getTotalRoomsCount(hotelId);
        await FirebaseFirestore.instance
            .collection('hotels')
            .doc(hotelId)
            .update({'totalRooms': roomCount});
      }
    } catch (e) {
      log('Error adding/updating room: $e');
      throw Exception('Failed to add/update room');
    }
  }

  static Future<void> deleteRoom(Room room) async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(room.id)
          .delete();
      final roomCount = await getTotalRoomsCount(room.hotelId);
      await FirebaseFirestore.instance
          .collection('hotels')
          .doc(room.hotelId)
          .update({'totalRooms': roomCount});
    } catch (e) {
      log('Error deleting room: $e');
      throw Exception('Failed to delete room');
    }
  }

  static Future<void> toggleRoomAvailability(Room room) async {
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
        'availability.isAvailable': !room.availability.isAvailable,
        'availability.nextAvailableDate': null,
      });
    } catch (e) {
      log('Error toggling room availability: $e');
      throw Exception('Failed to toggle room availability');
    }
  }

  static Future<int> getTotalRoomsCount(String hotelId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      log('Error counting hotel rooms: $e');
      return 0;
    }
  }
}
