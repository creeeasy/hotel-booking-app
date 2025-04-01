import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String>? favorites;
  final List<String>? bookings;
  final int? location;
  final String? avatarURL;

  Visitor({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.favorites,
    this.bookings,
    this.location,
    this.avatarURL,
  });

  factory Visitor.fromFirebaseUser({
    required String id,
    required String email,
    required bool isEmailVerified,
    String? firstName,
    String? lastName,
    List<String>? favorites,
    List<String>? bookings,
    int? location,
    String? avatarURL,
  }) {
    return Visitor(
      id: id,
      email: email,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      favorites: favorites ?? [],
      bookings: bookings ?? [],
      location: location,
      avatarURL: avatarURL,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'favorites': favorites ?? [],
      'bookings': bookings ?? [],
      'location': location,
      'avatarURL': avatarURL,
    };
  }

  factory Visitor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Visitor(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      favorites: List<String>.from(data['favorites'] ?? []),
      bookings: List<String>.from(data['bookings'] ?? []),
      location: data['location'] as int?,
      avatarURL: data['avatarURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'favorites': favorites ?? [],
      'bookings': bookings ?? [],
      'location': location,
      'avatarURL': avatarURL,
    };
  }
}
