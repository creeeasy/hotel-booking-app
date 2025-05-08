import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @welcomeBackSimple.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBackSimple;

  /// Welcome message for hotel dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome Back, {hotelName}!'**
  String welcomeBack(Object hotelName);

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get signInToAccount;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @emailValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailValidationError;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @passwordValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordValidationError;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrompt;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @missingPassword.
  ///
  /// In en, this message translates to:
  /// **'Missing password'**
  String get missingPassword;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials'**
  String get wrongCredentials;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authError;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @noHotelsFound.
  ///
  /// In en, this message translates to:
  /// **'No hotels found'**
  String get noHotelsFound;

  /// No description provided for @roomCapacity.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {# guest} other {# guests}}'**
  String roomCapacity(num count);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Filter option for rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get filterRating;

  /// Filter option for price
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get filterPrice;

  /// Filter option for minimum people
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get filterMinPeople;

  /// Filter option for location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocation;

  /// Title for logout dialog
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutTitle;

  /// Content for logout dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutContent;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// Text for very recent time
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Text for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(Object minutes);

  /// Text for hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(Object hours);

  /// Text for days ago
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @amenityWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get amenityWifi;

  /// No description provided for @amenityPool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get amenityPool;

  /// No description provided for @amenityGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get amenityGym;

  /// No description provided for @amenityRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get amenityRestaurant;

  /// No description provided for @amenitySpa.
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get amenitySpa;

  /// No description provided for @amenityParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get amenityParking;

  /// No description provided for @amenityRoomService.
  ///
  /// In en, this message translates to:
  /// **'Room Service'**
  String get amenityRoomService;

  /// No description provided for @amenityPlayground.
  ///
  /// In en, this message translates to:
  /// **'Kids Playground'**
  String get amenityPlayground;

  /// No description provided for @amenityBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get amenityBar;

  /// No description provided for @amenityConcierge.
  ///
  /// In en, this message translates to:
  /// **'Concierge'**
  String get amenityConcierge;

  /// No description provided for @amenityBusinessCenter.
  ///
  /// In en, this message translates to:
  /// **'Business Center'**
  String get amenityBusinessCenter;

  /// No description provided for @amenityLaundry.
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get amenityLaundry;

  /// No description provided for @amenityAirportShuttle.
  ///
  /// In en, this message translates to:
  /// **'Airport Shuttle'**
  String get amenityAirportShuttle;

  /// No description provided for @amenityPetFriendly.
  ///
  /// In en, this message translates to:
  /// **'Pet Friendly'**
  String get amenityPetFriendly;

  /// No description provided for @amenityAccessible.
  ///
  /// In en, this message translates to:
  /// **'Accessible'**
  String get amenityAccessible;

  /// No description provided for @amenitySmokeFree.
  ///
  /// In en, this message translates to:
  /// **'Smoke Free'**
  String get amenitySmokeFree;

  /// No description provided for @amenityBeachAccess.
  ///
  /// In en, this message translates to:
  /// **'Beach Access'**
  String get amenityBeachAccess;

  /// No description provided for @amenityTv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get amenityTv;

  /// No description provided for @amenityAc.
  ///
  /// In en, this message translates to:
  /// **'Air Conditioning'**
  String get amenityAc;

  /// No description provided for @amenityHeating.
  ///
  /// In en, this message translates to:
  /// **'Heating'**
  String get amenityHeating;

  /// No description provided for @amenitySafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get amenitySafe;

  /// No description provided for @amenityKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get amenityKitchen;

  /// No description provided for @amenityMinibar.
  ///
  /// In en, this message translates to:
  /// **'Minibar'**
  String get amenityMinibar;

  /// No description provided for @amenityBathtub.
  ///
  /// In en, this message translates to:
  /// **'Bathtub'**
  String get amenityBathtub;

  /// No description provided for @amenityToiletries.
  ///
  /// In en, this message translates to:
  /// **'Toiletries'**
  String get amenityToiletries;

  /// Title shown when no hotels are found
  ///
  /// In en, this message translates to:
  /// **'No Hotels Found'**
  String get noHotelsTitle;

  /// Default message shown when no hotels are found
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any hotels matching your criteria. Try adjusting your search filters or exploring nearby locations.'**
  String get noHotelsDefaultMessage;

  /// Title for bookings page
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsTitle;

  /// Title for bookings navigation tile
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsNavTitle;

  /// Title for filter dialog
  ///
  /// In en, this message translates to:
  /// **'Filter Bookings'**
  String get filterBookingsTitle;

  /// Title for booking details sheet
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailsTitle;

  /// Section header for room info
  ///
  /// In en, this message translates to:
  /// **'Room Information'**
  String get roomInformation;

  /// Section header for guest info
  ///
  /// In en, this message translates to:
  /// **'Guest Information'**
  String get guestInformation;

  /// Section header for booking dates
  ///
  /// In en, this message translates to:
  /// **'Booking Dates'**
  String get bookingDates;

  /// Section header for payment info
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInformation;

  /// Label for total amount
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Label for payment status
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// Text shown when payment is complete
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Button text to complete booking
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markCompleted;

  /// Label for check-in date
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// Label for check-out date
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get checkOut;

  /// Price per night text
  ///
  /// In en, this message translates to:
  /// **'{price} per night'**
  String perNight(Object price);

  /// Title when no bookings exist
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get noBookingsFound;

  /// Default no bookings message
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any bookings yet'**
  String get noBookingsDefault;

  /// Message when no filtered bookings exist
  ///
  /// In en, this message translates to:
  /// **'No {status} bookings found'**
  String noFilteredBookings(Object status);

  /// Error message when bookings fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookings'**
  String get failedToLoadBookings;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Summary card title for total bookings
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get summaryTotal;

  /// Summary card title for pending bookings
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get summaryPending;

  /// Summary card title for completed bookings
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get summaryCompleted;

  /// Summary card title for revenue
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get summaryRevenue;

  /// Button text to complete booking
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Pluralized night count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{night} other{nights}}'**
  String nights(num count);

  /// Subtitle for hotel dashboard
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening today'**
  String get dashboardSubtitle;

  /// Label for active bookings metric
  ///
  /// In en, this message translates to:
  /// **'Active Bookings'**
  String get activeBookings;

  /// Label for available rooms metric
  ///
  /// In en, this message translates to:
  /// **'Rooms Available'**
  String get roomsAvailable;

  /// Label for reviews metric
  ///
  /// In en, this message translates to:
  /// **'Total Reviews'**
  String get totalReviews;

  /// Label for pending bookings metric
  ///
  /// In en, this message translates to:
  /// **'Pending Bookings'**
  String get pendingBookings;

  /// Section title for quick access buttons
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// Section title for recent activity
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Message shown when there's no activity
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// Title for rooms navigation tile
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get roomsTitle;

  /// Description for rooms navigation tile
  ///
  /// In en, this message translates to:
  /// **'Manage room details'**
  String get roomsDescription;

  /// Description for bookings navigation tile
  ///
  /// In en, this message translates to:
  /// **'View all bookings'**
  String get bookingsDescription;

  /// Title for reviews navigation tile
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// Description for reviews navigation tile
  ///
  /// In en, this message translates to:
  /// **'Check guest feedback'**
  String get reviewsDescription;

  /// Title for profile navigation tile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Description for profile navigation tile
  ///
  /// In en, this message translates to:
  /// **'Hotel profile'**
  String get profileDescription;

  /// No description provided for @validUrl.
  ///
  /// In en, this message translates to:
  /// **'Type a valid url!'**
  String get validUrl;

  /// No description provided for @emptyInput.
  ///
  /// In en, this message translates to:
  /// **'Input can\'t be empty!'**
  String get emptyInput;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocation;

  /// No description provided for @updateDescription.
  ///
  /// In en, this message translates to:
  /// **'Update Description'**
  String get updateDescription;

  /// No description provided for @updateMapLink.
  ///
  /// In en, this message translates to:
  /// **'Update Map Link'**
  String get updateMapLink;

  /// No description provided for @updateContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Update Contact Information'**
  String get updateContactInfo;

  /// No description provided for @completeHotelProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Hotel Profile'**
  String get completeHotelProfile;

  /// No description provided for @selectWilaya.
  ///
  /// In en, this message translates to:
  /// **'Select a Wilaya'**
  String get selectWilaya;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @loadingPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingPlaceholder;

  /// No description provided for @inputEmpty.
  ///
  /// In en, this message translates to:
  /// **'Input can\'t be empty!'**
  String get inputEmpty;

  /// No description provided for @updateContactInformation.
  ///
  /// In en, this message translates to:
  /// **'Update Contact Information'**
  String get updateContactInformation;

  /// Hint text for input fields
  ///
  /// In en, this message translates to:
  /// **'Enter {field}...'**
  String enterField(Object field);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @hotelPhotos.
  ///
  /// In en, this message translates to:
  /// **'Hotel Photos'**
  String get hotelPhotos;

  /// No description provided for @noPhotosAdded.
  ///
  /// In en, this message translates to:
  /// **'No photos added'**
  String get noPhotosAdded;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @hotelName.
  ///
  /// In en, this message translates to:
  /// **'Hotel Name'**
  String get hotelName;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @wilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get wilaya;

  /// No description provided for @mapLink.
  ///
  /// In en, this message translates to:
  /// **'Map Link'**
  String get mapLink;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your profile data has been updated successfully.'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// No description provided for @imageUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get imageUploadedSuccessfully;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: {error}'**
  String errorUploadingImage(Object error);

  /// No description provided for @imageRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image removed successfully'**
  String get imageRemovedSuccessfully;

  /// No description provided for @errorRemovingImage.
  ///
  /// In en, this message translates to:
  /// **'Error removing image: {error}'**
  String errorRemovingImage(Object error);

  /// No description provided for @guestReviews.
  ///
  /// In en, this message translates to:
  /// **'Guest Reviews'**
  String get guestReviews;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Star rating label
  ///
  /// In en, this message translates to:
  /// **'{count} Stars'**
  String stars(Object count);

  /// Review count label
  ///
  /// In en, this message translates to:
  /// **'{count} Reviews'**
  String reviewsCount(Object count);

  /// No description provided for @errorLoadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews'**
  String get errorLoadingReviews;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'rooms'**
  String get rooms;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @hotelRegistration.
  ///
  /// In en, this message translates to:
  /// **'Hotel Registration'**
  String get hotelRegistration;

  /// No description provided for @registerHotel.
  ///
  /// In en, this message translates to:
  /// **'Register Your Hotel'**
  String get registerHotel;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @registerHotelButton.
  ///
  /// In en, this message translates to:
  /// **'Register Hotel'**
  String get registerHotelButton;

  /// No description provided for @enterHotelName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your hotel\'s name.'**
  String get enterHotelName;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get validEmail;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get passwordLength;

  /// No description provided for @passwordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMatch;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password provided is too weak.'**
  String get weakPassword;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email is already in use'**
  String get emailInUse;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to register'**
  String get registerFailed;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinFatiel.
  ///
  /// In en, this message translates to:
  /// **'Join Fatiel'**
  String get joinFatiel;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @firstNameLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first and last name.'**
  String get firstNameLastNameRequired;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @checkInDate.
  ///
  /// In en, this message translates to:
  /// **'Check-in Date'**
  String get checkInDate;

  /// No description provided for @checkOutDate.
  ///
  /// In en, this message translates to:
  /// **'Check-out Date'**
  String get checkOutDate;

  /// No description provided for @totalNights.
  ///
  /// In en, this message translates to:
  /// **'Total Nights'**
  String get totalNights;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get confirmAndPay;

  /// No description provided for @selectCheckInDate.
  ///
  /// In en, this message translates to:
  /// **'Select Check-in Date'**
  String get selectCheckInDate;

  /// No description provided for @selectCheckOutDate.
  ///
  /// In en, this message translates to:
  /// **'Select Check-out Date'**
  String get selectCheckOutDate;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed successfully!'**
  String get bookingConfirmed;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'night'**
  String get night;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @oopsSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @removeHotelFromFavoritesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this hotel from your favorites?'**
  String get removeHotelFromFavoritesConfirmation;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @failedToUpdateFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorites'**
  String get failedToUpdateFavorites;

  /// No description provided for @removeFromFavoritesSemantic.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavoritesSemantic;

  /// No description provided for @addToFavoritesSemantic.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavoritesSemantic;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @locationNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get locationNotSpecified;

  /// No description provided for @noImageAvailable.
  ///
  /// In en, this message translates to:
  /// **'No image available'**
  String get noImageAvailable;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'hotel'**
  String get hotel;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'hotels'**
  String get hotels;

  /// No description provided for @tryAdjustingSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search filters'**
  String get tryAdjustingSearchFilters;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get noDataFound;

  /// No description provided for @noPopularDestinationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No popular destinations available at the moment.'**
  String get noPopularDestinationsAvailable;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @allWilayas.
  ///
  /// In en, this message translates to:
  /// **'All Wilayas'**
  String get allWilayas;

  /// No description provided for @failedToLoadWilayaData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wilaya data'**
  String get failedToLoadWilayaData;

  /// No description provided for @noHotelsListedInAnyWilaya.
  ///
  /// In en, this message translates to:
  /// **'No hotels currently listed in any wilaya'**
  String get noHotelsListedInAnyWilaya;

  /// No description provided for @discoveringAmazingPlaces.
  ///
  /// In en, this message translates to:
  /// **'Discovering amazing places for you'**
  String get discoveringAmazingPlaces;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// No description provided for @priceSummary.
  ///
  /// In en, this message translates to:
  /// **'Price Summary'**
  String get priceSummary;

  /// No description provided for @roomRate.
  ///
  /// In en, this message translates to:
  /// **'Room Rate'**
  String get roomRate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @roomDetails.
  ///
  /// In en, this message translates to:
  /// **'Room Details'**
  String get roomDetails;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @exploreHotel.
  ///
  /// In en, this message translates to:
  /// **'Explore Hotel'**
  String get exploreHotel;

  /// No description provided for @bookingError.
  ///
  /// In en, this message translates to:
  /// **'Booking Error'**
  String get bookingError;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @noBookingFound.
  ///
  /// In en, this message translates to:
  /// **'No Booking Found'**
  String get noBookingFound;

  /// No description provided for @noBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any booking details'**
  String get noBookingDetails;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @failedToLoadBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load booking details'**
  String get failedToLoadBookingDetails;

  /// No description provided for @bookingDetailsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Booking details not available'**
  String get bookingDetailsNotAvailable;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @writeAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReview;

  /// No description provided for @shareYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get shareYourExperience;

  /// No description provided for @pleaseWriteAComment.
  ///
  /// In en, this message translates to:
  /// **'Please write a comment'**
  String get pleaseWriteAComment;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete Review'**
  String get deleteReview;

  /// No description provided for @areYouSureDeleteReview.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get areYouSureDeleteReview;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @areYouSureCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get areYouSureCancelBooking;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @exploreHotels.
  ///
  /// In en, this message translates to:
  /// **'Explore Hotels'**
  String get exploreHotels;

  /// No description provided for @noPendingBookings.
  ///
  /// In en, this message translates to:
  /// **'No Pending Bookings!'**
  String get noPendingBookings;

  /// No description provided for @noCompletedBookings.
  ///
  /// In en, this message translates to:
  /// **'No Completed Bookings!'**
  String get noCompletedBookings;

  /// No description provided for @noCancelledBookings.
  ///
  /// In en, this message translates to:
  /// **'No Cancelled Bookings!'**
  String get noCancelledBookings;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey today! Find the best hotels\nand book your dream stay effortlessly.'**
  String get startYourJourney;

  /// No description provided for @completedBookingsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your completed bookings will appear here.\nShare your experience by leaving reviews!'**
  String get completedBookingsAppearHere;

  /// No description provided for @cancelledBookingsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your cancelled bookings will appear here.\nYou can always book again!'**
  String get cancelledBookingsAppearHere;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @nearMe.
  ///
  /// In en, this message translates to:
  /// **'Near Me'**
  String get nearMe;

  /// No description provided for @recommendedHotels.
  ///
  /// In en, this message translates to:
  /// **'Recommended Hotels'**
  String get recommendedHotels;

  /// No description provided for @hotelsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Hotels Near You'**
  String get hotelsNearYou;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failedToLoadHotels.
  ///
  /// In en, this message translates to:
  /// **'Failed to load hotels'**
  String get failedToLoadHotels;

  /// No description provided for @noHotelsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Hotels Available'**
  String get noHotelsAvailable;

  /// No description provided for @noHotelsMatchingCriteria.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any hotels matching your criteria.'**
  String get noHotelsMatchingCriteria;

  /// No description provided for @findHotelsInCities.
  ///
  /// In en, this message translates to:
  /// **'Find hotels in cities'**
  String get findHotelsInCities;

  /// No description provided for @failedToLoadCityData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load city data'**
  String get failedToLoadCityData;

  /// No description provided for @noHotelsListedInCities.
  ///
  /// In en, this message translates to:
  /// **'No hotels are currently listed in these cities.'**
  String get noHotelsListedInCities;

  /// No description provided for @loadingYourFavorites.
  ///
  /// In en, this message translates to:
  /// **'Loading your favorites'**
  String get loadingYourFavorites;

  /// No description provided for @couldntLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load favorites'**
  String get couldntLoadFavorites;

  /// No description provided for @checkConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get checkConnectionAndTryAgain;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// No description provided for @saveFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite hotels by tapping the heart icon when browsing'**
  String get saveFavoritesMessage;

  /// No description provided for @browseHotels.
  ///
  /// In en, this message translates to:
  /// **'Browse Hotels'**
  String get browseHotels;

  /// No description provided for @recommendedHotelsCount.
  ///
  /// In en, this message translates to:
  /// **'Recommended Hotels ({count})'**
  String recommendedHotelsCount(Object count);

  /// No description provided for @hotelsNearYouCount.
  ///
  /// In en, this message translates to:
  /// **'Hotels Near You ({count})'**
  String hotelsNearYouCount(Object count);

  /// No description provided for @weCouldntFindAnyHotels.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any hotels matching your criteria.'**
  String get weCouldntFindAnyHotels;

  /// No description provided for @noReviewsDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No reviews data available'**
  String get noReviewsDataAvailable;

  /// No description provided for @guestFavorite.
  ///
  /// In en, this message translates to:
  /// **'Guest Favorite'**
  String get guestFavorite;

  /// No description provided for @basedOnReviews.
  ///
  /// In en, this message translates to:
  /// **'Based on {totalRatings} reviews'**
  String basedOnReviews(Object totalRatings);

  /// No description provided for @starsCount.
  ///
  /// In en, this message translates to:
  /// **'{ratingCount} Stars'**
  String starsCount(Object ratingCount);

  /// No description provided for @exploreRoomOffers.
  ///
  /// In en, this message translates to:
  /// **'Explore room offers'**
  String get exploreRoomOffers;

  /// No description provided for @perNightSimple.
  ///
  /// In en, this message translates to:
  /// **'Per night'**
  String get perNightSimple;

  /// No description provided for @roomType.
  ///
  /// In en, this message translates to:
  /// **'Room Type'**
  String get roomType;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @successfullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Successfully booked'**
  String get successfullyBooked;

  /// No description provided for @noAmenitiesListed.
  ///
  /// In en, this message translates to:
  /// **'No amenities listed'**
  String get noAmenitiesListed;

  /// No description provided for @availableFrom.
  ///
  /// In en, this message translates to:
  /// **'Available from'**
  String get availableFrom;

  /// No description provided for @notCurrentlyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not currently available'**
  String get notCurrentlyAvailable;

  /// No description provided for @failedToLoadRooms.
  ///
  /// In en, this message translates to:
  /// **'Failed to load rooms'**
  String get failedToLoadRooms;

  /// No description provided for @noRoomsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rooms available'**
  String get noRoomsAvailable;

  /// No description provided for @searchHotels.
  ///
  /// In en, this message translates to:
  /// **'Search Hotels'**
  String get searchHotels;

  /// No description provided for @searchHotelsLocations.
  ///
  /// In en, this message translates to:
  /// **'Search hotels, locations...'**
  String get searchHotelsLocations;

  /// No description provided for @searchForHotels.
  ///
  /// In en, this message translates to:
  /// **'Search for hotels'**
  String get searchForHotels;

  /// No description provided for @enterHotelNameLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter hotel name, location or amenities to find your perfect stay'**
  String get enterHotelNameLocation;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @inputCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Input can\'t be empty!'**
  String get inputCantBeEmpty;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @updateFirstName.
  ///
  /// In en, this message translates to:
  /// **'Update first name'**
  String get updateFirstName;

  /// No description provided for @updateLastName.
  ///
  /// In en, this message translates to:
  /// **'Update last name'**
  String get updateLastName;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocation;

  /// No description provided for @updateYourInformation.
  ///
  /// In en, this message translates to:
  /// **'Update Your Information'**
  String get updateYourInformation;

  /// No description provided for @selectAWilaya.
  ///
  /// In en, this message translates to:
  /// **'Select a Wilaya'**
  String get selectAWilaya;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Your current password is incorrect.'**
  String get wrongPassword;

  /// No description provided for @requiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please reauthenticate to update your password.'**
  String get requiresRecentLogin;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get genericError;

  /// No description provided for @failedToUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password. Please try again.'**
  String get failedToUpdatePassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password Mismatch'**
  String get passwordMismatch;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed'**
  String get imageUploadFailed;

  /// No description provided for @profileImageUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully'**
  String get profileImageUpdatedSuccessfully;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @removeProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Profile Image'**
  String get removeProfileImage;

  /// No description provided for @removeProfileImageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your profile image?'**
  String get removeProfileImageConfirmation;

  /// No description provided for @profileImageRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile image removed'**
  String get profileImageRemoved;

  /// No description provided for @failedToRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove image'**
  String get failedToRemoveImage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @wilayaNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wilaya not found'**
  String get wilayaNotFound;

  /// No description provided for @wilayaDataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Wilaya data not available'**
  String get wilayaDataNotAvailable;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @noHotelsRegistered.
  ///
  /// In en, this message translates to:
  /// **'There are currently no hotels registered in {wilayaName}'**
  String noHotelsRegistered(Object wilayaName);

  /// No description provided for @pleaseWaitAMoment.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get pleaseWaitAMoment;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passwordReset;

  /// No description provided for @passwordResetSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We have now sent you a password reset link.'**
  String get passwordResetSentMessage;

  /// No description provided for @forgotPasswordGenericError.
  ///
  /// In en, this message translates to:
  /// **'We could not process your request. Please make sure that you are a registered user, or if not, register a user now by going back one step.'**
  String get forgotPasswordGenericError;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address to receive a password reset link'**
  String get forgotPasswordInstructions;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @failedToLoadHotelDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load hotel details'**
  String get failedToLoadHotelDetails;

  /// No description provided for @noHotelInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No hotel information available'**
  String get noHotelInformationAvailable;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @noContactInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No contact information available'**
  String get noContactInformationAvailable;

  /// No description provided for @ratingsAndReviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & Reviews'**
  String get ratingsAndReviews;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @locationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Location on Map'**
  String get locationOnMap;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @mapLocationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Map location not available'**
  String get mapLocationNotAvailable;

  /// No description provided for @roomOffers.
  ///
  /// In en, this message translates to:
  /// **'Room Offers'**
  String get roomOffers;

  /// No description provided for @viewRoomOffers.
  ///
  /// In en, this message translates to:
  /// **'View Room Offers'**
  String get viewRoomOffers;

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select your account type to begin'**
  String get selectAccountType;

  /// No description provided for @traveler.
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get traveler;

  /// No description provided for @travelerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover and book luxury stays worldwide'**
  String get travelerSubtitle;

  /// No description provided for @hotelPartner.
  ///
  /// In en, this message translates to:
  /// **'Hotel Partner'**
  String get hotelPartner;

  /// No description provided for @hotelPartnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List and manage your luxury properties'**
  String get hotelPartnerSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @hotelInformationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Hotel information not available'**
  String get hotelInformationNotAvailable;

  /// No description provided for @roomAvailable.
  ///
  /// In en, this message translates to:
  /// **'room available'**
  String get roomAvailable;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// No description provided for @perPage.
  ///
  /// In en, this message translates to:
  /// **'per page'**
  String get perPage;

  /// No description provided for @failedToLoadReviewerDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviewer details'**
  String get failedToLoadReviewerDetails;

  /// No description provided for @reviewedBy.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by'**
  String get reviewedBy;

  /// No description provided for @noCommentProvided.
  ///
  /// In en, this message translates to:
  /// **'No comment provided'**
  String get noCommentProvided;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoom;

  /// No description provided for @roomMarkedAsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Room marked as unavailable'**
  String get roomMarkedAsUnavailable;

  /// No description provided for @roomMarkedAsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Room marked as available'**
  String get roomMarkedAsAvailable;

  /// No description provided for @failedToUpdateRoom.
  ///
  /// In en, this message translates to:
  /// **'Failed to update room: {error}'**
  String failedToUpdateRoom(Object error);

  /// No description provided for @deleteRoom.
  ///
  /// In en, this message translates to:
  /// **'Delete Room'**
  String get deleteRoom;

  /// No description provided for @deleteRoomConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure?'**
  String get deleteRoomConfirmation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @roomDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Room deleted successfully'**
  String get roomDeletedSuccessfully;

  /// No description provided for @failedToDeleteRoom.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete room: {error}'**
  String failedToDeleteRoom(Object error);

  /// No description provided for @editRoom.
  ///
  /// In en, this message translates to:
  /// **'Edit Room'**
  String get editRoom;

  /// No description provided for @addNewRoom.
  ///
  /// In en, this message translates to:
  /// **'Add New Room'**
  String get addNewRoom;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @pricePerNight.
  ///
  /// In en, this message translates to:
  /// **'Price per night'**
  String get pricePerNight;

  /// No description provided for @availableForBooking.
  ///
  /// In en, this message translates to:
  /// **'Available for booking'**
  String get availableForBooking;

  /// No description provided for @roomPhotos.
  ///
  /// In en, this message translates to:
  /// **'Room Photos'**
  String get roomPhotos;

  /// No description provided for @updateRoom.
  ///
  /// In en, this message translates to:
  /// **'Update Room'**
  String get updateRoom;

  /// No description provided for @roomUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Room updated successfully'**
  String get roomUpdatedSuccessfully;

  /// No description provided for @roomAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Room added successfully'**
  String get roomAddedSuccessfully;

  /// No description provided for @failedToAddRoom.
  ///
  /// In en, this message translates to:
  /// **'Failed to add room: {error}'**
  String failedToAddRoom(Object error);

  /// No description provided for @failedToUpdateRoomGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed to update room: {error}'**
  String failedToUpdateRoomGeneric(Object error);

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{guest} other{guests}}'**
  String guest(num count);

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{photo} other{photos}}'**
  String photoCount(num count);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @markUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Unavailable'**
  String get markUnavailable;

  /// No description provided for @markAvailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Available'**
  String get markAvailable;

  /// No description provided for @pricingAvailability.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Availability'**
  String get pricingAvailability;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @resetFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFiltersTitle;

  /// No description provided for @resetFiltersContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all filters?'**
  String get resetFiltersContent;

  /// No description provided for @resetFiltersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get resetFiltersCancel;

  /// No description provided for @resetFiltersConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFiltersConfirm;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @filterByMinGuests.
  ///
  /// In en, this message translates to:
  /// **'Minimum Guests'**
  String get filterByMinGuests;

  /// No description provided for @filterByPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get filterByPriceRange;

  /// No description provided for @filterByCustomerRating.
  ///
  /// In en, this message translates to:
  /// **'Customer Rating'**
  String get filterByCustomerRating;

  /// No description provided for @filterByLocation.
  ///
  /// In en, this message translates to:
  /// **'Location (Wilaya)'**
  String get filterByLocation;

  /// No description provided for @allHotels.
  ///
  /// In en, this message translates to:
  /// **'All Hotels'**
  String get allHotels;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @selectDatesFirst.
  ///
  /// In en, this message translates to:
  /// **'Select dates first'**
  String get selectDatesFirst;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noItemsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No items to display'**
  String get noItemsToDisplay;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noHotelsDescription.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any hotels matching your criteria'**
  String get noHotelsDescription;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @findYourPerfectStay.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Stay'**
  String get findYourPerfectStay;

  /// No description provided for @discoverAmazingHotels.
  ///
  /// In en, this message translates to:
  /// **'Discover amazing hotels tailored just for you'**
  String get discoverAmazingHotels;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get currencySymbol;

  /// No description provided for @popularDestinations.
  ///
  /// In en, this message translates to:
  /// **'Popular Destinations'**
  String get popularDestinations;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or check back later'**
  String get tryAdjustingFilters;

  /// No description provided for @exploreAll.
  ///
  /// In en, this message translates to:
  /// **'Explore All'**
  String get exploreAll;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @luxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get luxury;

  /// No description provided for @hotelsFound.
  ///
  /// In en, this message translates to:
  /// **'Hotels Found'**
  String get hotelsFound;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @activityNewBooking.
  ///
  /// In en, this message translates to:
  /// **'New Booking'**
  String get activityNewBooking;

  /// No description provided for @activityBookingDescription.
  ///
  /// In en, this message translates to:
  /// **'{firstName} {lastName} booked {roomName}'**
  String activityBookingDescription(Object firstName, Object lastName, Object roomName);

  /// No description provided for @activityNewReview.
  ///
  /// In en, this message translates to:
  /// **'New Review'**
  String get activityNewReview;

  /// No description provided for @activityReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'{firstName} {lastName} left a {rating}-star review'**
  String activityReviewDescription(Object firstName, Object lastName, Object rating);

  /// No description provided for @hotelsInWilaya.
  ///
  /// In en, this message translates to:
  /// **'Hotels in {wilaya}'**
  String hotelsInWilaya(Object wilaya);

  /// No description provided for @currentlyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Currently Available'**
  String get currentlyAvailable;

  /// No description provided for @availableSoon.
  ///
  /// In en, this message translates to:
  /// **'Available Soon'**
  String get availableSoon;

  /// No description provided for @hotelsManagement.
  ///
  /// In en, this message translates to:
  /// **'Hotels Management'**
  String get hotelsManagement;

  /// No description provided for @searchByHotelNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by hotel name or email'**
  String get searchByHotelNameOrEmail;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @unsubscribed.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed'**
  String get unsubscribed;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noHotelsInDatabase.
  ///
  /// In en, this message translates to:
  /// **'No hotels found in the database'**
  String get noHotelsInDatabase;

  /// No description provided for @noHotelsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No hotels match your current filters'**
  String get noHotelsMatchFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Sub'**
  String get subscribe;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsub'**
  String get unsubscribe;

  /// No description provided for @errorLoadingHotels.
  ///
  /// In en, this message translates to:
  /// **'Error loading hotels'**
  String get errorLoadingHotels;

  /// No description provided for @errorUpdatingSubscription.
  ///
  /// In en, this message translates to:
  /// **'Error updating subscription status'**
  String get errorUpdatingSubscription;

  /// No description provided for @hotelNowSubscribed.
  ///
  /// In en, this message translates to:
  /// **'{hotelName} is now subscribed'**
  String hotelNowSubscribed(String hotelName);

  /// No description provided for @hotelNowUnsubscribed.
  ///
  /// In en, this message translates to:
  /// **'{hotelName} is now unsubscribed'**
  String hotelNowUnsubscribed(String hotelName);

  /// No description provided for @ratingValue.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count})'**
  String ratingValue(String rating, String count);

  /// No description provided for @adminsManagement.
  ///
  /// In en, this message translates to:
  /// **'Admins Management'**
  String get adminsManagement;

  /// No description provided for @administratorAccounts.
  ///
  /// In en, this message translates to:
  /// **'Administrator Accounts'**
  String get administratorAccounts;

  /// No description provided for @manageAdminAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage all administrator accounts and permissions'**
  String get manageAdminAccounts;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @noAdminAccounts.
  ///
  /// In en, this message translates to:
  /// **'No admin accounts found'**
  String get noAdminAccounts;

  /// No description provided for @noAdminsMatch.
  ///
  /// In en, this message translates to:
  /// **'No admins match your search'**
  String get noAdminsMatch;

  /// No description provided for @createNewAdmin.
  ///
  /// In en, this message translates to:
  /// **'Create a new admin account to get started'**
  String get createNewAdmin;

  /// No description provided for @adjustSearchCriteria.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria'**
  String get adjustSearchCriteria;

  /// No description provided for @addAdmin.
  ///
  /// In en, this message translates to:
  /// **'Add Admin'**
  String get addAdmin;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @editAdmin.
  ///
  /// In en, this message translates to:
  /// **'Edit Admin'**
  String get editAdmin;

  /// No description provided for @deleteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Delete Admin'**
  String get deleteAdmin;

  /// No description provided for @totalAdmins.
  ///
  /// In en, this message translates to:
  /// **'Total Admins'**
  String get totalAdmins;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// No description provided for @ofWord.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofWord;

  /// No description provided for @adminId.
  ///
  /// In en, this message translates to:
  /// **'Admin ID'**
  String get adminId;

  /// No description provided for @addNewAdmin.
  ///
  /// In en, this message translates to:
  /// **'Add New Admin'**
  String get addNewAdmin;

  /// No description provided for @createNewAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new administrator account'**
  String get createNewAdminAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @passwordMustBeLong.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordMustBeLong;

  /// No description provided for @creatingAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating admin account...'**
  String get creatingAdminAccount;

  /// No description provided for @adminCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Admin account created successfully'**
  String get adminCreatedSuccessfully;

  /// No description provided for @updateAdminInfo.
  ///
  /// In en, this message translates to:
  /// **'Update administrator information'**
  String get updateAdminInfo;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Admin Account'**
  String get deleteAdminAccount;

  /// No description provided for @confirmDeleteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this admin account?'**
  String get confirmDeleteAdmin;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get createdOn;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @updatingAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Updating admin account...'**
  String get updatingAdminAccount;

  /// No description provided for @adminUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Admin account updated successfully'**
  String get adminUpdatedSuccessfully;

  /// No description provided for @failedToLoadAdmins.
  ///
  /// In en, this message translates to:
  /// **'Failed to load admins: {error}'**
  String failedToLoadAdmins(Object error);

  /// No description provided for @bookingsManagement.
  ///
  /// In en, this message translates to:
  /// **'Bookings Management'**
  String get bookingsManagement;

  /// No description provided for @totalBookings.
  ///
  /// In en, this message translates to:
  /// **'Total Bookings'**
  String get totalBookings;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @nightsWord.
  ///
  /// In en, this message translates to:
  /// **'nights'**
  String get nightsWord;

  /// No description provided for @bookedOn.
  ///
  /// In en, this message translates to:
  /// **'Booked on'**
  String get bookedOn;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @unknownHotel.
  ///
  /// In en, this message translates to:
  /// **'Unknown Hotel'**
  String get unknownHotel;

  /// No description provided for @unknownRoom.
  ///
  /// In en, this message translates to:
  /// **'Unknown Room'**
  String get unknownRoom;

  /// No description provided for @errorLoadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings: {error}'**
  String errorLoadingBookings(Object error);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @startDateBeforeEndDate.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date'**
  String get startDateBeforeEndDate;

  /// No description provided for @endDateAfterStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get endDateAfterStartDate;

  /// No description provided for @selectBothDates.
  ///
  /// In en, this message translates to:
  /// **'Please select both start and end dates'**
  String get selectBothDates;

  /// No description provided for @loadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Loading bookings...'**
  String get loadingBookings;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
