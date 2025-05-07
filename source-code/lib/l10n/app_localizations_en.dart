import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get welcomeBackSimple => 'Welcome Back';

  @override
  String welcomeBack(Object hotelName) {
    return 'Welcome Back, $hotelName!';
  }

  @override
  String get signInToAccount => 'Sign in to access your account';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get emailValidationError => 'Please enter your email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordValidationError => 'Please enter your password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get orDivider => 'OR';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get userNotFound => 'User not found';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get missingPassword => 'Missing password';

  @override
  String get wrongCredentials => 'Wrong credentials';

  @override
  String get authError => 'Authentication error';

  @override
  String get bookings => 'Bookings';

  @override
  String get noHotelsFound => 'No hotels found';

  @override
  String roomCapacity(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# guests',
      one: '# guest',
    );
    return '$_temp0';
  }

  @override
  String get completed => 'Completed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get filterRating => 'Rating';

  @override
  String get filterPrice => 'Price';

  @override
  String get filterMinPeople => 'Guests';

  @override
  String get filterLocation => 'Location';

  @override
  String get logoutTitle => 'Log out';

  @override
  String get logoutContent => 'Are you sure you want to log out?';

  @override
  String get logout => 'Log Out';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get amenityWifi => 'WiFi';

  @override
  String get amenityPool => 'Pool';

  @override
  String get amenityGym => 'Gym';

  @override
  String get amenityRestaurant => 'Restaurant';

  @override
  String get amenitySpa => 'Spa';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityRoomService => 'Room Service';

  @override
  String get amenityPlayground => 'Kids Playground';

  @override
  String get amenityBar => 'Bar';

  @override
  String get amenityConcierge => 'Concierge';

  @override
  String get amenityBusinessCenter => 'Business Center';

  @override
  String get amenityLaundry => 'Laundry';

  @override
  String get amenityAirportShuttle => 'Airport Shuttle';

  @override
  String get amenityPetFriendly => 'Pet Friendly';

  @override
  String get amenityAccessible => 'Accessible';

  @override
  String get amenitySmokeFree => 'Smoke Free';

  @override
  String get amenityBeachAccess => 'Beach Access';

  @override
  String get amenityTv => 'TV';

  @override
  String get amenityAc => 'Air Conditioning';

  @override
  String get amenityHeating => 'Heating';

  @override
  String get amenitySafe => 'Safe';

  @override
  String get amenityKitchen => 'Kitchen';

  @override
  String get amenityMinibar => 'Minibar';

  @override
  String get amenityBathtub => 'Bathtub';

  @override
  String get amenityToiletries => 'Toiletries';

  @override
  String get noHotelsTitle => 'No Hotels Found';

  @override
  String get noHotelsDefaultMessage => 'We couldn\'t find any hotels matching your criteria. Try adjusting your search filters or exploring nearby locations.';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get bookingsNavTitle => 'Bookings';

  @override
  String get filterBookingsTitle => 'Filter Bookings';

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String get roomInformation => 'Room Information';

  @override
  String get guestInformation => 'Guest Information';

  @override
  String get bookingDates => 'Booking Dates';

  @override
  String get paymentInformation => 'Payment Information';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paid => 'Paid';

  @override
  String get markCompleted => 'Mark as Completed';

  @override
  String get checkIn => 'Check-in';

  @override
  String get checkOut => 'Check-out';

  @override
  String perNight(Object price) {
    return '$price per night';
  }

  @override
  String get noBookingsFound => 'No Bookings Found';

  @override
  String get noBookingsDefault => 'You don\'t have any bookings yet';

  @override
  String noFilteredBookings(Object status) {
    return 'No $status bookings found';
  }

  @override
  String get failedToLoadBookings => 'Failed to load bookings';

  @override
  String get retry => 'Retry';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryPending => 'Pending';

  @override
  String get summaryCompleted => 'Completed';

  @override
  String get summaryRevenue => 'Revenue';

  @override
  String get complete => 'Complete';

  @override
  String nights(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nights',
      one: 'night',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSubtitle => 'Here\'s what\'s happening today';

  @override
  String get activeBookings => 'Active Bookings';

  @override
  String get roomsAvailable => 'Rooms Available';

  @override
  String get totalReviews => 'Total Reviews';

  @override
  String get pendingBookings => 'Pending Bookings';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get roomsTitle => 'Rooms';

  @override
  String get roomsDescription => 'Manage room details';

  @override
  String get bookingsDescription => 'View all bookings';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get reviewsDescription => 'Check guest feedback';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDescription => 'Hotel profile';

  @override
  String get validUrl => 'Type a valid url!';

  @override
  String get emptyInput => 'Input can\'t be empty!';

  @override
  String get updateLocation => 'Update Location';

  @override
  String get updateDescription => 'Update Description';

  @override
  String get updateMapLink => 'Update Map Link';

  @override
  String get updateContactInfo => 'Update Contact Information';

  @override
  String get completeHotelProfile => 'Complete Your Hotel Profile';

  @override
  String get selectWilaya => 'Select a Wilaya';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get next => 'Next';

  @override
  String get loadingPlaceholder => 'Loading';

  @override
  String get inputEmpty => 'Input can\'t be empty!';

  @override
  String get updateContactInformation => 'Update Contact Information';

  @override
  String enterField(Object field) {
    return 'Enter $field...';
  }

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logOut => 'Log Out';

  @override
  String get hotelPhotos => 'Hotel Photos';

  @override
  String get noPhotosAdded => 'No photos added';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get hotelName => 'Hotel Name';

  @override
  String get required => 'Required';

  @override
  String get description => 'Description';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get location => 'Location';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get mapLink => 'Map Link';

  @override
  String get profileUpdatedSuccessfully => 'Your profile data has been updated successfully.';

  @override
  String get errorUpdatingProfile => 'Error updating profile';

  @override
  String get imageUploadedSuccessfully => 'Image uploaded successfully';

  @override
  String errorUploadingImage(Object error) {
    return 'Error uploading image: $error';
  }

  @override
  String get imageRemovedSuccessfully => 'Image removed successfully';

  @override
  String errorRemovingImage(Object error) {
    return 'Error removing image: $error';
  }

  @override
  String get guestReviews => 'Guest Reviews';

  @override
  String get all => 'All';

  @override
  String stars(Object count) {
    return '$count Stars';
  }

  @override
  String reviewsCount(Object count) {
    return '$count Reviews';
  }

  @override
  String get errorLoadingReviews => 'Error loading reviews';

  @override
  String get home => 'Home';

  @override
  String get rooms => 'rooms';

  @override
  String get reviews => 'reviews';

  @override
  String get hotelRegistration => 'Hotel Registration';

  @override
  String get registerHotel => 'Register Your Hotel';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get registerHotelButton => 'Register Hotel';

  @override
  String get enterHotelName => 'Please enter your hotel\'s name.';

  @override
  String get validEmail => 'Please enter a valid email address.';

  @override
  String get passwordLength => 'Password must be at least 6 characters long.';

  @override
  String get passwordMatch => 'Passwords do not match.';

  @override
  String get weakPassword => 'The password provided is too weak.';

  @override
  String get emailInUse => 'Email is already in use';

  @override
  String get registerFailed => 'Failed to register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinFatiel => 'Join Fatiel';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get firstNameLastNameRequired => 'Please enter your first and last name.';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get checkInDate => 'Check-in Date';

  @override
  String get checkOutDate => 'Check-out Date';

  @override
  String get totalNights => 'Total Nights';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get confirmAndPay => 'Confirm & Pay';

  @override
  String get selectCheckInDate => 'Select Check-in Date';

  @override
  String get selectCheckOutDate => 'Select Check-out Date';

  @override
  String get confirm => 'Confirm';

  @override
  String get bookingConfirmed => 'Booking confirmed successfully!';

  @override
  String get from => 'From';

  @override
  String get night => 'night';

  @override
  String get bookNow => 'Book Now';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get oopsSomethingWentWrong => 'Oops! Something went wrong';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get removeHotelFromFavoritesConfirmation => 'Are you sure you want to remove this hotel from your favorites?';

  @override
  String get remove => 'Remove';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get failedToUpdateFavorites => 'Failed to update favorites';

  @override
  String get removeFromFavoritesSemantic => 'Remove from favorites';

  @override
  String get addToFavoritesSemantic => 'Add to favorites';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get locationNotSpecified => 'Location not specified';

  @override
  String get noImageAvailable => 'No image available';

  @override
  String get hotel => 'hotel';

  @override
  String get hotels => 'hotels';

  @override
  String get tryAdjustingSearchFilters => 'Try adjusting your search filters';

  @override
  String get noDataFound => 'No Data Found';

  @override
  String get noPopularDestinationsAvailable => 'No popular destinations available at the moment.';

  @override
  String get error => 'Error';

  @override
  String get guests => 'Guests';

  @override
  String get available => 'Available';

  @override
  String get seeAll => 'See All';

  @override
  String get allWilayas => 'All Wilayas';

  @override
  String get failedToLoadWilayaData => 'Failed to load wilaya data';

  @override
  String get noHotelsListedInAnyWilaya => 'No hotels currently listed in any wilaya';

  @override
  String get discoveringAmazingPlaces => 'Discovering amazing places for you';

  @override
  String get bookingSummary => 'Booking Summary';

  @override
  String get priceSummary => 'Price Summary';

  @override
  String get roomRate => 'Room Rate';

  @override
  String get duration => 'Duration';

  @override
  String get roomDetails => 'Room Details';

  @override
  String get capacity => 'Capacity';

  @override
  String get exploreHotel => 'Explore Hotel';

  @override
  String get bookingError => 'Booking Error';

  @override
  String get goBack => 'Go Back';

  @override
  String get noBookingFound => 'No Booking Found';

  @override
  String get noBookingDetails => 'We couldn\'t find any booking details';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get failedToLoadBookingDetails => 'Failed to load booking details';

  @override
  String get bookingDetailsNotAvailable => 'Booking details not available';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get viewDetails => 'View Details';

  @override
  String get writeAReview => 'Write a Review';

  @override
  String get editReview => 'Edit Review';

  @override
  String get shareYourExperience => 'Share your experience...';

  @override
  String get pleaseWriteAComment => 'Please write a comment';

  @override
  String get submit => 'Submit';

  @override
  String get update => 'Update';

  @override
  String get deleteReview => 'Delete Review';

  @override
  String get areYouSureDeleteReview => 'Are you sure you want to delete this review?';

  @override
  String get delete => 'Delete';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get areYouSureCancelBooking => 'Are you sure you want to cancel this booking?';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get exploreHotels => 'Explore Hotels';

  @override
  String get noPendingBookings => 'No Pending Bookings!';

  @override
  String get noCompletedBookings => 'No Completed Bookings!';

  @override
  String get noCancelledBookings => 'No Cancelled Bookings!';

  @override
  String get startYourJourney => 'Start your journey today! Find the best hotels\nand book your dream stay effortlessly.';

  @override
  String get completedBookingsAppearHere => 'Your completed bookings will appear here.\nShare your experience by leaving reviews!';

  @override
  String get cancelledBookingsAppearHere => 'Your cancelled bookings will appear here.\nYou can always book again!';

  @override
  String get pending => 'Pending';

  @override
  String get amenities => 'Amenities';

  @override
  String get recommended => 'Recommended';

  @override
  String get nearMe => 'Near Me';

  @override
  String get recommendedHotels => 'Recommended Hotels';

  @override
  String get hotelsNearYou => 'Hotels Near You';

  @override
  String get success => 'Success';

  @override
  String get failedToLoadHotels => 'Failed to load hotels';

  @override
  String get noHotelsAvailable => 'No Hotels Available';

  @override
  String get noHotelsMatchingCriteria => 'We couldn\'t find any hotels matching your criteria.';

  @override
  String get findHotelsInCities => 'Find hotels in cities';

  @override
  String get failedToLoadCityData => 'Failed to load city data';

  @override
  String get noHotelsListedInCities => 'No hotels are currently listed in these cities.';

  @override
  String get loadingYourFavorites => 'Loading your favorites';

  @override
  String get couldntLoadFavorites => 'Couldn\'t load favorites';

  @override
  String get checkConnectionAndTryAgain => 'Please check your connection and try again';

  @override
  String get noFavoritesYet => 'No Favorites Yet';

  @override
  String get saveFavoritesMessage => 'Save your favorite hotels by tapping the heart icon when browsing';

  @override
  String get browseHotels => 'Browse Hotels';

  @override
  String recommendedHotelsCount(Object count) {
    return 'Recommended Hotels ($count)';
  }

  @override
  String hotelsNearYouCount(Object count) {
    return 'Hotels Near You ($count)';
  }

  @override
  String get weCouldntFindAnyHotels => 'We couldn\'t find any hotels matching your criteria.';

  @override
  String get noReviewsDataAvailable => 'No reviews data available';

  @override
  String get guestFavorite => 'Guest Favorite';

  @override
  String basedOnReviews(Object totalRatings) {
    return 'Based on $totalRatings reviews';
  }

  @override
  String starsCount(Object ratingCount) {
    return '$ratingCount Stars';
  }

  @override
  String get exploreRoomOffers => 'Explore room offers';

  @override
  String get perNightSimple => 'Per night';

  @override
  String get roomType => 'Room Type';

  @override
  String get dates => 'Dates';

  @override
  String get successfullyBooked => 'Successfully booked';

  @override
  String get noAmenitiesListed => 'No amenities listed';

  @override
  String get availableFrom => 'Available from';

  @override
  String get notCurrentlyAvailable => 'Not currently available';

  @override
  String get failedToLoadRooms => 'Failed to load rooms';

  @override
  String get noRoomsAvailable => 'No rooms available';

  @override
  String get searchHotels => 'Search Hotels';

  @override
  String get searchHotelsLocations => 'Search hotels, locations...';

  @override
  String get searchForHotels => 'Search for hotels';

  @override
  String get enterHotelNameLocation => 'Enter hotel name, location or amenities to find your perfect stay';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get inputCantBeEmpty => 'Input can\'t be empty!';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get updateFirstName => 'Update first name';

  @override
  String get updateLastName => 'Update last name';

  @override
  String get selectLocation => 'Select location';

  @override
  String get updateYourInformation => 'Update Your Information';

  @override
  String get selectAWilaya => 'Select a Wilaya';

  @override
  String get enter => 'Enter';

  @override
  String get passwordUpdatedSuccessfully => 'Your password has been updated successfully';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordMustBeAtLeast6Characters => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get wrongPassword => 'Your current password is incorrect.';

  @override
  String get requiresRecentLogin => 'Please reauthenticate to update your password.';

  @override
  String get genericError => 'An unexpected error occurred. Please try again.';

  @override
  String get failedToUpdatePassword => 'Failed to update password. Please try again.';

  @override
  String get passwordMismatch => 'Password Mismatch';

  @override
  String get explore => 'Explore';

  @override
  String get favorites => 'Favorites';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get imageUploadFailed => 'Image upload failed';

  @override
  String get profileImageUpdatedSuccessfully => 'Profile image updated successfully';

  @override
  String get failedToUploadImage => 'Failed to upload image';

  @override
  String get removeProfileImage => 'Remove Profile Image';

  @override
  String get removeProfileImageConfirmation => 'Are you sure you want to remove your profile image?';

  @override
  String get profileImageRemoved => 'Profile image removed';

  @override
  String get failedToRemoveImage => 'Failed to remove image';

  @override
  String get ok => 'OK';

  @override
  String get uploading => 'Uploading...';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get wilayaNotFound => 'Wilaya not found';

  @override
  String get wilayaDataNotAvailable => 'Wilaya data not available';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String noHotelsRegistered(Object wilayaName) {
    return 'There are currently no hotels registered in $wilayaName';
  }

  @override
  String get pleaseWaitAMoment => 'Please wait a moment';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get passwordReset => 'Password reset';

  @override
  String get passwordResetSentMessage => 'We have now sent you a password reset link.';

  @override
  String get forgotPasswordGenericError => 'We could not process your request. Please make sure that you are a registered user, or if not, register a user now by going back one step.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get forgotPasswordInstructions => 'Enter your registered email address to receive a password reset link';

  @override
  String get enterYourEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get failedToLoadHotelDetails => 'Failed to load hotel details';

  @override
  String get noHotelInformationAvailable => 'No hotel information available';

  @override
  String get room => 'Room';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get noContactInformationAvailable => 'No contact information available';

  @override
  String get ratingsAndReviews => 'Ratings & Reviews';

  @override
  String get viewAll => 'View all';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get locationOnMap => 'Location on Map';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get mapLocationNotAvailable => 'Map location not available';

  @override
  String get roomOffers => 'Room Offers';

  @override
  String get viewRoomOffers => 'View Room Offers';

  @override
  String get selectAccountType => 'Select your account type to begin';

  @override
  String get traveler => 'Traveler';

  @override
  String get travelerSubtitle => 'Discover and book luxury stays worldwide';

  @override
  String get hotelPartner => 'Hotel Partner';

  @override
  String get hotelPartnerSubtitle => 'List and manage your luxury properties';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get hotelInformationNotAvailable => 'Hotel information not available';

  @override
  String get roomAvailable => 'room available';

  @override
  String get premium => 'PREMIUM';

  @override
  String get perPage => 'per page';

  @override
  String get failedToLoadReviewerDetails => 'Failed to load reviewer details';

  @override
  String get reviewedBy => 'Reviewed by';

  @override
  String get noCommentProvided => 'No comment provided';

  @override
  String get addRoom => 'Add Room';

  @override
  String get roomMarkedAsUnavailable => 'Room marked as unavailable';

  @override
  String get roomMarkedAsAvailable => 'Room marked as available';

  @override
  String failedToUpdateRoom(Object error) {
    return 'Failed to update room: $error';
  }

  @override
  String get deleteRoom => 'Delete Room';

  @override
  String get deleteRoomConfirmation => 'This action cannot be undone. Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get roomDeletedSuccessfully => 'Room deleted successfully';

  @override
  String failedToDeleteRoom(Object error) {
    return 'Failed to delete room: $error';
  }

  @override
  String get editRoom => 'Edit Room';

  @override
  String get addNewRoom => 'Add New Room';

  @override
  String get roomName => 'Room Name';

  @override
  String get pricePerNight => 'Price per night';

  @override
  String get availableForBooking => 'Available for booking';

  @override
  String get roomPhotos => 'Room Photos';

  @override
  String get updateRoom => 'Update Room';

  @override
  String get roomUpdatedSuccessfully => 'Room updated successfully';

  @override
  String get roomAddedSuccessfully => 'Room added successfully';

  @override
  String failedToAddRoom(Object error) {
    return 'Failed to add room: $error';
  }

  @override
  String failedToUpdateRoomGeneric(Object error) {
    return 'Failed to update room: $error';
  }

  @override
  String guest(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'guests',
      one: 'guest',
    );
    return '$_temp0';
  }

  @override
  String photoCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'photos',
      one: 'photo',
    );
    return '$_temp0';
  }

  @override
  String get edit => 'Edit';

  @override
  String get markUnavailable => 'Mark Unavailable';

  @override
  String get markAvailable => 'Mark Available';

  @override
  String get pricingAvailability => 'Pricing & Availability';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get resetFiltersTitle => 'Reset Filters';

  @override
  String get resetFiltersContent => 'Are you sure you want to reset all filters?';

  @override
  String get resetFiltersCancel => 'Cancel';

  @override
  String get resetFiltersConfirm => 'Reset';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get filterByMinGuests => 'Minimum Guests';

  @override
  String get filterByPriceRange => 'Price Range';

  @override
  String get filterByCustomerRating => 'Customer Rating';

  @override
  String get filterByLocation => 'Location (Wilaya)';

  @override
  String get allHotels => 'All Hotels';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get selectDatesFirst => 'Select dates first';

  @override
  String get refresh => 'Refresh';

  @override
  String get noItemsToDisplay => 'No items to display';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noHotelsDescription => 'We couldn\'t find any hotels matching your criteria';

  @override
  String get reset => 'Reset';

  @override
  String get hello => 'Hello';

  @override
  String get findYourPerfectStay => 'Find Your Perfect Stay';

  @override
  String get discoverAmazingHotels => 'Discover amazing hotels tailored just for you';

  @override
  String get startingFrom => 'Starting from';

  @override
  String get currencySymbol => 'DZD';

  @override
  String get popularDestinations => 'Popular Destinations';

  @override
  String get tryAdjustingFilters => 'Try adjusting your filters or search criteria';

  @override
  String get exploreAll => 'Explore All';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get luxury => 'Luxury';

  @override
  String get hotelsFound => 'Hotels Found';

  @override
  String get facilities => 'Facilities';

  @override
  String get availability => 'Availability';

  @override
  String get activityNewBooking => 'New Booking';

  @override
  String activityBookingDescription(Object firstName, Object lastName, Object roomName) {
    return '$firstName $lastName booked $roomName';
  }

  @override
  String get activityNewReview => 'New Review';

  @override
  String activityReviewDescription(Object firstName, Object lastName, Object rating) {
    return '$firstName $lastName left a $rating-star review';
  }

  @override
  String hotelsInWilaya(Object wilaya) {
    return 'Hotels in $wilaya';
  }

  @override
  String get currentlyAvailable => 'Currently Available';

  @override
  String get availableSoon => 'Available Soon';

  @override
  String get hotelsManagement => 'Hotels Management';

  @override
  String get searchByHotelNameOrEmail => 'Search by hotel name or email';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get unsubscribed => 'Unsubscribed';

  @override
  String get inactive => 'Inactive';

  @override
  String get unknown => 'Unknown';

  @override
  String get noHotelsInDatabase => 'No hotels found in the database';

  @override
  String get noHotelsMatchFilters => 'No hotels match your current filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get subscribe => 'Sub';

  @override
  String get unsubscribe => 'Unsub';

  @override
  String get errorLoadingHotels => 'Error loading hotels';

  @override
  String get errorUpdatingSubscription => 'Error updating subscription status';

  @override
  String hotelNowSubscribed(String hotelName) {
    return '$hotelName is now subscribed';
  }

  @override
  String hotelNowUnsubscribed(String hotelName) {
    return '$hotelName is now unsubscribed';
  }

  @override
  String ratingValue(String rating, String count) {
    return '$rating ($count)';
  }
}
