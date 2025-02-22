import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:fatiel/enum/user_role.dart';

class Hotel extends AuthUser {
  final String hotelName;
  final int? location;
  final List<Map<String, double>> ratings;
  final List<String>? images;
  final double? pricePerNight;
  final int availableRooms;
  final String? description;
  final String? thumbnail;
  final String? mapLink;
  final String? contactInfo;
  final List<String>? facilities;
  final String? checkInTime;
  final String? checkOutTime;

  Hotel({
    required super.id,
    required super.email,
    required super.isEmailVerified,
    required super.role,
    required this.hotelName,
    this.location,
    this.ratings = const [],
    this.images,
    this.availableRooms = 0,
    this.pricePerNight,
    this.description,
    this.thumbnail,
    this.mapLink,
    this.contactInfo,
    this.facilities,
    this.checkInTime,
    this.checkOutTime,
  });

  factory Hotel.fromFirebaseUser(
    AuthUser user, {
    String hotelName = '',
    int? location,
    List<Map<String, double>> ratings = const [],
    List<String>? images,
    int availableRooms = 0,
    double? pricePerNight,
    String? description,
    String? thumbnail,
    String? mapLink,
    String? contactInfo,
    List<String>? facilities,
    String? checkInTime,
    String? checkOutTime,
  }) {
    return Hotel(
      id: user.id,
      email: user.email,
      isEmailVerified: user.isEmailVerified,
      role: UserRole.hotel,
      hotelName: hotelName,
      location: location,
      ratings: ratings,
      images: images,
      availableRooms: availableRooms,
      pricePerNight: pricePerNight,
      description: description,
      thumbnail: thumbnail,
      mapLink: mapLink,
      contactInfo: contactInfo,
      facilities: facilities,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': hotelName,
      'email': email,
      'role': role.toString(),
      'location': location,
      'ratings': ratings,
      'images': images,
      'availableRooms': availableRooms,
      'pricePerNight': pricePerNight,
    };
  }

  factory Hotel.fromFirestore(DocumentSnapshot doc, String? hotelId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Hotel(
      id: hotelId ?? '',
      hotelName: data['hotelName'] as String? ?? '',
      email: '',
      role: UserRole.hotel,
      isEmailVerified: true,
      location: data['location'] as int?,
      ratings: (data['ratings'] as List<dynamic>?)
              ?.map((rating) => Map<String, double>.from(rating.map(
                  (key, value) => MapEntry(key, (value as num).toDouble()))))
              .toList() ??
          [],
      images: (data['images'] as List<dynamic>?)
              ?.map((image) => image as String)
              .toList() ??
          [],
      availableRooms: data['availableRooms'] as int? ?? 0,
      pricePerNight: (data['pricePerNight'] as num?)?.toDouble(),
      description: data['description'] as String?,
      thumbnail: data['thumbnail'] as String?,
      mapLink: data['mapLink'] as String?,
      contactInfo: data['contactInfo'] as String?,
      facilities: (data['facilities'] as List<dynamic>?)
              ?.map((facility) => facility as String)
              .toList() ??
          [],
      checkInTime: data['checkInTime'] as String?,
      checkOutTime: data['checkOutTime'] as String?,
    );
  }

  static Future<Hotel> getHotelById(String hotelId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotelId)
          .get();
      return Hotel.fromFirestore(doc, hotelId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<List<Hotel>> getHotelsByWilaya(int wilayaId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('location', isEqualTo: wilayaId)
          .get();

      return querySnapshot.docs
          .map((doc) => Hotel.fromFirestore(doc, doc.id))
          .toList();
    } catch (e) {
      log('Error fetching hotels by wilaya: $e');
      return [];
    }
  }

  static Future<bool> addHotelToFav({
    required String hotelId,
    required String visitorId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("visitors")
          .doc(visitorId)
          .update({
        "favorites": FieldValue.arrayUnion([hotelId]),
      });
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<bool> removeHotelFromFav({
    required String hotelId,
    required String visitorId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("visitors")
          .doc(visitorId)
          .update({
        "favorites": FieldValue.arrayRemove([hotelId]),
      });
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<Map<int, int>> getHotelStatistics() async {
    try {
      final hotelsSnapshot =
          await FirebaseFirestore.instance.collection("hotels").get();
      final List<Hotel> hotels = hotelsSnapshot.docs
          .map((doc) => Hotel.fromFirestore(doc, null))
          .toList();

      Map<int, int> wilayaHotelCount = {};

      for (var wilaya in Wilaya.wilayasList) {
        int count =
            hotels.where((hotel) => hotel.location == wilaya.ind).length;
        wilayaHotelCount[wilaya.ind] = count;
      }

      return wilayaHotelCount;
    } catch (e) {
      log(e.toString());
      return {};
    }
  }

  static Future<void> updateHotel(Hotel hotel) async {
    try {
      await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotel.id)
          .update(hotel.toFirestore());
    } catch (e) {
      log('Error updating hotel: $e');
      rethrow;
    }
  }

  static UserRole _parseRole(String roleString) {
    try {
      return UserRole.values.byName(roleString);
    } catch (e) {
      log('Invalid role string: $roleString. Defaulting to hotel.');
      return UserRole.hotel;
    }
  }

  @override
  String toString() {
    return '''
      Hotel(
        id: $id,
        name: $hotelName,
      )
    ''';
  }

  static Future<List<Hotel>> getPopularHotel() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('hotels').get();

      List<Hotel> hotels = querySnapshot.docs
          .map((doc) => Hotel.fromFirestore(doc, doc.id))
          .toList();

      // Sort hotels by average rating (descending)
      hotels.sort((a, b) {
        double averageRatingA = a.ratings.isNotEmpty
            ? a.ratings.map((r) => r.values.first).reduce((a, b) => a + b) /
                a.ratings.length
            : 0.0;
        double averageRatingB = b.ratings.isNotEmpty
            ? b.ratings.map((r) => r.values.first).reduce((a, b) => a + b) /
                b.ratings.length
            : 0.0;
        return averageRatingB.compareTo(averageRatingA);
      });

      return hotels;
    } catch (e) {
      log('Error fetching popular hotels: $e');
      return [];
    }
  }

  static Future<List<Hotel>> getNearMeHotel({int? userLocation}) async {
    if (userLocation == null) {
      return [];
    }
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('location', isEqualTo: userLocation)
          .get();

      List<Hotel> nearbyHotels = querySnapshot.docs
          .map((doc) => Hotel.fromFirestore(doc, doc.id))
          .toList();

      return nearbyHotels;
    } catch (e) {
      log('Error fetching nearby hotels: $e');
      return [];
    }
  }
}
