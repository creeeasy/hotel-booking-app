import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/constants/hotel_price_ranges.dart';
import 'package:fatiel/enum/activity_type.dart';
import 'package:fatiel/enum/review_update_type.dart';
import 'package:fatiel/models/activity_item.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/models/rating.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/utils/generate_search_keywords.dart';
import 'package:iconsax/iconsax.dart';

class Hotel {
  final String id;
  final String email;
  final String hotelName;
  final int? location;
  final Rating ratings;
  final List<String> images;
  final int? totalRooms;
  final String? description;
  final String? mapLink;
  final String? contactInfo;
  final List<String>? searchKeywords;

  Hotel({
    required this.id,
    required this.email,
    required this.hotelName,
    required this.images,
    this.description,
    this.location,
    Rating? ratings,
    this.totalRooms = 0,
    this.mapLink,
    this.contactInfo,
    this.searchKeywords = const [],
  }) : ratings = ratings ?? Rating(rating: 0, totalRating: 0);
  Hotel copyWith({
    String? id,
    String? email,
    String? hotelName,
    int? location,
    List<String>? images,
    int? totalRooms,
    String? description,
    String? mapLink,
    String? contactInfo,
    List<String>? searchKeywords,
    Rating? ratings,
  }) {
    return Hotel(
      id: id ?? this.id,
      email: email ?? this.email,
      hotelName: hotelName ?? this.hotelName,
      location: location ?? this.location,
      images: images ?? this.images,
      totalRooms: totalRooms ?? this.totalRooms,
      description: description ?? this.description,
      mapLink: mapLink ?? this.mapLink,
      contactInfo: contactInfo ?? this.contactInfo,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      ratings: ratings ?? this.ratings,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'hotelName': hotelName,
      'location': location,
      'images': images,
      'totalRooms': totalRooms,
      'description': description,
      'mapLink': mapLink,
      'contactInfo': contactInfo,
      'searchKeywords': searchKeywords,
      'ratings': {
        'rating': ratings.rating,
        'totalRating': ratings.totalRating,
      },
    };
  }

  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Hotel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      hotelName: data['hotelName'] as String? ?? '',
      location: data['location'] as int?,
      totalRooms: data['totalRooms'] as int?,
      ratings: data['ratings'] != null
          ? Rating(
              rating: (data['ratings']?['rating'] as num? ?? 0).toDouble(),
              totalRating: (data['ratings']?['totalRating'] as int?) ?? 0,
            )
          : Rating(rating: 0, totalRating: 0),
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: data['description'] as String?,
      mapLink: data['mapLink'] as String?,
      contactInfo: data['contactInfo'] as String?,
      searchKeywords: (data['searchKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
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
      'mapLink': mapLink,
      'contactInfo': contactInfo,
      'totalRooms': totalRooms,
      'searchKeywords': searchKeywords
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
    double? oldRating,
  }) async {
    try {
      final hotelRef =
          FirebaseFirestore.instance.collection('hotels').doc(hotelId);
      final hotelSnapshot = await hotelRef.get();

      final hotelData = hotelSnapshot.data();
      if (hotelData == null) return false;

      final ratings = hotelData['ratings'] as Map<String, dynamic>? ??
          {'rating': 0, 'totalRating': 0};
      double currentRating = (ratings['rating'] as num?)?.toDouble() ?? 0;
      int totalRatings = (ratings['totalRating'] as num?)?.toInt() ?? 0;

      if (action == ReviewUpdateType.add && rating != null) {
        double newTotal =
            ((currentRating * totalRatings) + rating) / (totalRatings + 1);
        await hotelRef.update({
          'ratings.rating': newTotal,
          'ratings.totalRating': totalRatings + 1,
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
            'ratings.totalRating': totalRatings - 1,
          });
        } else {
          await hotelRef.update({
            'ratings.rating': 0,
            'ratings.totalRating': 0,
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

  static Future<List<Hotel>> findHotelsByKeyword(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final keywords = query.trim().toLowerCase().split(' ');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('searchKeywords', arrayContainsAny: keywords)
          .get();

      return querySnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    } catch (e, stackTrace) {
      log('Error searching for hotel: $e\n$stackTrace');
      return [];
    }
  }

  static Future<List<Hotel>> filterHotels(
      {required HotelFilterParameters params}) async {
    try {
      final HotelFilterParameters(
        :maxPeople,
        :location,
        :minPeople,
        :minPrice,
        :minRating,
        :maxRating
      ) = params;
      Query hotelQuery = FirebaseFirestore.instance.collection('hotels');

      if (minRating != null && minRating > 0) {
        hotelQuery = hotelQuery.where('ratings.rating',
            isGreaterThanOrEqualTo: minRating);
      }
      if (maxRating != null && maxRating < 5) {
        hotelQuery =
            hotelQuery.where('ratings.rating', isLessThanOrEqualTo: maxRating);
      }

      if (location != null) {
        hotelQuery = hotelQuery.where('location', isEqualTo: location);
      }

      QuerySnapshot hotelSnapshot = await hotelQuery.get();
      List<Hotel> hotels =
          hotelSnapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();

      if (hotels.isEmpty) return [];

      List<String> hotelIds = hotels.map((hotel) => hotel.id).toList();

      Query roomQuery = FirebaseFirestore.instance
          .collection('rooms')
          .where('hotelId', whereIn: hotelIds);

      if (minPrice != null) {
        roomQuery =
            roomQuery.where('pricePerNight', isGreaterThanOrEqualTo: minPrice);
      }

      final maxPrice = minPrice != null
          ? priceRanges.firstWhere((range) => range["min"] == minPrice,
              orElse: () => {"max": null})["max"]
          : null;

      if (maxPrice != null) {
        roomQuery =
            roomQuery.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }

      QuerySnapshot roomSnapshot = await roomQuery.get();
      List<QueryDocumentSnapshot> filteredRooms =
          roomSnapshot.docs.where((doc) {
        int capacity = doc['capacity'] as int;
        bool meetsMinPeople = minPeople == null || capacity >= minPeople;
        bool meetsMaxPeople = maxPeople == null || capacity <= maxPeople;
        return meetsMinPeople && meetsMaxPeople;
      }).toList();

      Set<String> matchingHotelIds =
          filteredRooms.map((doc) => doc['hotelId'] as String).toSet();

      return hotels
          .where((hotel) => matchingHotelIds.contains(hotel.id))
          .toList();
    } catch (e) {
      print(e);
      log('Error filtering hotels: $e');
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
      late String text;
      if (step == 0) {
        final int? parsedLocation = int.tryParse(newValue);
        if (parsedLocation == null) {
          log("Error: Invalid integer value for location.");
          return;
        }
        updateData = parsedLocation;
        text = Wilaya.fromIndex(updateData)!.name;
      } else {
        updateData = newValue;
        text = updateData;
      }
      final updatePayload = {fieldToUpdate: updateData};
      if (step != 2) {
        final searchWords = generateSearchKeywords(text);
        updatePayload['searchKeywords'] = FieldValue.arrayUnion(searchWords);
      }

      await hotelRef.update(updatePayload);
    } catch (e) {
      log('Error updating hotel details: $e');
    }
  }

  static Future<List<Hotel>> getNearbyHotels(
    int? userLocation, {
    HotelFilterParameters? params,
    int limit = 0, // limit determines filtering criteria
  }) async {
    if (userLocation == null) return []; // Early return if location is null

    try {
      Query hotelQuery = FirebaseFirestore.instance
          .collection('hotels')
          .where('location', isEqualTo: userLocation);

      if (params != null) {
        final HotelFilterParameters(:minRating, :maxRating) = params;

        if (minRating != null && minRating > 0) {
          hotelQuery = hotelQuery.where('ratings.rating',
              isGreaterThanOrEqualTo: minRating);
        }
        if (maxRating != null && maxRating < 5) {
          hotelQuery = hotelQuery.where('ratings.rating',
              isLessThanOrEqualTo: maxRating);
        }
      }

      if (limit > 0) {
        hotelQuery = hotelQuery.limit(limit);
      }

      final hotels =
          (await hotelQuery.get()).docs.map(Hotel.fromFirestore).toList();
      if (hotels.isEmpty || limit == 0) return hotels;

      final hotelIds = hotels.map((hotel) => hotel.id).toList();
      Query roomQuery = _buildRoomQuery(hotelIds, params);

      final matchingHotelIds =
          await _filterRoomIdsByCapacity(roomQuery, params);
      final filteredHotels =
          hotels.where((hotel) => matchingHotelIds.contains(hotel.id)).toList();
      return limit > 0 ? filteredHotels.take(limit).toList() : filteredHotels;
    } catch (e) {
      print(e);
      log('Error fetching nearby hotels: $e');
      return [];
    }
  }

  static Future<List<Hotel>> getRecommendedHotels({
    required HotelFilterParameters params,
    int limit = 0,
  }) async {
    try {
      Query hotelQuery = _buildHotelQuery(params, limit);

      final hotels =
          (await hotelQuery.get()).docs.map(Hotel.fromFirestore).toList();
      if (hotels.isEmpty || limit == 0) return hotels;

      final filteredHotels = await _filterHotelsByRooms(hotels, params);
      return limit > 0 ? filteredHotels.take(limit).toList() : filteredHotels;
    } catch (e) {
      log('Error fetching recommended hotels: $e');
      return [];
    }
  }

  static Query _buildHotelQuery(HotelFilterParameters params, int limit) {
    Query query = FirebaseFirestore.instance.collection('hotels');

    if (params.minRating != null && params.minRating! > 0) {
      query = query.where('ratings.rating',
          isGreaterThanOrEqualTo: params.minRating);
    }
    if (params.maxRating != null && params.maxRating! < 5) {
      query =
          query.where('ratings.rating', isLessThanOrEqualTo: params.maxRating);
    }
    if (params.location != null) {
      query = query.where('location', isEqualTo: params.location);
    }
    return limit > 0 ? query.limit(limit) : query;
  }

  static Query _buildRoomQuery(
      List<String> hotelIds, HotelFilterParameters? params) {
    Query query = FirebaseFirestore.instance
        .collection('rooms')
        .where('hotelId', whereIn: hotelIds);

    if (params != null && params.minPrice != null) {
      query =
          query.where('pricePerNight', isGreaterThanOrEqualTo: params.minPrice);
      final maxPrice = priceRanges.firstWhere(
          (range) => range['min'] == params.minPrice,
          orElse: () => {'max': null})['max'];
      if (maxPrice != null) {
        query = query.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }
    }
    return query;
  }

  static Future<Set<String>> _filterRoomIdsByCapacity(
      Query roomQuery, HotelFilterParameters? params) async {
    final snapshot = await roomQuery.get();
    return snapshot.docs
        .where((doc) {
          final capacity = doc['capacity'] as int;
          return (params?.minPeople == null ||
                  capacity >= params!.minPeople!) &&
              (params?.maxPeople == null || capacity <= params!.maxPeople!);
        })
        .map((doc) => doc['hotelId'] as String)
        .toSet();
  }

  static Future<List<Hotel>> _filterHotelsByRooms(
      List<Hotel> hotels, HotelFilterParameters params) async {
    final hotelIds = hotels.map((hotel) => hotel.id).toList();
    Query roomQuery = _buildRoomQuery(hotelIds, params);

    final matchingHotelIds = await _filterRoomIdsByCapacity(roomQuery, params);
    return hotels
        .where((hotel) => matchingHotelIds.contains(hotel.id))
        .toList();
  }

  static const int maxRecentActivities = 5;
  static const Duration recentActivityPeriod = Duration(days: 7);

  static Future<List<ActivityItem>> getRecentActivity({
    required String hotelId,
  }) async {
    try {
      final recentBookings = _getRecentBookings(hotelId);
      final recentReviews = _getRecentReviews(hotelId);
      final results = await Future.wait([recentBookings, recentReviews]);
      final allActivities = [...results[0], ...results[1]];
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allActivities.take(maxRecentActivities).toList();
    } catch (e) {
      print('Error fetching recent activity: $e');
      return [];
    }
  }

  static Future<List<ActivityItem>> _getRecentBookings(String hotelId) async {
    final cutoffDate = DateTime.now().subtract(recentActivityPeriod);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('hotelId', isEqualTo: hotelId)
        .where('createdAt', isGreaterThanOrEqualTo: cutoffDate)
        .orderBy('createdAt', descending: true)
        .limit(maxRecentActivities)
        .get();

    final activities = <ActivityItem>[];

    for (final doc in querySnapshot.docs) {
      final booking = Booking.fromFirestore(doc);
      final visitor = await Visitor.getVisitorById(booking.visitorId);
      final room = await Room.getRoomById(booking.roomId);

      activities.add(ActivityItem(
        type: ActivityType.booking,
        title: 'New Booking',
        description:
            '${visitor!.firstName} ${visitor.lastName} booked ${room!.name}',
        timestamp: booking.createdAt,
        icon: Iconsax.calendar_add,
      ));
    }

    return activities;
  }

  static Future<List<ActivityItem>> _getRecentReviews(String hotelId) async {
    final cutoffDate = DateTime.now().subtract(recentActivityPeriod);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('hotelId', isEqualTo: hotelId)
        .where('createdAt', isGreaterThanOrEqualTo: cutoffDate)
        .orderBy('createdAt', descending: true)
        .limit(maxRecentActivities)
        .get();

    final activities = <ActivityItem>[];

    for (final doc in querySnapshot.docs) {
      final review = Review.fromFirestore(doc);
      final visitor = await Visitor.getVisitorById(review.visitorId);

      activities.add(ActivityItem(
        type: ActivityType.review,
        title: 'New Review',
        description:
            '${visitor!.firstName} ${visitor.lastName} left a ${review.rating}-star review',
        timestamp: review.createdAt,
        icon: Iconsax.star,
      ));
    }

    return activities;
  }

  static Future<void> updateHotel({required Hotel hotel}) async {
    try {
      await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotel.id)
          .update(hotel.toUpdateMap());
    } catch (e) {
      log('An error occured $e');
      rethrow;
    }
  }
}
