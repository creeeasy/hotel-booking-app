import 'package:iconsax/iconsax.dart';
import 'package:flutter/widgets.dart';

class AmenityIcon {
  final String label;
  final IconData icon;

  const AmenityIcon(this.icon, this.label);
}

class AmenityIcons {
  static final Map<String, AmenityIcon> amenities = {
    'wifi': const AmenityIcon(Iconsax.wifi, 'WiFi'),
    'pool': const AmenityIcon(Iconsax.drop, 'Pool'),
    'gym': const AmenityIcon(Iconsax.activity, 'Gym'),
    'restaurant': const AmenityIcon(Iconsax.cup, 'Restaurant'),
    'spa': const AmenityIcon(Iconsax.personalcard, 'Spa'),
    'parking': const AmenityIcon(Iconsax.car, 'Parking'),
    'room_service': const AmenityIcon(Iconsax.home, 'Room Service'),
    'playground': const AmenityIcon(Iconsax.game, 'Kids Playground'),
    'bar': const AmenityIcon(Iconsax.cup, 'Bar'),
    'concierge': const AmenityIcon(Iconsax.profile_2user, 'Concierge'),
    'business_center': const AmenityIcon(Iconsax.building_3, 'Business Center'),
    'laundry': const AmenityIcon(Iconsax.truck, 'Laundry'),
    'airport_shuttle': const AmenityIcon(Iconsax.airplane, 'Airport Shuttle'),
    'pet_friendly': const AmenityIcon(Iconsax.pet, 'Pet Friendly'),
    'disabled_facilities': const AmenityIcon(Iconsax.profile_add, 'Accessible'),
    'smoke_free': const AmenityIcon(Iconsax.close_circle, 'Smoke Free'),
    'beach_access': const AmenityIcon(Iconsax.sun_1, 'Beach Access'),
    'tv': const AmenityIcon(Iconsax.monitor, 'TV'),
    'ac': const AmenityIcon(Iconsax.wind, 'Air Conditioning'),
    'heating': const AmenityIcon(Iconsax.sun, 'Heating'),
    'safe': const AmenityIcon(Iconsax.security_card, 'Safe'),
    'kitchen': const AmenityIcon(Iconsax.home, 'Kitchen'),
    'minibar': const AmenityIcon(Iconsax.cup, 'Minibar'),
    'bathtub': const AmenityIcon(Iconsax.home, 'Bathtub'),
    'toiletries': const AmenityIcon(Iconsax.truck, 'Toiletries'),
  };

  static AmenityIcon? getAmenity(String amenity) =>
      amenities[amenity.toLowerCase()];

  static List<AmenityIcon> get allAmenities => amenities.values.toList();

  static List<String> get allAmenityLabels =>
      amenities.values.map((e) => e.label).toList()..sort();
}