import 'package:firebase_auth/firebase_auth.dart' show User;

class Visitor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  Visitor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Visitor.fromFirebaseUser(User user) {
    return Visitor(
      id: user.uid,
      firstName: user.displayName ?? '',
      lastName: '',
      email: user.email ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  factory Visitor.fromFirestore(Map<String, dynamic> data) {
    return Visitor(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
