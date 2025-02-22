import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:fatiel/enum/user_role.dart';

class Visitor extends AuthUser {
  final String firstName;
  final String lastName;
  final List<String>? favorites;
  final List<String>? bookings;
  final int? location;

  Visitor(
      {required super.id,
      required super.email,
      required super.isEmailVerified,
      required super.role,
      required this.firstName,
      required this.lastName,
      this.favorites,
      this.bookings,
      this.location});

  factory Visitor.fromFirebaseUser(
    AuthUser user, {
    String? firstName,
    String? lastName,
    List<String>? favorites,
    List<String>? bookings,
    int? location,
  }) {
    return Visitor(
      id: user.id,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: user.email,
      role: UserRole.visitor,
      isEmailVerified: user.isEmailVerified,
      favorites: favorites ?? [],
      bookings: bookings ?? [],
      location: location,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role?.name,
      'isEmailVerified': isEmailVerified,
      'favorites': favorites ?? [],
      'bookings': bookings ?? [],
      'location': location,
    };
  }

  factory Visitor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    log(data.toString());
    return Visitor(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      isEmailVerified: data['isEmailVerified'] ?? false,
      favorites: List<String>.from(data['favorites'] ?? []),
      bookings: List<String>.from(data['bookings'] ?? []),
      location: data['location'] != null ? data['location'] as int : null,
    );
  }

  static Future<void> updateVisitor(Visitor visitor) async {
    try {
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitor.id)
          .update(visitor.toFirestore());
    } catch (e) {
      print('Error updating visitor: $e');
      rethrow;
    }
  }

  static Future<List<String>> getUserFavorites(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('visitors')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        List<String> favorites = List<String>.from(data?['favorites'] ?? []);
        return favorites;
      } else {
        return [];
      }
    } catch (e) {
      log('Error fetching user favorites: $e');
      return [];
    }
  }

  static UserRole _parseRole(dynamic roleString) {
    if (roleString is String) {
      try {
        return UserRole.values.byName(roleString);
      } catch (_) {
        print('Invalid role string: $roleString. Defaulting to visitor.');
      }
    }
    return UserRole.visitor;
  }

  @override
  String toString() {
    return 'Visitor(id: $id, firstName: $firstName, lastName: $lastName, email: $email, role: $role, isEmailVerified: $isEmailVerified, favorites: $favorites, bookings: $bookings)';
  }
}
