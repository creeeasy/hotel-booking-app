import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/constants/hotel_price_ranges.dart';
import 'package:fatiel/enum/activity_type.dart';
import 'package:fatiel/enum/review_update_type.dart';
import 'package:fatiel/models/activity_item.dart';
import 'package:fatiel/models/booking.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/hotel_filter_parameters.dart';
import 'package:fatiel/models/review.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/services/room/room_service.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:fatiel/utils/generate_search_keywords.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HotelService {
  static const int maxRecentActivities = 5;
  static const Duration recentActivityPeriod = Duration(days: 7);

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

  static final CollectionReference<Map<String, dynamic>> _hotelsCollection =
      FirebaseFirestore.instance.collection('hotels');

  static final CollectionReference<Map<String, dynamic>> _roomsCollection =
      FirebaseFirestore.instance.collection('rooms');

  static Future<List<Hotel>> getRecommendedHotels({
    required HotelFilterParameters params,
  }) async {
    try {
      final hotels = await _getFilteredHotels(params);
      if (hotels.isEmpty) return hotels;
      return await _filterHotelsByRoomAvailability(hotels, params);
    } catch (e) {
      log('Error fetching recommended hotels: $e');
      return [];
    }
  }

  static Future<List<Hotel>> getNearbyHotels(
    int? userLocation, {
    HotelFilterParameters? params,
  }) async {
    if (userLocation == null) return [];

    try {
      Query<Map<String, dynamic>> hotelQuery = _hotelsCollection.where(
        'location',
        isEqualTo: userLocation,
      );

      final paramsWithoutLocation = params != null
          ? HotelFilterParameters(
              minRating: params.minRating,
              maxRating: params.maxRating,
              minPrice: params.minPrice,
              minPeople: params.minPeople,
              maxPeople: params.maxPeople,
              location: null,
            )
          : null;

      if (paramsWithoutLocation != null) {
        hotelQuery = _applyHotelFilters(hotelQuery, paramsWithoutLocation);
      }

      final hotels = (await hotelQuery.get())
          .docs
          .map((doc) => Hotel.fromFirestore(doc))
          .toList();
      if (hotels.isEmpty) return [];
      return paramsWithoutLocation != null
          ? await _filterHotelsByRoomAvailability(hotels, paramsWithoutLocation)
          : hotels;
    } catch (e) {
      log('Error fetching nearby hotels: $e');
      return [];
    }
  }

  static Future<List<Hotel>> _getFilteredHotels(
      HotelFilterParameters params) async {
    Query<Map<String, dynamic>> query = _hotelsCollection;
    query = _applyHotelFilters(query, params);
    final snapshot = await query.get();
    return snapshot.docs.map(Hotel.fromFirestore).toList();
  }

  static Query<Map<String, dynamic>> _applyHotelFilters(
    Query<Map<String, dynamic>> query,
    HotelFilterParameters params,
  ) {
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
    return query;
  }

  static Future<List<Hotel>> _filterHotelsByRoomAvailability(
    List<Hotel> hotels,
    HotelFilterParameters params,
  ) async {
    if (!_needsRoomFiltering(params)) return hotels;

    final hotelIds = hotels.map((hotel) => hotel.id).toList();
    final matchingHotelIds = await _getMatchingRoomHotelIds(hotelIds, params);
    return hotels
        .where((hotel) => matchingHotelIds.contains(hotel.id))
        .toList();
  }

  static Future<Set<String>> _getMatchingRoomHotelIds(
    List<String> hotelIds,
    HotelFilterParameters params,
  ) async {
    Query<Map<String, dynamic>> roomQuery = _roomsCollection.where(
      'hotelId',
      whereIn: hotelIds,
    );

    roomQuery = _applyRoomFilters(roomQuery, params);

    final snapshot = await roomQuery.get();
    return snapshot.docs
        .where((doc) => _matchesCapacity(doc, params))
        .map((doc) => doc['hotelId'] as String)
        .toSet();
  }

  static Query<Map<String, dynamic>> _applyRoomFilters(
    Query<Map<String, dynamic>> query,
    HotelFilterParameters params,
  ) {
    if (params.minPrice != null) {
      query = query.where(
        'pricePerNight',
        isGreaterThanOrEqualTo: params.minPrice!.toDouble(),
      );

      final maxPrice = _getMaxPriceForRange(params.minPrice!.toDouble());
      if (maxPrice != null) {
        query = query.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }
    }
    return query;
  }

  static double? _getMaxPriceForRange(double minPrice) {
    final range = priceRanges.firstWhere(
      (range) => range['min'] == minPrice,
      orElse: () => {'max': null},
    );
    return range['max']?.toDouble();
  }

  static bool _matchesCapacity(
    DocumentSnapshot roomDoc,
    HotelFilterParameters params,
  ) {
    final capacity = roomDoc['capacity'] as int;
    return (params.minPeople == null || capacity >= params.minPeople!) &&
        (params.maxPeople == null || capacity <= params.maxPeople!);
  }

  static Future<List<Hotel>> getAllHotels({
    HotelFilterParameters? params,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _hotelsCollection;

      if (params != null) {
        query = _applyHotelFilters(query, params);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) return [];
      List<Hotel> hotels = snapshot.docs.map(Hotel.fromFirestore).toList();

      if (params != null && _needsRoomFiltering(params)) {
        hotels = await _filterHotelsByRoomAvailability(hotels, params);
      }

      return hotels;
    } catch (e) {
      print(e);
      log('Error fetching all hotels: $e');
      return [];
    }
  }

// Supporting functions (these remain the same as in your existing code)
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

  static bool _needsRoomFiltering(HotelFilterParameters params) {
    return params.minPrice != null ||
        params.minPeople != null ||
        params.maxPeople != null;
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
      final visitor = await VisitorService.getVisitorById(booking.visitorId);
      final room = await RoomService.getRoomById(booking.roomId);

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
      final visitor = await VisitorService.getVisitorById(review.visitorId);

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
