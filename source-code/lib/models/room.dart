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

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      hotelId: json['hotelId'],
      name: json['name'],
      description: json['description'],
      capacity: json['capacity'],
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      images: List<String>.from(json['images']),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((facility) => facility as String)
              .toList() ??
          [],
      availability: RoomAvailability.fromJson(json['availability']),
    );
  }

  Map<String, dynamic> toJson() {
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
