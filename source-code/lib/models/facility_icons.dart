class FacilityIcon {
  final String name;
  final String svgPath;

  FacilityIcon({required this.name, required this.svgPath});
}

class FacilityIcons {
  static final Map<String, FacilityIcon> facilities = {
    'wifi': FacilityIcon(name: 'WiFi', svgPath: 'assets/icons/wifi.svg'),
    'pool': FacilityIcon(name: 'Pool', svgPath: 'assets/icons/pool.svg'),
    'gym': FacilityIcon(name: 'Gym', svgPath: 'assets/icons/gym.svg'),
    'spa': FacilityIcon(name: 'Spa', svgPath: 'assets/icons/spa.svg'),
    'restaurant': FacilityIcon(
        name: 'Restaurant', svgPath: 'assets/icons/restaurant.svg'),
    'parking':
        FacilityIcon(name: 'Parking', svgPath: 'assets/icons/parking.svg'),
    'room_service': FacilityIcon(
        name: 'Room Service', svgPath: 'assets/icons/room_service.svg'),
    'playground': FacilityIcon(
        name: 'Kids’ Playground', svgPath: 'assets/icons/playground.svg'),
  };

  static FacilityIcon getFacility(String facility) {
    return facilities[facility.toLowerCase()]!;
  }
}
