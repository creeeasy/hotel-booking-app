import 'package:fatiel/enum/user_role.dart';
import 'package:fatiel/models/admin.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/admin/admin_service.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:fatiel/utils/generate_search_keywords.dart';
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
        final adminData = await AdminService.getAdminById(user.id);
        if (adminData != null) {
          return AuthUser(
            id: user.id,
            email: user.email,
            isEmailVerified: true,
            role: UserRole.admin,
          );
        }

        final visitorData = await VisitorService.getVisitorById(user.id);
        if (visitorData != null) {
          return AuthUser(
            id: user.id,
            email: user.email,
            isEmailVerified: true,
            role: UserRole.visitor,
          );
        }

        return AuthUser(
          id: user.id,
          email: user.email,
          isEmailVerified: true,
          role: UserRole.hotel,
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

  // @override
  // Future<void> sendEmailVerification() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     await user.sendEmailVerification();
  //   } else {
  //     throw UserNotLoggedInException();
  //   }
  // }

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

  @override
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

  @override
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
        final searchWords = generateSearchKeywords(hotelName);
        await FirebaseFirestore.instance
            .collection('hotels')
            .doc(user.uid)
            .set({
          'hotelName': hotelName,
          'totalRooms': 0,
          "ratings": {
            'rating': 0,
            'totalRating': 0,
          },
          'searchKeywords': FieldValue.arrayUnion(searchWords),
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
  Future<AuthUser?> createAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final now = DateTime.now();
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .set({
          'email': email,
          'name': name,
          'createdAt': now,
          'updatedAt': now,
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

    final admin = await AdminService.getAdminById(user.id);
    if (admin != null) {
      return {
        'role': UserRole.admin,
        'admin': Admin(
          id: user.id,
          email: user.email,
          name: admin.name,
          createdAt: admin.createdAt,
          updatedAt: admin.updatedAt,
          avatarURL: admin.avatarURL,
        ),
      };
    }

    final hotel = await HotelService.getHotelById(user.id);
    if (hotel != null) {
      final hotelData = Hotel(
        id: user.id,
        email: user.email,
        hotelName: hotel.hotelName,
        images: hotel.images,
        location: hotel.location,
        ratings: hotel.ratings,
        totalRooms: hotel.totalRooms,
        description: hotel.description,
        mapLink: hotel.mapLink,
        contactInfo: hotel.contactInfo,
        searchKeywords: hotel.searchKeywords,
        isSubscribed: hotel.isSubscribed,
      );
      final isCompleted = [
        hotel.location,
        hotel.description?.isNotEmpty == true,
        hotel.mapLink?.isNotEmpty == true,
        hotel.contactInfo?.isNotEmpty == true
      ].every((detail) => detail != null && detail != false);
      return {
        'role': UserRole.hotel,
        'isCompleted': isCompleted,
        'hotel': hotelData
      };
    }

    final visitor = await VisitorService.getVisitorById(user.id);
    if (visitor != null) {
      return {
        'role': UserRole.visitor,
        'visitor': Visitor(
          id: user.id,
          email: user.email,
          firstName: visitor.firstName,
          lastName: visitor.lastName,
          favorites: visitor.favorites,
          bookings: visitor.bookings,
          location: visitor.location,
          avatarURL: visitor.avatarURL,
        ),
      };
    }

    return null;
  }

  @override
  Future<void> updatePassword(
      {required String currentPassword, required String newPassword}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final credential = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case 'invalid-credential':
            throw WrongPasswordException();
          case 'weak-password':
            throw WeakPasswordException();
          case 'wrong-password':
            throw WrongPasswordException();
          case 'requires-recent-login':
            throw RequiresRecentLoginException();
          case 'too-many-requests':
            throw UserNotFoundException();
          case 'user-not-found':
            throw UserNotLoggedInException();
          case 'network-request-failed':
          default:
            throw GenericException();
        }
      } catch (error) {
        throw GenericException();
      }
    } else {
      throw UserNotLoggedInException();
    }
  }

  @override
  Future<bool> checkHotelSubscription({required String hotelId}) async {
    try {
      final hotel = await HotelService.getHotelById(hotelId);

      return hotel!.isSubscribed == true;
    } catch (error) {
      throw GenericException();
    }
  }
}
