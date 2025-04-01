import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/room_availability.dart';

class Room {
  final String id;
  final String hotelId;
  final String name;
  final String description;
  final int capacity;
  final double pricePerNight;
  final List<String> images;
  final List<String> amenities;
  final RoomAvailability availability;

  Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.capacity,
    required this.pricePerNight,
    required this.images,
    required this.amenities,
    required this.availability,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Room(
      id: doc.id,
      hotelId: data['hotelId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      capacity: data['capacity'] as int? ?? 0,
      pricePerNight: (data['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      amenities: (data['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      availability: RoomAvailability.fromJson(
          data['availability'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'hotelId': hotelId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'pricePerNight': pricePerNight,
      'images': images,
      'amenities': amenities,
      'availability': availability.toJson(),
    };
  }
}
