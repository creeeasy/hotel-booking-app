import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fatiel/enum/review_update_type.dart';
import 'package:fatiel/enum/wilaya.dart';
import 'package:fatiel/models/rating.dart';

class Hotel {
  final String id;
  final String email;
  final String hotelName;
  final int? location;
  final Rating ratings;
  final List<String> images;
  final List<String> rooms;
  final String? description;
  final String? thumbnail;
  final String? mapLink;
  final String? contactInfo;
  final double? startingPricePerNight;
  final String? longitude;
  final String? latitude;

  Hotel({
    required this.id,
    required this.email,
    required this.hotelName,
    required this.images,
    this.description,
    this.thumbnail,
    this.location,
    Rating? ratings,
    this.mapLink,
    this.contactInfo,
    this.rooms = const [],
    this.startingPricePerNight,
    this.latitude,
    this.longitude,
  }) : ratings = ratings ?? Rating(rating: 0, totalRating: 0);

  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Hotel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      hotelName: data['hotelName'] as String? ?? '',
      location: data['location'] as int?,
      ratings: data['ratings'] != null
          ? Rating(
              rating: (data['ratings']['rating'] as num).toDouble(),
              totalRating: data['ratings']['total_rating'] as int,
            )
          : Rating(rating: 0, totalRating: 0),
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
      longitude: data['longitude'] as String?,
      latitude: data['latitude'] as String?,
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
      'longitude': longitude,
      'latitude': latitude,
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

  static Future<bool> updateHotelReview({
    required String hotelId,
    required ReviewUpdateType action,
    double? rating,
    double? oldRating, // Needed for updating
  }) async {
    try {
      final hotelRef =
          FirebaseFirestore.instance.collection('hotels').doc(hotelId);
      final hotelSnapshot = await hotelRef.get();

      final hotelData = hotelSnapshot.data();
      if (hotelData == null) return false;

      final ratings = hotelData['ratings'] as Map<String, dynamic>? ??
          {'rating': 0, 'total_rating': 0};
      double currentRating = (ratings['rating'] as num?)?.toDouble() ?? 0;
      int totalRatings = (ratings['total_rating'] as num?)?.toInt() ?? 0;

      if (action == ReviewUpdateType.add && rating != null) {
        double newTotal =
            ((currentRating * totalRatings) + rating) / (totalRatings + 1);
        await hotelRef.update({
          'ratings.rating': newTotal,
          'ratings.total_rating': totalRatings + 1,
        });
      } else if (action == ReviewUpdateType.update &&
          rating != null &&
          oldRating != null) {
        double newTotal =
            ((currentRating * totalRatings) - oldRating + rating) /
                totalRatings;
        await hotelRef.update({
          'ratings.rating': newTotal,
        });
      } else if (action == ReviewUpdateType.delete && rating != null) {
        if (totalRatings > 1) {
          double newTotal =
              ((currentRating * totalRatings) - rating) / (totalRatings - 1);
          await hotelRef.update({
            'ratings.rating': newTotal,
            'ratings.total_rating': totalRatings - 1,
          });
        } else {
          await hotelRef.update({
            'ratings.rating': 0,
            'ratings.total_rating': 0,
          });
        }
      }

      return true;
    } catch (e) {
      log('Error updating hotel review: $e');
      return false;
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

  static Future<List<Hotel>> getRecommendedHotels() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('hotels').get();
      final hotels =
          querySnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
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

  static Future<void> updateHotelDetails({
    required String hotelId,
    required int step,
    required String newValue,
  }) async {
    try {
      if (newValue.trim().isEmpty) {
        log("Error: Cannot update with an empty value.");
        return;
      }

      final hotelRef =
          FirebaseFirestore.instance.collection('hotels').doc(hotelId);

      final Map<int, String> stepFields = {
        0: 'location',
        1: 'description',
        2: 'mapLink',
        3: 'contactInfo',
      };

      if (!stepFields.containsKey(step)) {
        log("Error: Invalid step value ($step).");
        return;
      }

      final String fieldToUpdate = stepFields[step]!;
      dynamic updateData;

      if (step == 0) {
        final int? parsedLocation = int.tryParse(newValue);
        if (parsedLocation == null) {
          log("Error: Invalid integer value for location.");
          return;
        }
        updateData = parsedLocation;
      } else {
        updateData = newValue;
      }

      await hotelRef.update({fieldToUpdate: updateData});
    } catch (e) {
      log('Error updating hotel details: $e');
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
