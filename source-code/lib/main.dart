import 'package:fatiel/screens/register/hotel_registration_screen.dart';
import 'package:fatiel/screens/register/visitor_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/loading/loading_screen.dart';
import 'package:fatiel/screens/forgot_password_screen.dart';
import 'package:fatiel/screens/home_screen.dart';
import 'package:fatiel/screens/login_screen.dart';
import 'package:fatiel/screens/register_screen.dart';
import 'package:fatiel/screens/reset_password_screen.dart';
import 'package:fatiel/screens/verify_email_screen.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/auth/firebase_auth_provider.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import "package:fatiel/constants/routes/routes.dart";
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => AuthBloc(FirebaseAuthProvider())),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            textTheme:
                GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
        routes: {
          loginViewRoute: (context) => const LoginView(),
          registerViewRoute: (context) => RegisterView(),
          forgotPasswordViewRoute: (context) => const ForgotPasswordView(),
          resetPasswordViewRoute: (context) => const ResetPassowrdView(),
          homePageViewRoute: (context) => const HomeView(
                title: "Welcome Home",
              ),
          verificationEmailViewRoute: (context) => const VerifyEmailView(),
          visitorRegistrationRoute: (context) =>
              const VisitorRegistrationView(), // Add the visitor registration route
          hotelRegistrationRoute: (context) => const HotelRegistrationView(),
        },
        home: const Traffic());
  }
}

class Traffic extends StatefulWidget {
  const Traffic({super.key});

  @override
  State<Traffic> createState() => _TrafficState();
}

class _TrafficState extends State<Traffic> {
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
      if (state is AuthStateLoggedIn) {
        return const HomeView(
          title: "Welcome home",
        );
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
        // return const VisitorRegistrationView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return RegisterView();
      } else if (state is AuthStateHotelRegistering) {
        return const HotelRegistrationView();
      } else if (state is AuthStateVisitorRegistering) {
        return const VisitorRegistrationView();
      } else {
        return Scaffold(
          body: circularProgressIndicatorWidget(),
        );
      }
    }));
  }
}
