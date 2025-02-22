import 'package:fatiel/enum/user_role.dart';
import 'package:fatiel/models/Hotel.dart';
import 'package:fatiel/models/Visitor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/firebase_options.dart';
import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/auth_user.dart';
import 'package:fatiel/services/auth/auth_provider.dart' as auth;

typedef AuthProviderImplement = auth.AuthProvider;

class FirebaseAuthProvider implements AuthProviderImplement {
  @override
  Future<AuthUser?> logIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;

      if (user != null) {
        final visitorDoc = await FirebaseFirestore.instance
            .collection("visitors")
            .doc(user.id)
            .get();
        final userRole = visitorDoc.exists ? UserRole.visitor : UserRole.hotel;

        return AuthUser(
          id: user.id,
          email: user.email,
          isEmailVerified: user.isEmailVerified,
          role: userRole,
        );
      } else {
        return null;
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'user-not-found':
          throw UserNotFoundException();
        case 'invalid-email':
          throw InvalidEmailException();
        case 'weak-password':
          throw WeakPasswordException();
        case 'missing-password':
          throw MissingPasswordException();
        case 'wrong-password':
          throw WrongPasswordException();
        default:
          throw GenericException();
      }
    } catch (error) {
      throw GenericException();
    }
  }

  @override
  Future<void> firebaseIntialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (exception) {
      switch (exception.code) {
        case 'invalid-email':
          throw InvalidEmailException();
        case 'user-not-found':
          throw UserNotFoundException();
      }
    } catch (error) {
      throw GenericException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    } else {
      return AuthUser.currentUser(user);
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInException();
    }
  }

  Future<AuthUser?> createVisitor({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('visitors')
            .doc(user.uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
        });
        return AuthUser.currentUser(user);
      } else {
        return null;
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-email':
          throw InvalidEmailException();
        case 'weak-password':
          throw WeakPasswordException();
        case 'email-already-in-use':
          throw EmailAlreadyInUseException();
        case 'missing-password':
          throw MissingPasswordException();
        default:
          throw GenericException();
      }
    } catch (error) {
      throw GenericException();
    }
  }

  Future<AuthUser?> createHotel({
    required String email,
    required String password,
    required String hotelName,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('hotels')
            .doc(user.uid)
            .set({
          'hotelName': hotelName,
        });
        return AuthUser.currentUser(user);
      } else {
        return null;
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'invalid-email':
          throw InvalidEmailException();
        case 'weak-password':
          throw WeakPasswordException();
        case 'email-already-in-use':
          throw EmailAlreadyInUseException();
        case 'missing-password':
          throw MissingPasswordException();
        default:
          throw GenericException();
      }
    } catch (error) {
      throw GenericException();
    }
  }

  @override
  Future<dynamic> getUser() async {
    final user = currentUser!;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final DocumentSnapshot hotelDoc =
        await firestore.collection('hotels').doc(user.id).get();

    if (hotelDoc.exists) {
      final data = hotelDoc.data() as Map<String, dynamic>;
      return Hotel(
        id: user.id,
        email: user.email,
        isEmailVerified: user.isEmailVerified,
        role: UserRole.hotel,
        hotelName: data['hotelName'] ?? 'Unknown',
      );
    }

    final DocumentSnapshot visitorDoc =
        await firestore.collection('visitors').doc(user.id).get();

    final data = visitorDoc.data() as Map<String, dynamic>;
    return Visitor(
      id: user.id,
      email: user.email,
      isEmailVerified: user.isEmailVerified,
      role: UserRole.visitor,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      favorites: List<String>.from(data["favorites"] ?? []),
      bookings: List<String>.from(data["bookings"] ?? []),
      location: data['location'] != null ? data['location'] as int : null,
    );
  }
}
