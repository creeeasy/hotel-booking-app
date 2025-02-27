import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/enum/wilaya.dart';

class Hotel {
  final String id;
  final String email;
  final String hotelName;
  final int? location;
  final List<Map<String, double>> ratings;
  final List<String> images;
  final List<String> rooms;
  final String? description;
  final String? thumbnail;
  final String? mapLink;
  final String? contactInfo;
  final double? startingPricePerNight;

  Hotel({
    required this.id,
    required this.email,
    required this.hotelName,
    required this.images,
    this.description,
    this.thumbnail,
    this.location,
    this.ratings = const [],
    this.mapLink,
    this.contactInfo,
    this.rooms = const [],
    this.startingPricePerNight,
  });

  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Hotel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      hotelName: data['hotelName'] as String? ?? '',
      location: data['location'] as int?,
      ratings: (data['ratings'] as List<dynamic>?)?.map((rating) {
            return Map<String, double>.from(rating
                .map((key, value) => MapEntry(key, (value as num).toDouble())));
          }).toList() ??
          [],
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: data['description'] as String?,
      thumbnail: data['thumbnail'] as String?,
      mapLink: data['mapLink'] as String?,
      contactInfo: data['contactInfo'] as String?,
      rooms:
          (data['rooms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      startingPricePerNight:
          (data['startingPricePerNight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'hotelName': hotelName,
      'location': location,
      'ratings': ratings,
      'images': images,
      'description': description,
      'thumbnail': thumbnail,
      'mapLink': mapLink,
      'contactInfo': contactInfo,
      'rooms': rooms,
      'startingPricePerNight': startingPricePerNight,
    };
  }

  static Future<Hotel?> getHotelById(String hotelId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotelId)
          .get();
      if (doc.exists) {
        return Hotel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      log('Error fetching hotel by ID: $e');
      return null;
    }
  }

  static Future<List<Hotel>> getHotelsByWilaya(int wilayaId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('location', isEqualTo: wilayaId)
          .get();
      return querySnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    } catch (e) {
      log('Error fetching hotels by wilaya: $e');
      return [];
    }
  }

  static Future<bool> toggleFavorite({
    required String hotelId,
    required String visitorId,
    required bool isAdding,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("visitors")
          .doc(visitorId)
          .update({
        "favorites": isAdding
            ? FieldValue.arrayUnion([hotelId])
            : FieldValue.arrayRemove([hotelId]),
      });
      return true;
    } catch (e) {
      log('Error updating favorite hotels: $e');
      return false;
    }
  }

  static Future<Map<int, int>> getHotelStatistics() async {
    try {
      final hotelsSnapshot =
          await FirebaseFirestore.instance.collection("hotels").get();
      final hotels =
          hotelsSnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      return {
        for (var wilaya in Wilaya.wilayasList)
          wilaya.ind:
              hotels.where((hotel) => hotel.location == wilaya.ind).length
      };
    } catch (e) {
      log('Error fetching hotel statistics: $e');
      return {};
    }
  }

  static Future<List<Hotel>> getPopularHotels() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('hotels').get();
      final hotels =
          querySnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
      hotels.sort((a, b) {
        double avgA = a.ratings.isNotEmpty
            ? a.ratings.map((r) => r.values.first).reduce((a, b) => a + b) /
                a.ratings.length
            : 0.0;
        double avgB = b.ratings.isNotEmpty
            ? b.ratings.map((r) => r.values.first).reduce((a, b) => a + b) /
                b.ratings.length
            : 0.0;
        return avgB.compareTo(avgA);
      });
      return hotels;
    } catch (e) {
      log('Error fetching popular hotels: $e');
      return [];
    }
  }

  static Future<List<Hotel>> findHotelsByKeyword(String query) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .get();
      return querySnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    } catch (e) {
      log('Error searching for hotel: $e');
      return [];
    }
  }

  static Future<List<Hotel>> getNearbyHotels(int? userLocation) async {
    if (userLocation == null) return [];
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('location', isEqualTo: userLocation)
          .get();
      return querySnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    } catch (e) {
      log('Error fetching nearby hotels: $e');
      return [];
    }
  }
}
