import 'package:equatable/equatable.dart';
import 'package:fatiel/models/admin.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  final dynamic currentUser;

  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment...',
    this.currentUser,
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateHotelRegistering extends AuthState {
  final Exception? exception;

  const AuthStateHotelRegistering({required this.exception, required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateVisitorRegistering extends AuthState {
  final Exception? exception;

  const AuthStateVisitorRegistering(
      {required this.exception, required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateHotelDetailsCompletion extends AuthState {
  final Exception? exception;
  final Hotel? hotel;

  const AuthStateHotelDetailsCompletion(
      {required this.exception, required bool isLoading, this.hotel})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({required this.exception, required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateUpdatePassword extends AuthState {
  final Exception? exception;

  const AuthStateUpdatePassword({required this.exception, required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateVisitorLoggedIn extends AuthState {
  final Visitor user;
  const AuthStateVisitorLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading, currentUser: user);
}

class AuthStateHotelLoggedIn extends AuthState {
  final Hotel user;
  const AuthStateHotelLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading, currentUser: user);
}

// class AuthStateNeedsVerification extends AuthState {
//   const AuthStateNeedsVerification({required bool isLoading})
//       : super(isLoading: isLoading);
// }

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut(
      {required this.exception, required bool isLoading, String? loadingText})
      : super(isLoading: isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateHotelSubscriptionRequired extends AuthState {
  final Hotel hotel;
  final String message;

  const AuthStateHotelSubscriptionRequired({
    required this.hotel,
    required bool isLoading,
    this.message =
        "Your subscription is pending. Please contact support to activate your account.",
  }) : super(isLoading: isLoading, currentUser: hotel);
}

class AuthStateAdminLoggedIn extends AuthState {
  final Admin admin;
  const AuthStateAdminLoggedIn({
    required bool isLoading,
    required this.admin,
  }) : super(
          isLoading: isLoading,
          currentUser: admin,
        );
}
