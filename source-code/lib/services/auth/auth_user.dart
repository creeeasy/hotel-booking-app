import 'package:firebase_auth/firebase_auth.dart' show User;

class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;

  AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });
  factory AuthUser.currentUser(User user) {
    return AuthUser(
      id: user.uid,
      email: user.email!,
      isEmailVerified: user.emailVerified,
    );
  }
}