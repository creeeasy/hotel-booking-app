import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/widgets.dart';

class Amenity {
  final String label;
  final IconData icon;

  const Amenity({required this.label, required this.icon});
}

class AmenityIcons {
  static final Map<String, Amenity> amenities = {
    'wifi': const Amenity(label: 'WiFi', icon: FontAwesomeIcons.wifi),
    'pool': const Amenity(label: 'Pool', icon: FontAwesomeIcons.swimmingPool),
    'gym': const Amenity(label: 'Gym', icon: FontAwesomeIcons.dumbbell),
    'spa': const Amenity(label: 'Spa', icon: FontAwesomeIcons.spa),
    'restaurant':
        const Amenity(label: 'Restaurant', icon: FontAwesomeIcons.utensils),
    'parking': const Amenity(label: 'Parking', icon: FontAwesomeIcons.parking),
    'room_service': const Amenity(
        label: 'Room Service', icon: FontAwesomeIcons.conciergeBell),
    'playground':
        const Amenity(label: 'Kids’ Playground', icon: FontAwesomeIcons.child),
  };

  static Amenity? getAmenity(String amenity) {
    return amenities[amenity.toLowerCase()];
  }
}
