import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:fatiel/enum/user_role.dart';

class Visitor extends AuthUser {
  final String firstName;
  final String lastName;

  Visitor({
    required super.id,
    required super.email,
    required super.isEmailVerified,
    required super.role,
    required this.firstName,
    required this.lastName,
  });

  factory Visitor.fromFirebaseUser(User user) {
    return Visitor(
      id: user.uid,
      firstName: '',
      lastName: '',
      email: user.email ?? '',
      role: UserRole.visitor,
      isEmailVerified: user.emailVerified,
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
    };
  }

  factory Visitor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Visitor(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      isEmailVerified: data['isEmailVerified'] ?? false,
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

  static UserRole _parseRole(dynamic roleString) {
    if (roleString is String) {
      try {
        return UserRole.values.byName(roleString);
      } catch (_) {
        print('Invalid role string: $roleString. Defaulting to visitor.');
      }
    }
    return UserRole.visitor; // Default to visitor if role is null or invalid
  }

  @override
  String toString() {
    return 'Visitor(id: $id, firstName: $firstName, lastName: $lastName, email: $email, role: $role, isEmailVerified: $isEmailVerified)';
  }
}
