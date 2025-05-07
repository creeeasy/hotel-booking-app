import 'package:fatiel/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<dynamic> getUser();
  Future<AuthUser?> createVisitor(
      {required String email,
      required String password,
      required String firstName,
      required String lastName});
  Future<AuthUser?> createHotel(
      {required String email,
      required String password,
      required String hotelName});
  Future<AuthUser?> logIn({required String email, required String password});
  // Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String email});
  Future<void> firebaseIntialize();
  Future<void> logOut();

  Future<void> updatePassword(
      {required String currentPassword, required String newPassword});
  AuthUser? get currentUser;
  Future<AuthUser?> createAdmin({
    required String email,
    required String password,
    required String name,
  });
  Future<bool> checkHotelSubscription({required String hotelId});
}
