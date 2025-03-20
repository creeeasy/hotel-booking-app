import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventVisitorRegister extends AuthEvent {
  const AuthEventVisitorRegister();
}

class AuthEventHotelRegister extends AuthEvent {
  const AuthEventHotelRegister();
}

class AuthEventHotelDetailsCompletion extends AuthEvent {
  const AuthEventHotelDetailsCompletion();
}

class AuthEventHotelLogIn extends AuthEvent {
  const AuthEventHotelLogIn();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventUpdatePassword extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  const AuthEventUpdatePassword(
      {required this.currentPassword, required this.newPassword});
}

class AuthEventVisitorRegistering extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const AuthEventVisitorRegistering(
      this.firstName, this.lastName, this.email, this.password);
}

class AuthEventHotelRegistering extends AuthEvent {
  final String hotelName;
  final String email;
  final String password;
  const AuthEventHotelRegistering(this.hotelName, this.email, this.password);
}
