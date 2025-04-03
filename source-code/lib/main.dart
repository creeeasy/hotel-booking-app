import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/providers/locale_provider.dart';
import 'package:fatiel/screens/auth_flow.dart';
import 'package:fatiel/screens/hotel/bookings_screen.dart';
import 'package:fatiel/screens/hotel/hotel_dashboard_screen.dart';
import 'package:fatiel/screens/hotel/hotel_home_screen.dart';
import 'package:fatiel/screens/hotel/hotel_profile_screen.dart';
import 'package:fatiel/screens/hotel/hotel_reviews_screen.dart';
import 'package:fatiel/screens/hotel/rooms_screen.dart';
import 'package:fatiel/screens/hotel_details_page.dart';
import 'package:fatiel/screens/register/hotel_registration_screen.dart';
import 'package:fatiel/screens/register/visitor_registration_screen.dart';
import 'package:fatiel/screens/splash_screen.dart';
import 'package:fatiel/screens/visitor/reviews_screen.dart';
import 'package:fatiel/screens/visitor/all_wilayas_screen.dart';
import 'package:fatiel/screens/visitor/booking_details_screen.dart';
import 'package:fatiel/screens/visitor/booking_screen.dart';
import 'package:fatiel/screens/visitor/explore_screen.dart';
import 'package:fatiel/screens/visitor/favorite_screen.dart';
import 'package:fatiel/screens/visitor/hotel_browse_view.dart';
import 'package:fatiel/screens/visitor/room_booking_offers_screen.dart';
import 'package:fatiel/screens/visitor/search_hotel_screen.dart';
import 'package:fatiel/screens/visitor/update_informations_screen.dart';
import 'package:fatiel/screens/visitor/update_password_sceen.dart';
import 'package:fatiel/screens/visitor/visitor_home_screen.dart';
import 'package:fatiel/screens/visitor/visitor_profile_screen.dart';
import 'package:fatiel/screens/visitor/wilaya_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/screens/forgot_password_screen.dart';
import 'package:fatiel/screens/login_screen.dart';
import 'package:fatiel/screens/register_screen.dart';
import 'package:fatiel/screens/verify_email_screen.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/firebase_auth_provider.dart';
import "package:fatiel/constants/routes/routes.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fatiel/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FirebaseAuthProvider())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: L10n.supportedLocales,
        locale: context.watch<LocaleProvider>().locale,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Barlow',
        ),
        routes: {
          loginViewRoute: (context) => const LoginView(),
          registerViewRoute: (context) => RegisterView(),
          forgotPasswordViewRoute: (context) => const ForgotPasswordView(),
          hotelHomePageViewRoute: (context) => const HotelHomeView(),
          visitorHomePageViewRoute: (context) => const VisitorHomeScreen(),
          verificationEmailViewRoute: (context) => const VerifyEmailView(),
          visitorRegistrationRoute: (context) =>
              const VisitorRegistrationView(),
          hotelRegistrationRoute: (context) => const HotelRegistrationView(),
          hotelDetailsRoute: (context) => const HotelDetailsView(),
          favoritesViewRoute: (context) => const FavoritePage(),
          exploreViewRoute: (context) => const ExploreView(),
          bookingsViewRoute: (context) => const BookingScreen(),
          wilayaDetailsViewRoute: (context) => const WilayaDetailsPageView(),
          searchHotelViewRoute: (context) => const SearchHotelView(),
          roomBookingOffersViewRoute: (context) =>
              const RoomBookingOffersPage(),
          bookingDetailsViewRoute: (context) => const BookingDetailsView(),
          allWilayaViewRoute: (context) => const AllWilayaScreen(),
          reviewsScreenRoute: (context) => const ReviewsScreen(),
          hotelBrowseScreenRoute: (context) => const HotelBrowseView(),
          visitorProfileRoute: (context) => const VisitorProfileScreen(),
          updatePasswordRoute: (context) => const UpdatePasswordScreen(),
          updateInformationRoute: (context) => const UpdateUserInformation(),
          hotelDashboardRoute: (context) => const HotelDashboardScreen(),
          hotelRoomsRoute: (context) => const HotelRoomsPage(),
          hotelBookingsRoute: (context) => const HotelBookingsPage(),
          hotelReviewsRoute: (context) => const HotelReviewsScreen(),
          hotelProfileRoute: (context) => const HotelProfileView(),
          authFlowRoute: (context) => const AuthFlow(),
        },
        home: const SplashScreen());
  }
}
