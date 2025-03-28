import 'package:iconsax/iconsax.dart';
import 'package:flutter/widgets.dart';

class AmenityIcon {
  final String label;
  final IconData icon;

  const AmenityIcon(this.icon, this.label);
}

class AmenityIcons {
  static final Map<String, AmenityIcon> amenities = {
    // Basic Amenities
    'wifi': const AmenityIcon(Iconsax.wifi, 'WiFi'),
    'pool': const AmenityIcon(Iconsax.drop, 'Pool'),
    'gym': const AmenityIcon(Iconsax.activity, 'Gym'),
    'spa': const AmenityIcon(Iconsax.health, 'Spa'),
    'restaurant': const AmenityIcon(Iconsax.cup, 'Restaurant'),
    'parking': const AmenityIcon(Iconsax.car, 'Parking'),
    'room_service': const AmenityIcon(Iconsax.box, 'Room Service'),
    'playground': const AmenityIcon(Iconsax.game, 'Kids Playground'),
    'bar': const AmenityIcon(Iconsax.cup, 'Bar'), // Using cup for bar

    // Facility Services
    'concierge': const AmenityIcon(Iconsax.profile_2user, 'Concierge'),
    'business_center': const AmenityIcon(Iconsax.building_3, 'Business Center'),
    'laundry': const AmenityIcon(Iconsax.home, 'Laundry'),
    'airport_shuttle': const AmenityIcon(Iconsax.car, 'Airport Shuttle'),

    // Special Features
    'pet_friendly': const AmenityIcon(Iconsax.pet, 'Pet Friendly'),
    'disabled_facilities': const AmenityIcon(Iconsax.profile_add, 'Accessible'),
    'smoke_free': const AmenityIcon(Iconsax.close_circle, 'Smoke Free'),
    'beach_access': const AmenityIcon(Iconsax.sun_1, 'Beach Access'),

    // Room Amenities
    'tv': const AmenityIcon(Iconsax.monitor, 'TV'),
    'ac': const AmenityIcon(Iconsax.wind, 'Air Conditioning'),
    'heating': const AmenityIcon(Iconsax.sun, 'Heating'),
    'safe': const AmenityIcon(Iconsax.security_card, 'Safe'),
    'kitchen': const AmenityIcon(Iconsax.box, 'Kitchen'), // Alternative
    'minibar': const AmenityIcon(Iconsax.box, 'Minibar'),
    'bathtub': const AmenityIcon(Iconsax.home, 'Bathtub'),
    'toiletries': const AmenityIcon(Iconsax.box, 'Toiletries'),
  };

  // Get amenity by key
  static AmenityIcon? getAmenity(String amenity) {
    return amenities[amenity.toLowerCase()];
  }

  // Get all amenities as a list
  static List<AmenityIcon> get allAmenities => amenities.values.toList();

  // Get sorted list of amenity labels
  static List<String> get allAmenityLabels =>
      amenities.values.map((e) => e.label).toList()..sort();
}
