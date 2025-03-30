import 'package:fatiel/screens/hotel/hotel_details_completion_view.dart';
import 'package:fatiel/screens/hotel/hotel_home_screen.dart';
import 'package:fatiel/screens/register/hotel_registration_screen.dart';
import 'package:fatiel/screens/register/visitor_registration_screen.dart';
import 'package:fatiel/screens/visitor/visitor_home_screen.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/loading/loading_screen.dart';
import 'package:fatiel/screens/forgot_password_screen.dart';
import 'package:fatiel/screens/login_screen.dart';
import 'package:fatiel/screens/register_screen.dart';
import 'package:fatiel/screens/verify_email_screen.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? 'Please wait a moment',
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: ((context, state) {
      if (state is AuthStateHotelLoggedIn) {
        return const HotelHomeView();
      } else if (state is AuthStateVisitorLoggedIn) {
        return const VisitorHomeScreen();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return RegisterView();
      } else if (state is AuthStateHotelRegistering) {
        return const HotelRegistrationView();
      } else if (state is AuthStateHotelDetailsCompletion) {
        return const HotelDetailsCompletion();
      } else if (state is AuthStateVisitorRegistering) {
        return const VisitorRegistrationView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicatorWidget(),
        );
      }
    }));
  }
}
