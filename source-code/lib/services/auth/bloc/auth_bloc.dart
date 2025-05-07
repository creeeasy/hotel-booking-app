import 'package:fatiel/enum/user_role.dart';
import 'package:fatiel/models/admin.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/stream/visitor_bookings_stream.dart';
import 'package:fatiel/services/stream/visitor_favorites_stream.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/services/auth/auth_provider.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // on<AuthEventSendEmailVerification>((event, emit) async {
    //   await provider.sendEmailVerification();
    //   emit(state);
    // });

    on<AuthEventShouldRegister>(((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    }));
    on<AuthEventVisitorRegister>(((event, emit) {
      emit(
          const AuthStateVisitorRegistering(exception: null, isLoading: false));
    }));
    on<AuthEventHotelRegister>(((event, emit) {
      emit(const AuthStateHotelRegistering(exception: null, isLoading: false));
    }));

    on<AuthEventHotelRegistering>((event, emit) async {
      emit(const AuthStateHotelRegistering(exception: null, isLoading: false));
      final email = event.email;
      final password = event.password;
      final hotelName = event.hotelName;

      emit(const AuthStateHotelRegistering(
        exception: null,
        isLoading: true,
      ));

      try {
        await provider.createHotel(
          email: email,
          password: password,
          hotelName: hotelName,
        );
        final authenticatedUser = await provider.getUser();
        final Hotel hotel = authenticatedUser["hotel"] as Hotel;
        return emit(AuthStateHotelDetailsCompletion(
          isLoading: false,
          exception: null,
          hotel: hotel,
        ));
      } on Exception catch (e) {
        emit(AuthStateHotelRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventVisitorRegistering>((event, emit) async {
      emit(
          const AuthStateVisitorRegistering(exception: null, isLoading: false));
      final email = event.email;
      final password = event.password;
      final firstName = event.firstName;
      final lastName = event.lastName;

      emit(const AuthStateVisitorRegistering(
        exception: null,
        isLoading: true,
      ));

      try {
        await provider.createVisitor(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );
        final authenticatedUser = await provider.getUser();
        VisitorBookingsStream.listenToBookings(null);
        VisitorFavoritesStream.listenToFavorites();

        return emit(AuthStateVisitorLoggedIn(
          isLoading: false,
          user: authenticatedUser,
        ));
      } on Exception catch (e) {
        emit(AuthStateVisitorRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return;
      } else {
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
        ));
        bool didSendEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(email: email);
          didSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
        }
        emit(AuthStateForgotPassword(
          exception: exception,
          hasSentEmail: didSendEmail,
          isLoading: false,
        ));
      }
    });

    on<AuthEventInitialize>((event, emit) async {
      await provider.firebaseIntialize();
      final user = provider.currentUser;

      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else {
        final authenticatedUser = await provider.getUser();

        if (authenticatedUser == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          return;
        }

        if (authenticatedUser is Map) {
          final userRole = authenticatedUser['role'] as UserRole;

          switch (userRole) {
            case UserRole.admin:
              final Admin admin = authenticatedUser["admin"] as Admin;
              emit(AuthStateAdminLoggedIn(
                isLoading: false,
                admin: admin,
              ));
              break;

            case UserRole.hotel:
              final bool isCompleted = authenticatedUser["isCompleted"] as bool;
              final Hotel hotel = authenticatedUser["hotel"] as Hotel;

              if (isCompleted) {
                if (!hotel.isSubscribed) {
                  return add(AuthEventCheckSubscriptionStatus(hotel.id));
                }
                emit(AuthStateHotelLoggedIn(
                  isLoading: false,
                  user: hotel,
                ));
              } else {
                emit(AuthStateHotelDetailsCompletion(
                  exception: null,
                  isLoading: false,
                  hotel: hotel,
                ));
              }
              break;

            case UserRole.visitor:
              final Visitor visitor = authenticatedUser["visitor"] as Visitor;
              VisitorBookingsStream.listenToBookings(null);
              VisitorFavoritesStream.listenToFavorites();

              emit(AuthStateVisitorLoggedIn(
                isLoading: false,
                user: visitor,
              ));
              break;

            default:
              emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          }
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        }
      }
    });
    on<AuthEventHotelLogIn>((event, emit) async {
      final authenticatedUser = await provider.getUser();
      final Hotel hotel = authenticatedUser["hotel"] as Hotel;
      emit(AuthStateHotelLoggedIn(
        isLoading: false,
        user: hotel,
      ));
    });
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Please wait while I log you in',
      ));

      final email = event.email;
      final password = event.password;

      try {
        await provider.logIn(email: email, password: password);
        // final user = await provider.logIn(email: email, password: password);

        // if (!user!.isEmailVerified) {
        //   emit(const AuthStateNeedsVerification(
        //     isLoading: false,
        //   ));
        // } else {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
        final authenticatedUser = await provider.getUser();
        if (authenticatedUser is Map<String, dynamic> &&
            authenticatedUser["hotel"] is Hotel) {
          final bool isCompleted = authenticatedUser["isCompleted"] as bool;
          final Hotel hotel = authenticatedUser["hotel"] as Hotel;

          if (isCompleted) {
            if (!hotel.isSubscribed) {
              return add(AuthEventCheckSubscriptionStatus(hotel.id));
            }
            return emit(AuthStateHotelLoggedIn(
              isLoading: false,
              user: hotel,
            ));
          }

          emit(AuthStateHotelDetailsCompletion(
            exception: null,
            isLoading: false,
            hotel: hotel,
          ));
        } else if (authenticatedUser is Map<String, dynamic> &&
            authenticatedUser["admin"] is Admin) {
          final Admin admin = authenticatedUser["admin"] as Admin;
          return emit(AuthStateAdminLoggedIn(
            isLoading: false,
            admin: admin,
          ));
        } else {
          VisitorBookingsStream.listenToBookings(null);
          VisitorFavoritesStream.listenToFavorites();

          return emit(AuthStateVisitorLoggedIn(
            isLoading: false,
            user: authenticatedUser,
          ));
          // }
        }
      } on Exception catch (exception) {
        emit(
          AuthStateLoggedOut(
            exception: exception,
            isLoading: false,
          ),
        );
      }
    });
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (exception) {
        emit(
          AuthStateLoggedOut(
            exception: exception,
            isLoading: false,
          ),
        );
      }
    });

    on<AuthEventUpdatePassword>((event, emit) async {
      emit(const AuthStateUpdatePassword(
        exception: null,
        isLoading: true,
      ));
      try {
        await provider.updatePassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        emit(const AuthStateUpdatePassword(
          exception: null,
          isLoading: false,
        ));
        emit(const AuthStateVisitorRegistering(
            exception: null, isLoading: false));
      } on Exception catch (exception) {
        emit(AuthStateUpdatePassword(
          exception: exception,
          isLoading: false,
        ));
        emit(const AuthStateVisitorRegistering(
            exception: null, isLoading: false));
      }
    });

    on<AuthEventCheckSubscriptionStatus>((event, emit) async {
      try {
        final hotelId = event.hotelId;
        final bool isSubscribed =
            await provider.checkHotelSubscription(hotelId: hotelId);

        if (!isSubscribed) {
          final authenticatedUser = await provider.getUser();
          final Hotel hotel = authenticatedUser["hotel"] as Hotel;

          emit(AuthStateHotelSubscriptionRequired(
            hotel: hotel,
            isLoading: false,
          ));
        } else {
          final authenticatedUser = await provider.getUser();
          final Hotel hotel = authenticatedUser["hotel"] as Hotel;

          emit(AuthStateHotelLoggedIn(
            isLoading: false,
            user: hotel,
          ));
        }
      } on Exception catch (exception) {
        emit(AuthStateLoggedOut(
          exception: exception,
          isLoading: false,
        ));
      }
    });
  }
}
