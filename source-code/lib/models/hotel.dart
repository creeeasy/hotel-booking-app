import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/rating.dart';

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
  final bool isSubscribed;

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
    this.isSubscribed = false, // Default to unsubscribed
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
    bool? isSubscribed,
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
      isSubscribed: isSubscribed ?? this.isSubscribed,
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
      'isSubscribed': isSubscribed,
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
      isSubscribed: data['isSubscribed'] as bool? ?? false,
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
      'searchKeywords': searchKeywords,
      'isSubscribed': isSubscribed,
    };
  }
}
