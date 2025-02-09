import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:fatiel/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment...',
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

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({required this.exception, required isLoading})
      : super(isLoading: isLoading);
}

class AuthStateVisitorLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateVisitorLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateHotelLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateHotelLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isLoading})
      : super(isLoading: isLoading);
}

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
