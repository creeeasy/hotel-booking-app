class Amenity {
  final String label;
  final String iconPath;

  const Amenity({required this.label, required this.iconPath});
}

class AmenityIcons {
  static final Map<String, Amenity> amenities = {
    'wifi': const Amenity(label: 'WiFi', iconPath: 'assets/icons/wifi.svg'),
    'pool': const Amenity(label: 'Pool', iconPath: 'assets/icons/pool.svg'),
    'gym': const Amenity(label: 'Gym', iconPath: 'assets/icons/gym.svg'),
    'spa': const Amenity(label: 'Spa', iconPath: 'assets/icons/spa.svg'),
    'restaurant': const Amenity(
        label: 'Restaurant', iconPath: 'assets/icons/restaurant.svg'),
    'parking':
        const Amenity(label: 'Parking', iconPath: 'assets/icons/parking.svg'),
    'room_service': const Amenity(
        label: 'Room Service', iconPath: 'assets/icons/room_service.svg'),
    'playground': const Amenity(
        label: 'Kids’ Playground', iconPath: 'assets/icons/playground.svg'),
  };

  static Amenity? getAmenity(String amenity) {
    return amenities[amenity.toLowerCase()];
  }
}
