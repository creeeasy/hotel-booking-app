import 'dart:async';
import 'package:fatiel/screens/admin/admin_home_screen.dart';
import 'package:fatiel/screens/hotel/hotel_subscription_pending_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/helpers/loading/loading_screen.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/screens/hotel/hotel_details_completion_view.dart';
import 'package:fatiel/screens/hotel/hotel_home_screen.dart';
import 'package:fatiel/screens/register/hotel_registration_screen.dart';
import 'package:fatiel/screens/register/visitor_registration_screen.dart';
import 'package:fatiel/screens/visitor/visitor_home_screen.dart';
import 'package:fatiel/screens/forgot_password_screen.dart';
import 'package:fatiel/screens/login_screen.dart';
import 'package:fatiel/screens/register_screen.dart';

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  DateTime? _lastPressed;
  Timer? _exitTimer;
  bool _showExitPrompt = false;

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  Future<bool> _handleWillPop() async {
    final now = DateTime.now();

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return false;
    }

    if (_lastPressed != null &&
        now.difference(_lastPressed!) < const Duration(seconds: 1)) {
      return true;
    }

    _lastPressed = now;
    setState(() => _showExitPrompt = true);

    _exitTimer?.cancel();
    _exitTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showExitPrompt = false);
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  state.isLoading
                      ? LoadingScreen().show(
                          context: context,
                          text: L10n.of(context).pleaseWaitAMoment,
                        )
                      : LoadingScreen().hide();
                },
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case AuthStateHotelLoggedIn:
                      return const HotelHomeView();
                    case AuthStateVisitorLoggedIn:
                      return const VisitorHomeScreen();
                    case AuthStateLoggedOut:
                      return const LoginView();
                    case AuthStateForgotPassword:
                      return const ForgotPasswordView();
                    case AuthStateRegistering:
                      return RegisterView();
                    case AuthStateHotelRegistering:
                      return const HotelRegistrationView();
                    case AuthStateHotelDetailsCompletion:
                      return const HotelDetailsCompletion();
                    case AuthStateVisitorRegistering:
                      return const VisitorRegistrationView();
                    case AuthStateHotelSubscriptionRequired:
                      return const HotelSubscriptionPendingScreen();
                    case AuthStateAdminLoggedIn:
                      return const AdminHomePage();

                    default:
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
