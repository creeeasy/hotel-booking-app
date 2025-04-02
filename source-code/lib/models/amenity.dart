import 'package:fatiel/l10n/l10n.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/widgets.dart';

class AmenityIcon {
  final String label;
  final IconData icon;

  const AmenityIcon(this.icon, this.label);

  static String getLocalizedLabel(String amenity, BuildContext context) {
    final l10n = L10n.of(context);

    // First try to match by key
    final normalizedAmenity = amenity.toLowerCase().replaceAll(' ', '_');
    switch (normalizedAmenity) {
      case 'wifi':
      case 'wi-fi':
        return l10n.amenityWifi;
      case 'pool':
        return l10n.amenityPool;
      case 'gym':
      case 'fitness_center':
        return l10n.amenityGym;
      case 'restaurant':
        return l10n.amenityRestaurant;
      case 'spa':
        return l10n.amenitySpa;
      case 'parking':
        return l10n.amenityParking;
      case 'room_service':
      case 'roomservice':
        return l10n.amenityRoomService;
      case 'playground':
        return l10n.amenityPlayground;
      case 'bar':
        return l10n.amenityBar;
      case 'concierge':
        return l10n.amenityConcierge;
      case 'business_center':
      case 'businesscenter':
        return l10n.amenityBusinessCenter;
      case 'laundry':
        return l10n.amenityLaundry;
      case 'airport_shuttle':
      case 'airportshuttle':
        return l10n.amenityAirportShuttle;
      case 'pet_friendly':
      case 'petfriendly':
        return l10n.amenityPetFriendly;
      case 'disabled_facilities':
      case 'accessible':
        return l10n.amenityAccessible;
      case 'smoke_free':
      case 'smokefree':
        return l10n.amenitySmokeFree;
      case 'beach_access':
      case 'beachaccess':
        return l10n.amenityBeachAccess;
      case 'tv':
        return l10n.amenityTv;
      case 'ac':
      case 'air_conditioning':
        return l10n.amenityAc;
      case 'heating':
        return l10n.amenityHeating;
      case 'safe':
        return l10n.amenitySafe;
      case 'kitchen':
        return l10n.amenityKitchen;
      case 'minibar':
        return l10n.amenityMinibar;
      case 'bathtub':
        return l10n.amenityBathtub;
      case 'toiletries':
        return l10n.amenityToiletries;
      default:
        final matchedAmenity = AmenityIcons.amenities.values.firstWhere(
          (a) => a.label.toLowerCase() == amenity.toLowerCase(),
          orElse: () => AmenityIcon(Iconsax.box, amenity),
        );
        if (matchedAmenity.label != amenity) {
          return getLocalizedLabel(matchedAmenity.label, context);
        }
        return amenity;
    }
  }
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
