import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:fatiel/enum/user_role.dart';

class Hotel extends AuthUser {
  final String name;

  Hotel({
    required super.id,
    required super.email,
    required super.isEmailVerified,
    required super.role,
    required this.name,
  });

  factory Hotel.fromFirebaseUser(AuthUser user, {String name = ''}) {
    return Hotel(
      id: user.id,
      email: user.email,
      isEmailVerified: user.isEmailVerified,
      role: UserRole.hotel,
      name: name,
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString(),
    };
  }

  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Hotel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      isEmailVerified: true,
    );
  }

  static Future<void> updateHotel(Hotel hotel) async {
    try {
      await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotel.id)
          .update(hotel.toFirestore());
    } catch (e) {
      print('Error updating hotel: $e');
      rethrow;
    }
  }

  static UserRole _parseRole(String roleString) {
    try {
      return UserRole.values.byName(roleString);
    } catch (e) {
      print('Invalid role string: $roleString. Defaulting to hotel.');
      return UserRole.hotel;
    }
  }

  @override
  String toString() {
    return 'Hotel(id: $id, name: $name, email: $email, role: $role, isEmailVerified: $isEmailVerified)';
  }
}
