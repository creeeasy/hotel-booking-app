import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/screens/hotel/hotel_details_completion_view.dart';
import 'package:fatiel/screens/hotel/hotel_home_screen.dart';
import 'package:fatiel/screens/register/hotel_registration_screen.dart';
import 'package:fatiel/screens/register/visitor_registration_screen.dart';
import 'package:fatiel/screens/visitor/visitor_home_screen.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/helpers/loading/loading_screen.dart';
import 'package:fatiel/screens/forgot_password_screen.dart';
import 'package:fatiel/screens/login_screen.dart';
import 'package:fatiel/screens/register_screen.dart';
// import 'package:fatiel/screens/verify_email_screen.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'dart:async';

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  DateTime? _lastPressed;
  Timer? _timer;
  bool _showExitPrompt = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _handleWillPop() async {
    final now = DateTime.now();

    if (_lastPressed != null &&
        now.difference(_lastPressed!) < const Duration(seconds: 1)) {
      return true;
    }

    _lastPressed = now;
    setState(() => _showExitPrompt = true);

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showExitPrompt = false);
      }
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Stack(
        children: [
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.isLoading) {
                LoadingScreen().show(
                  context: context,
                  text: L10n.of(context).pleaseWaitAMoment,
                );
              } else {
                LoadingScreen().hide();
              }
            },
            builder: (context, state) {
              if (state is AuthStateHotelLoggedIn) {
                return const HotelHomeView();
              } else if (state is AuthStateVisitorLoggedIn) {
                return const VisitorHomeScreen();
                // } else if (state is AuthStateNeedsVerification) {
                //   return const VerifyEmailView();
              } else if (state is AuthStateLoggedOut) {
                return const LoginView();
              } else if (state is AuthStateForgotPassword) {
                return const ForgotPasswordView();
              } else if (state is AuthStateRegistering) {
                return RegisterView();
              } else if (state is AuthStateHotelRegistering) {
                return const HotelRegistrationView();
              } else if (state is AuthStateHotelDetailsCompletion) {
                return HotelDetailsCompletion();
              } else if (state is AuthStateVisitorRegistering) {
                return const VisitorRegistrationView();
              } else {
                return const Scaffold(
                  body: CircularProgressIndicatorWidget(),
                );
              }
            },
          ),
          if (_showExitPrompt)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    L10n.of(context).pressBackAgainToExit,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
