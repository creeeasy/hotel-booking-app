import 'package:fatiel/services/auth/auth_provider.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:fatiel/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);
  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider() as AuthProvider);
  }
  @override
  Future<AuthUser?> createUser(
      {required String email, required String password}) {
    return provider.createUser(email: email, password: password);
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

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> logOut() => provider.logOut();
}
