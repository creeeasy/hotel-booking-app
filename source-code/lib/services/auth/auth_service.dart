import 'package:fatiel/services/auth/auth_provider.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:fatiel/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);
  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider());
  }
  @override
  Future<AuthUser?> createVisitor({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return provider.createVisitor(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<AuthUser?> createHotel({
    required String email,
    required String password,
    required String hotelName,
  }) {
    return provider.createHotel(
      email: email,
      password: password,
      hotelName: hotelName,
    );
  }

  @override
  Future<void> firebaseIntialize() {
    return provider.firebaseIntialize();
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return provider.sendPasswordReset(email: email);
  }

  @override
  Future<AuthUser?> logIn({required String email, required String password}) {
    return provider.logIn(email: email, password: password);
  }

  // @override
  // Future<void> sendEmailVerification() {
  //   return provider.sendEmailVerification();
  // }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<dynamic> getUser() {
    return provider.getUser();
  }

  @override
  Future<void> updatePassword(
      {required String newPassword, required String currentPassword}) {
    return provider.updatePassword(
        currentPassword: currentPassword, newPassword: newPassword);
  }

  @override
  Future<AuthUser?> createAdmin({
    required String email,
    required String password,
    required String name,
  }) {
    return provider.createAdmin(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<bool> checkHotelSubscription({required String hotelId}) {
    return provider.checkHotelSubscription(hotelId: hotelId);
  }
}
