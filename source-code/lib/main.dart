import 'package:fatiel/screens/hotel/hotel_home_screen.dart';
import 'package:fatiel/screens/hotel_details_page.dart';
import 'package:fatiel/screens/register/hotel_registration_screen.dart';
import 'package:fatiel/screens/register/visitor_registration_screen.dart';
import 'package:fatiel/screens/visitor/all_wilayas_screen.dart';
import 'package:fatiel/screens/visitor/booking_details_screen.dart';
import 'package:fatiel/screens/visitor/booking_screen.dart';
import 'package:fatiel/screens/visitor/explore_screen.dart';
import 'package:fatiel/screens/visitor/favorite_screen.dart';
import 'package:fatiel/screens/visitor/room_booking_offers_screen.dart';
import 'package:fatiel/screens/visitor/search_hotel_screen.dart';
import 'package:fatiel/screens/visitor/visitor_home_screen.dart';
import 'package:fatiel/screens/visitor/wilaya_details_page.dart';
import 'package:fatiel/widgets/circular_progress_inducator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/loading/loading_screen.dart';
import 'package:fatiel/screens/forgot_password_screen.dart';
import 'package:fatiel/screens/login_screen.dart';
import 'package:fatiel/screens/register_screen.dart';
import 'package:fatiel/screens/reset_password_screen.dart';
import 'package:fatiel/screens/verify_email_screen.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/services/auth/firebase_auth_provider.dart';
import "package:fatiel/constants/routes/routes.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FirebaseAuthProvider())),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Barlow',
        ),
        routes: {
          loginViewRoute: (context) => const LoginView(),
          registerViewRoute: (context) => RegisterView(),
          forgotPasswordViewRoute: (context) => const ForgotPasswordView(),
          resetPasswordViewRoute: (context) => const ResetPassowrdView(),
          hotelHomePageViewRoute: (context) => const HotelHomeView(),
          visitorHomePageViewRoute: (context) => const VisitorHomeScreen(),
          verificationEmailViewRoute: (context) => const VerifyEmailView(),
          visitorRegistrationRoute: (context) =>
              const VisitorRegistrationView(), // Add the visitor registration route
          hotelRegistrationRoute: (context) => const HotelRegistrationView(),
          hotelDetailsRoute: (context) => const HotelDetailsView(),
          favoritesViewRoute: (context) => const FavoritePage(),
          exploreViewRoute: (context) => ExploreView(),
          bookingsViewRoute: (context) => const BookingView(),
          wilayaDetailsViewRoute: (context) => const WilayaDetailsPageView(),
          searchHotelViewRoute: (context) => const SearchHotelView(),
          roomBookingOffersViewRoute: (context) =>
              const RoomBookingOffersPage(),
          bookingDetailsViewRoute: (context) => const BookingDetailsView(),
          allWilayaViewRoute: (context) => const AllWilayaScreen(),
        },
        home: const SafeArea(child: Traffic()));
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
      if (state is AuthStateHotelLoggedIn) {
        return const HotelHomeView();
      } else if (state is AuthStateVisitorLoggedIn) {
        // return const RoomBookingOffersPage();

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
