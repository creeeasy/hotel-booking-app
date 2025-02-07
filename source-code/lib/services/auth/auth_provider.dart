
import 'package:fatiel/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<AuthUser?> createUser(
      {required String email, required String password});
  Future<AuthUser?> logIn({required String email, required String password});
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String email});
  Future<void> firebaseIntialize();
  Future<void> logOut();
  AuthUser? get currentUser;
}