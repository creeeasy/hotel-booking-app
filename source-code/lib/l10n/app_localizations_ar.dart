import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get welcomeBackSimple => 'أهلاً بعودتك';

  @override
  String welcomeBack(Object hotelName) {
    return 'أهلاً بعودتك، $hotelName!';
  }

  @override
  String get signInToAccount => 'سجل الدخول للوصول إلى حسابك';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get emailValidationError => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordValidationError => 'الرجاء إدخال كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get orDivider => 'أو';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟ ';

  @override
  String get register => 'تسجيل';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get missingPassword => 'كلمة المرور مفقودة';

  @override
  String get wrongCredentials => 'بيانات اعتماد خاطئة';

  @override
  String get authError => 'خطأ في المصادقة';

  @override
  String get bookings => 'الحجوزات';

  @override
  String get noHotelsFound => 'لم يتم العثور على فنادق';

  @override
  String roomCapacity(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# ضيوف',
      one: '# ضيف',
    );
    return '$_temp0';
  }

  @override
  String get completed => 'مكتمل';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get filterRating => 'التقييم';

  @override
  String get filterPrice => 'السعر';

  @override
  String get filterMinPeople => 'الضيوف';

  @override
  String get filterLocation => 'الموقع';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutContent => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(Object minutes) {
    return 'منذ $minutes دقيقة';
  }

  @override
  String hoursAgo(Object hours) {
    return 'منذ $hours ساعة';
  }

  @override
  String daysAgo(Object days) {
    return 'منذ $days يوم';
  }

  @override
  String get amenityWifi => 'واي فاي';

  @override
  String get amenityPool => 'مسبح';

  @override
  String get amenityGym => 'صالة رياضية';

  @override
  String get amenityRestaurant => 'مطعم';

  @override
  String get amenitySpa => 'منتجع صحي';

  @override
  String get amenityParking => 'موقف سيارات';

  @override
  String get amenityRoomService => 'خدمة الغرف';

  @override
  String get amenityPlayground => 'ملعب للأطفال';

  @override
  String get amenityBar => 'بار';

  @override
  String get amenityConcierge => 'خدمة الكونسيرج';

  @override
  String get amenityBusinessCenter => 'مركز أعمال';

  @override
  String get amenityLaundry => 'غسيل الملابس';

  @override
  String get amenityAirportShuttle => 'خدمة نقل المطار';

  @override
  String get amenityPetFriendly => 'صديق للحيوانات الأليفة';

  @override
  String get amenityAccessible => 'يمكن الوصول إليه';

  @override
  String get amenitySmokeFree => 'ممنوع التدخين';

  @override
  String get amenityBeachAccess => 'الوصول إلى الشاطئ';

  @override
  String get amenityTv => 'تلفزيون';

  @override
  String get amenityAc => 'تكييف';

  @override
  String get amenityHeating => 'تدفئة';

  @override
  String get amenitySafe => 'خزنة';

  @override
  String get amenityKitchen => 'مطبخ';

  @override
  String get amenityMinibar => 'ميني بار';

  @override
  String get amenityBathtub => 'حوض استحمام';

  @override
  String get amenityToiletries => 'أدوات استحمام';

  @override
  String get noHotelsTitle => 'لم يتم العثور على فنادق';

  @override
  String get noHotelsDefaultMessage => 'لم نتمكن من العثور على أي فنادق تطابق معاييرك. حاول تعديل عوامل تصفية البحث أو استكشاف المواقع القريبة.';

  @override
  String get bookingsTitle => 'الحجوزات';

  @override
  String get bookingsNavTitle => 'الحجوزات';

  @override
  String get filterBookingsTitle => 'تصفية الحجوزات';

  @override
  String get bookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String get roomInformation => 'معلومات الغرفة';

  @override
  String get guestInformation => 'معلومات الضيف';

  @override
  String get bookingDates => 'تواريخ الحجز';

  @override
  String get paymentInformation => 'معلومات الدفع';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get paid => 'مدفوع';

  @override
  String get markCompleted => 'وضع علامة كمكتمل';

  @override
  String get checkIn => 'تاريخ الوصول';

  @override
  String get checkOut => 'تاريخ المغادرة';

  @override
  String perNight(Object price) {
    return '$price لليلة الواحدة';
  }

  @override
  String get noBookingsFound => 'لا توجد حجوزات';

  @override
  String get noBookingsDefault => 'ليس لديك أي حجوزات حتى الآن';

  @override
  String noFilteredBookings(Object status) {
    return 'لم يتم العثور على حجوزات $status';
  }

  @override
  String get failedToLoadBookings => 'فشل تحميل الحجوزات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get summaryTotal => 'الإجمالي';

  @override
  String get summaryPending => 'قيد الانتظار';

  @override
  String get summaryCompleted => 'مكتمل';

  @override
  String get summaryRevenue => 'الإيرادات';

  @override
  String get complete => 'إكمال';

  @override
  String nights(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ليالي',
      one: 'ليلة',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSubtitle => 'إليك ما يحدث اليوم';

  @override
  String get activeBookings => 'الحجوزات النشطة';

  @override
  String get roomsAvailable => 'الغرف المتاحة';

  @override
  String get totalReviews => 'إجمالي التقييمات';

  @override
  String get pendingBookings => 'الحجوزات قيد الانتظار';

  @override
  String get quickAccess => 'الوصول السريع';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get noRecentActivity => 'لا يوجد نشاط أخير';

  @override
  String get roomsTitle => 'الغرف';

  @override
  String get roomsDescription => 'إدارة تفاصيل الغرف';

  @override
  String get bookingsDescription => 'عرض جميع الحجوزات';

  @override
  String get reviewsTitle => 'التقييمات';

  @override
  String get reviewsDescription => 'تحقق من ملاحظات الضيوف';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileDescription => 'الملف الشخصي للفندق';

  @override
  String get validUrl => 'اكتب عنوان URL صالحًا!';

  @override
  String get emptyInput => 'لا يمكن أن يكون الإدخال فارغًا!';

  @override
  String get updateLocation => 'تحديث الموقع';

  @override
  String get updateDescription => 'تحديث الوصف';

  @override
  String get updateMapLink => 'تحديث رابط الخريطة';

  @override
  String get updateContactInfo => 'تحديث معلومات الاتصال';

  @override
  String get completeHotelProfile => 'أكمل ملف تعريف فندقك';

  @override
  String get selectWilaya => 'اختر ولاية';

  @override
  String get back => 'رجوع';

  @override
  String get finish => 'إنهاء';

  @override
  String get next => 'التالي';

  @override
  String get loadingPlaceholder => 'جاري التحميل';

  @override
  String get inputEmpty => 'لا يمكن أن يكون الإدخال فارغًا!';

  @override
  String get updateContactInformation => 'تحديث معلومات الاتصال';

  @override
  String enterField(Object field) {
    return 'أدخل $field...';
  }

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get hotelPhotos => 'صور الفندق';

  @override
  String get noPhotosAdded => 'لم تتم إضافة صور';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get hotelName => 'اسم الفندق';

  @override
  String get required => 'مطلوب';

  @override
  String get description => 'الوصف';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get location => 'الموقع';

  @override
  String get wilaya => 'الولاية';

  @override
  String get mapLink => 'رابط الخريطة';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث بيانات ملفك الشخصي بنجاح.';

  @override
  String get errorUpdatingProfile => 'خطأ في تحديث الملف الشخصي';

  @override
  String get imageUploadedSuccessfully => 'تم تحميل الصورة بنجاح';

  @override
  String errorUploadingImage(Object error) {
    return 'خطأ في تحميل الصورة: $error';
  }

  @override
  String get imageRemovedSuccessfully => 'تمت إزالة الصورة بنجاح';

  @override
  String errorRemovingImage(Object error) {
    return 'خطأ في إزالة الصورة: $error';
  }

  @override
  String get guestReviews => 'تقييمات الضيوف';

  @override
  String get all => 'الكل';

  @override
  String stars(Object count) {
    return '$count نجوم';
  }

  @override
  String reviewsCount(Object count) {
    return '$count تقييمات';
  }

  @override
  String get errorLoadingReviews => 'خطأ في تحميل التقييمات';

  @override
  String get home => 'الرئيسية';

  @override
  String get rooms => 'غرف';

  @override
  String get reviews => 'تقييمات';

  @override
  String get hotelRegistration => 'تسجيل الفندق';

  @override
  String get registerHotel => 'سجل فندقك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get registerHotelButton => 'تسجيل الفندق';

  @override
  String get enterHotelName => 'الرجاء إدخال اسم فندقك.';

  @override
  String get validEmail => 'الرجاء إدخال عنوان بريد إلكتروني صالح.';

  @override
  String get passwordLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل.';

  @override
  String get passwordMatch => 'كلمات المرور غير متطابقة.';

  @override
  String get weakPassword => 'كلمة المرور المقدمة ضعيفة جدًا.';

  @override
  String get emailInUse => 'البريد الإلكتروني قيد الاستخدام بالفعل';

  @override
  String get registerFailed => 'فشل التسجيل';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinFatiel => 'انضم إلى فتيل';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get firstNameLastNameRequired => 'الرجاء إدخال اسمك الأول واسم عائلتك.';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get checkInDate => 'تاريخ تسجيل الوصول';

  @override
  String get checkOutDate => 'تاريخ تسجيل المغادرة';

  @override
  String get totalNights => 'إجمالي الليالي';

  @override
  String get totalPrice => 'السعر الإجمالي';

  @override
  String get confirmAndPay => 'تأكيد والدفع';

  @override
  String get selectCheckInDate => 'حدد تاريخ تسجيل الوصول';

  @override
  String get selectCheckOutDate => 'حدد تاريخ تسجيل المغادرة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get bookingConfirmed => 'تم تأكيد الحجز بنجاح!';

  @override
  String get from => 'من';

  @override
  String get night => 'ليلة';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get oopsSomethingWentWrong => 'عفوًا! حدث خطأ ما';

  @override
  String get goToHome => 'الذهاب إلى الرئيسية';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get removeHotelFromFavoritesConfirmation => 'هل أنت متأكد من أنك تريد إزالة هذا الفندق من مفضلاتك؟';

  @override
  String get remove => 'إزالة';

  @override
  String get addedToFavorites => 'تمت الإضافة إلى المفضلة';

  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة';

  @override
  String get failedToUpdateFavorites => 'فشل تحديث المفضلة';

  @override
  String get removeFromFavoritesSemantic => 'إزالة من المفضلة';

  @override
  String get addToFavoritesSemantic => 'إضافة إلى المفضلة';

  @override
  String get imageNotAvailable => 'الصورة غير متوفرة';

  @override
  String get locationNotSpecified => 'الموقع غير محدد';

  @override
  String get noImageAvailable => 'لا توجد صورة متاحة';

  @override
  String get hotel => 'فندق';

  @override
  String get hotels => 'فنادق';

  @override
  String get tryAdjustingSearchFilters => 'حاول تعديل عوامل تصفية البحث';

  @override
  String get noDataFound => 'لم يتم العثور على بيانات';

  @override
  String get noPopularDestinationsAvailable => 'لا توجد وجهات شهيرة متاحة في الوقت الحالي.';

  @override
  String get error => 'خطأ';

  @override
  String get guests => 'ضيوف';

  @override
  String get available => 'متاح';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get allWilayas => 'جميع الولايات';

  @override
  String get failedToLoadWilayaData => 'فشل تحميل بيانات الولاية';

  @override
  String get noHotelsListedInAnyWilaya => 'لا توجد فنادق مدرجة حاليًا في أي ولاية';

  @override
  String get discoveringAmazingPlaces => 'اكتشاف أماكن رائعة لك';

  @override
  String get bookingSummary => 'ملخص الحجز';

  @override
  String get priceSummary => 'ملخص السعر';

  @override
  String get roomRate => 'سعر الغرفة';

  @override
  String get duration => 'المدة';

  @override
  String get roomDetails => 'تفاصيل الغرفة';

  @override
  String get capacity => 'السعة';

  @override
  String get exploreHotel => 'استكشاف الفندق';

  @override
  String get bookingError => 'خطأ في الحجز';

  @override
  String get goBack => 'العودة';

  @override
  String get noBookingFound => 'لم يتم العثور على حجز';

  @override
  String get noBookingDetails => 'لم نتمكن من العثور على أي تفاصيل حجز';

  @override
  String get myBookings => 'حجوزاتي';

  @override
  String get failedToLoadBookingDetails => 'فشل تحميل تفاصيل الحجز';

  @override
  String get bookingDetailsNotAvailable => 'تفاصيل الحجز غير متوفرة';

  @override
  String get unknownLocation => 'موقع غير معروف';

  @override
  String get cancelled => 'ملغى';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get writeAReview => 'اكتب تقييمًا';

  @override
  String get editReview => 'تعديل التقييم';

  @override
  String get shareYourExperience => 'شارك تجربتك...';

  @override
  String get pleaseWriteAComment => 'الرجاء كتابة تعليق';

  @override
  String get submit => 'إرسال';

  @override
  String get update => 'تحديث';

  @override
  String get deleteReview => 'حذف التقييم';

  @override
  String get areYouSureDeleteReview => 'هل أنت متأكد من أنك تريد حذف هذا التقييم؟';

  @override
  String get delete => 'حذف';

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String get areYouSureCancelBooking => 'هل أنت متأكد من أنك تريد إلغاء هذا الحجز؟';

  @override
  String get no => 'لا';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get exploreHotels => 'استكشاف الفنادق';

  @override
  String get noPendingBookings => 'لا توجد حجوزات قيد الانتظار!';

  @override
  String get noCompletedBookings => 'لا توجد حجوزات مكتملة!';

  @override
  String get noCancelledBookings => 'لا توجد حجوزات ملغاة!';

  @override
  String get startYourJourney => 'ابدأ رحلتك اليوم! ابحث عن أفضل الفنادق\nواحجز إقامتك التي تحلم بها بسهولة.';

  @override
  String get completedBookingsAppearHere => 'ستظهر حجوزاتك المكتملة هنا.\nشارك تجربتك بترك التقييمات!';

  @override
  String get cancelledBookingsAppearHere => 'ستظهر حجوزاتك الملغاة هنا.\nيمكنك دائمًا الحجز مرة أخرى!';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get amenities => 'وسائل الراحة';

  @override
  String get recommended => 'مُوصى به';

  @override
  String get nearMe => 'بالقرب مني';

  @override
  String get recommendedHotels => 'الفنادق الموصى بها';

  @override
  String get hotelsNearYou => 'الفنادق القريبة منك';

  @override
  String get success => 'نجاح';

  @override
  String get failedToLoadHotels => 'فشل تحميل الفنادق';

  @override
  String get noHotelsAvailable => 'لا توجد فنادق متاحة';

  @override
  String get noHotelsMatchingCriteria => 'لم نتمكن من العثور على أي فنادق تطابق معاييرك.';

  @override
  String get findHotelsInCities => 'ابحث عن فنادق في المدن';

  @override
  String get failedToLoadCityData => 'فشل تحميل بيانات المدينة';

  @override
  String get noHotelsListedInCities => 'لا توجد فنادق مدرجة حاليًا في هذه المدن.';

  @override
  String get loadingYourFavorites => 'جارٍ تحميل مفضلاتك';

  @override
  String get couldntLoadFavorites => 'تعذر تحميل المفضلة';

  @override
  String get checkConnectionAndTryAgain => 'يرجى التحقق من اتصالك والمحاولة مرة أخرى';

  @override
  String get noFavoritesYet => 'لا توجد مفضلات حتى الآن';

  @override
  String get saveFavoritesMessage => 'احفظ فنادقك المفضلة بالنقر على أيقونة القلب عند التصفح';

  @override
  String get browseHotels => 'تصفح الفنادق';

  @override
  String recommendedHotelsCount(Object count) {
    return 'الفنادق الموصى بها ($count)';
  }

  @override
  String hotelsNearYouCount(Object count) {
    return 'الفنادق القريبة منك ($count)';
  }

  @override
  String get weCouldntFindAnyHotels => 'لم نتمكن من العثور على أي فنادق تطابق معاييرك.';

  @override
  String get noReviewsDataAvailable => 'لا توجد بيانات تقييمات متاحة';

  @override
  String get guestFavorite => 'المفضلة لدى الضيوف';

  @override
  String basedOnReviews(Object totalRatings) {
    return 'بناءً على $totalRatings تقييمات';
  }

  @override
  String starsCount(Object ratingCount) {
    return '$ratingCount نجوم';
  }

  @override
  String get exploreRoomOffers => 'استكشف عروض الغرف';

  @override
  String get perNightSimple => 'لليلة الواحدة';

  @override
  String get roomType => 'نوع الغرفة';

  @override
  String get dates => 'التواريخ';

  @override
  String get successfullyBooked => 'تم الحجز بنجاح';

  @override
  String get noAmenitiesListed => 'لا توجد وسائل راحة مدرجة';

  @override
  String get availableFrom => 'متاح من';

  @override
  String get notCurrentlyAvailable => 'غير متاح حاليًا';

  @override
  String get failedToLoadRooms => 'فشل تحميل الغرف';

  @override
  String get noRoomsAvailable => 'لا توجد غرف متاحة';

  @override
  String get searchHotels => 'البحث عن فنادق';

  @override
  String get searchHotelsLocations => 'البحث عن فنادق، مواقع...';

  @override
  String get searchForHotels => 'البحث عن فنادق';

  @override
  String get enterHotelNameLocation => 'أدخل اسم الفندق أو الموقع أو وسائل الراحة للعثور على إقامتك المثالية';

  @override
  String get searchFailed => 'فشل البحث';

  @override
  String get inputCantBeEmpty => 'لا يمكن أن يكون الإدخال فارغًا!';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get updateFirstName => 'تحديث الاسم الأول';

  @override
  String get updateLastName => 'تحديث اسم العائلة';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get updateYourInformation => 'تحديث معلوماتك';

  @override
  String get selectAWilaya => 'اختر ولاية';

  @override
  String get enter => 'أدخل';

  @override
  String get passwordUpdatedSuccessfully => 'تم تحديث كلمة المرور الخاصة بك بنجاح';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get pleaseEnterCurrentPassword => 'الرجاء إدخال كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get pleaseEnterNewPassword => 'الرجاء إدخال كلمة مرور جديدة';

  @override
  String get passwordMustBeAtLeast6Characters => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get wrongPassword => 'كلمة المرور الحالية غير صحيحة.';

  @override
  String get requiresRecentLogin => 'يرجى إعادة المصادقة لتحديث كلمة المرور الخاصة بك.';

  @override
  String get genericError => 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get failedToUpdatePassword => 'فشل تحديث كلمة المرور. يرجى المحاولة مرة أخرى.';

  @override
  String get passwordMismatch => 'عدم تطابق كلمة المرور';

  @override
  String get explore => 'استكشاف';

  @override
  String get favorites => 'المفضلة';

  @override
  String get profileSettings => 'إعدادات الملف الشخصي';

  @override
  String get imageUploadFailed => 'فشل تحميل الصورة';

  @override
  String get profileImageUpdatedSuccessfully => 'تم تحديث صورة الملف الشخصي بنجاح';

  @override
  String get failedToUploadImage => 'فشل تحميل الصورة';

  @override
  String get removeProfileImage => 'إزالة صورة الملف الشخصي';

  @override
  String get removeProfileImageConfirmation => 'هل أنت متأكد من أنك تريد إزالة صورة ملفك الشخصي؟';

  @override
  String get profileImageRemoved => 'تمت إزالة صورة الملف الشخصي';

  @override
  String get failedToRemoveImage => 'فشل إزالة الصورة';

  @override
  String get ok => 'موافق';

  @override
  String get uploading => 'جاري التحميل...';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get updateProfile => 'تحديث الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get wilayaNotFound => 'لم يتم العثور على الولاية';

  @override
  String get wilayaDataNotAvailable => 'بيانات الولاية غير متوفرة';

  @override
  String get failedToLoadImage => 'فشل تحميل الصورة';

  @override
  String noHotelsRegistered(Object wilayaName) {
    return 'لا توجد فنادق مسجلة حاليًا في $wilayaName';
  }

  @override
  String get pleaseWaitAMoment => 'الرجاء الانتظار لحظة';

  @override
  String get pressBackAgainToExit => 'اضغط على رجوع مرة أخرى للخروج';

  @override
  String get passwordReset => 'إعادة تعيين كلمة المرور';

  @override
  String get passwordResetSentMessage => 'لقد أرسلنا لك الآن رابط إعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordGenericError => 'لم نتمكن من معالجة طلبك. يرجى التأكد من أنك مستخدم مسجل، أو إذا لم تكن كذلك، فقم بتسجيل مستخدم الآن بالرجوع خطوة واحدة.';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordInstructions => 'أدخل عنوان بريدك الإلكتروني المسجل لتلقي رابط إعادة تعيين كلمة المرور';

  @override
  String get enterYourEmail => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get enterValidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get failedToLoadHotelDetails => 'فشل تحميل تفاصيل الفندق';

  @override
  String get noHotelInformationAvailable => 'لا تتوفر معلومات الفندق';

  @override
  String get room => 'الغرفة';

  @override
  String get noDescriptionAvailable => 'لا يوجد وصف متاح';

  @override
  String get noContactInformationAvailable => 'لا تتوفر معلومات الاتصال';

  @override
  String get ratingsAndReviews => 'التقييمات والمراجعات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noReviewsYet => 'لا توجد تقييمات حتى الآن';

  @override
  String get averageRating => 'متوسط التقييم';

  @override
  String get locationOnMap => 'الموقع على الخريطة';

  @override
  String get openInMaps => 'افتح في الخرائط';

  @override
  String get mapLocationNotAvailable => 'موقع الخريطة غير متوفر';

  @override
  String get roomOffers => 'عروض الغرف';

  @override
  String get viewRoomOffers => 'عرض عروض الغرف';

  @override
  String get selectAccountType => 'حدد نوع حسابك للبدء';

  @override
  String get traveler => 'مسافر';

  @override
  String get travelerSubtitle => 'اكتشف واحجز إقامات فاخرة في جميع أنحاء العالم';

  @override
  String get hotelPartner => 'شريك الفندق';

  @override
  String get hotelPartnerSubtitle => 'قائمة وإدارة العقارات الفاخرة الخاصة بك';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟ ';

  @override
  String get hotelInformationNotAvailable => 'معلومات الفندق غير متوفرة';

  @override
  String get roomAvailable => 'غرفة متاحة';

  @override
  String get premium => 'ممتاز';

  @override
  String get perPage => 'لكل صفحة';

  @override
  String get failedToLoadReviewerDetails => 'فشل تحميل تفاصيل المراجع';

  @override
  String get reviewedBy => 'تمت المراجعة بواسطة';

  @override
  String get noCommentProvided => 'لم يتم تقديم تعليق';

  @override
  String get addRoom => 'إضافة غرفة';

  @override
  String get roomMarkedAsUnavailable => 'تم وضع علامة على الغرفة كغير متاحة';

  @override
  String get roomMarkedAsAvailable => 'تم وضع علامة على الغرفة كمتاحة';

  @override
  String failedToUpdateRoom(Object error) {
    return 'فشل تحديث الغرفة: $error';
  }

  @override
  String get deleteRoom => 'حذف الغرفة';

  @override
  String get deleteRoomConfirmation => 'لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get roomDeletedSuccessfully => 'تم حذف الغرفة بنجاح';

  @override
  String failedToDeleteRoom(Object error) {
    return 'فشل حذف الغرفة: $error';
  }

  @override
  String get editRoom => 'تعديل الغرفة';

  @override
  String get addNewRoom => 'إضافة غرفة جديدة';

  @override
  String get roomName => 'اسم الغرفة';

  @override
  String get pricePerNight => 'السعر لكل ليلة';

  @override
  String get availableForBooking => 'متاح للحجز';

  @override
  String get roomPhotos => 'صور الغرفة';

  @override
  String get updateRoom => 'تحديث الغرفة';

  @override
  String get roomUpdatedSuccessfully => 'تم تحديث الغرفة بنجاح';

  @override
  String get roomAddedSuccessfully => 'تمت إضافة الغرفة بنجاح';

  @override
  String failedToAddRoom(Object error) {
    return 'فشل إضافة الغرفة: $error';
  }

  @override
  String failedToUpdateRoomGeneric(Object error) {
    return 'فشل تحديث الغرفة: $error';
  }

  @override
  String guest(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ضيوف',
      one: 'ضيف',
    );
    return '$_temp0';
  }

  @override
  String photoCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'صور',
      one: 'صورة',
    );
    return '$_temp0';
  }

  @override
  String get edit => 'تعديل';

  @override
  String get markUnavailable => 'وضع علامة كغير متاح';

  @override
  String get markAvailable => 'وضع علامة كمتاح';

  @override
  String get pricingAvailability => 'التسعير والتوافر';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get resetFiltersTitle => 'إعادة تعيين الفلاتر';

  @override
  String get resetFiltersContent => 'هل أنت متأكد من أنك تريد إعادة تعيين جميع الفلاتر؟';

  @override
  String get resetFiltersCancel => 'إلغاء';

  @override
  String get resetFiltersConfirm => 'إعادة تعيين';

  @override
  String get applyFilters => 'تطبيق الفلاتر';

  @override
  String get filterByMinGuests => 'الحد الأدنى للضيوف';

  @override
  String get filterByPriceRange => 'نطاق السعر';

  @override
  String get filterByCustomerRating => 'تقييم العملاء';

  @override
  String get filterByLocation => 'الموقع (ولاية)';

  @override
  String get allHotels => 'جميع الفنادق';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get selectDatesFirst => 'اختر التواريخ أولًا';

  @override
  String get refresh => 'تحديث';

  @override
  String get noItemsToDisplay => 'لا توجد عناصر لعرضها';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get noHotelsDescription => 'لم نتمكن من العثور على أي فنادق تطابق معاييرك';

  @override
  String get reset => 'إعادة الضبط';

  @override
  String get hello => 'مرحباً';

  @override
  String get findYourPerfectStay => 'ابحث عن إقامتك المثالية';

  @override
  String get discoverAmazingHotels => 'اكتشف فنادق مذهلة مصممة خصيصًا لك';

  @override
  String get startingFrom => 'تبدأ من';

  @override
  String get currencySymbol => 'د.ج';

  @override
  String get popularDestinations => 'الوجهات الشعبية';

  @override
  String get tryAdjustingFilters => 'حاول تعديل عوامل التصفية أو تحقق لاحقًا';

  @override
  String get exploreAll => 'استكشف الكل';

  @override
  String get resetFilters => 'إعادة تعيين الفلاتر';

  @override
  String get luxury => 'فاخر';

  @override
  String get hotelsFound => 'الفنادق الموجودة';

  @override
  String get facilities => 'مرافق';

  @override
  String get availability => 'التوفر';

  @override
  String get activityNewBooking => 'حجز جديد';

  @override
  String activityBookingDescription(Object firstName, Object lastName, Object roomName) {
    return 'قام $firstName $lastName بحجز $roomName';
  }

  @override
  String get activityNewReview => 'مراجعة جديدة';

  @override
  String activityReviewDescription(Object firstName, Object lastName, Object rating) {
    return 'ترك $firstName $lastName مراجعة بتقييم $rating نجوم';
  }

  @override
  String hotelsInWilaya(Object wilaya) {
    return 'فنادق في $wilaya';
  }

  @override
  String get currentlyAvailable => 'متاح حالياً';

  @override
  String get availableSoon => 'سيكون متاحاً قريباً';

  @override
  String get hotelsManagement => 'إدارة الفنادق';

  @override
  String get searchByHotelNameOrEmail => 'البحث بإسم الفندق أو البريد الإلكتروني';

  @override
  String get subscribed => 'مشترك';

  @override
  String get unsubscribed => 'غير مشترك';

  @override
  String get inactive => 'غير نشط';

  @override
  String get unknown => 'غير معروف';

  @override
  String get noHotelsInDatabase => 'لم يتم العثور على فنادق في قاعدة البيانات';

  @override
  String get noHotelsMatchFilters => 'لا توجد فنادق تطابق عوامل التصفية الحالية';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get subscribe => 'اشتراك';

  @override
  String get unsubscribe => 'إلغاء';

  @override
  String get errorLoadingHotels => 'خطأ في تحميل الفنادق';

  @override
  String get errorUpdatingSubscription => 'خطأ في تحديث حالة الاشتراك';

  @override
  String hotelNowSubscribed(String hotelName) {
    return '$hotelName مشترك الآن';
  }

  @override
  String hotelNowUnsubscribed(String hotelName) {
    return '$hotelName غير مشترك الآن';
  }

  @override
  String ratingValue(String rating, String count) {
    return '$rating ($count)';
  }

  @override
  String get adminsManagement => 'إدارة المشرفين';

  @override
  String get administratorAccounts => 'حسابات المشرفين';

  @override
  String get manageAdminAccounts => 'إدارة جميع حسابات المشرفين والصلاحيات';

  @override
  String get searchByName => 'البحث بالاسم...';

  @override
  String get noAdminAccounts => 'لا توجد حسابات مشرفين';

  @override
  String get noAdminsMatch => 'لا توجد نتائج مطابقة للبحث';

  @override
  String get createNewAdmin => 'إنشاء حساب مشرف جديد للبدء';

  @override
  String get adjustSearchCriteria => 'حاول تعديل معايير البحث';

  @override
  String get addAdmin => 'إضافة مشرف';

  @override
  String get name => 'الاسم';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get actions => 'الإجراءات';

  @override
  String get editAdmin => 'تعديل المشرف';

  @override
  String get deleteAdmin => 'حذف المشرف';

  @override
  String get totalAdmins => 'إجمالي المشرفين';

  @override
  String get filtered => 'مفلتر';

  @override
  String get ofWord => 'من';

  @override
  String get adminId => 'معرف المشرف';

  @override
  String get addNewAdmin => 'إضافة مشرف جديد';

  @override
  String get createNewAdminAccount => 'إنشاء حساب مشرف جديد';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get pleaseEnterName => 'الرجاء إدخال الاسم';

  @override
  String get pleaseEnterEmail => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get pleaseEnterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get passwordLengthError => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get passwordMustBeLong => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get creatingAdminAccount => 'جاري إنشاء حساب المشرف...';

  @override
  String get adminCreatedSuccessfully => 'تم إنشاء حساب المشرف بنجاح';

  @override
  String get updateAdminInfo => 'تحديث معلومات المشرف';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get deleteAdminAccount => 'حذف حساب المشرف';

  @override
  String get confirmDeleteAdmin => 'هل أنت متأكد أنك تريد حذف حساب المشرف هذا؟';

  @override
  String get createdOn => 'تم الإنشاء في';

  @override
  String get actionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get updatingAdminAccount => 'جاري تحديث حساب المشرف...';

  @override
  String get adminUpdatedSuccessfully => 'تم تحديث حساب المشرف بنجاح';

  @override
  String failedToLoadAdmins(Object error) {
    return 'فشل تحميل المشرفين: $error';
  }

  @override
  String get bookingsManagement => 'إدارة الحجوزات';

  @override
  String get totalBookings => 'إجمالي الحجوزات';

  @override
  String get totalEarnings => 'إجمالي الأرباح';

  @override
  String get filterByDate => 'تصفية حسب التاريخ';

  @override
  String get allTime => 'كل الأوقات';

  @override
  String get today => 'اليوم';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get customRange => 'نطاق مخصص';

  @override
  String get selectDateRange => 'اختر نطاق التاريخ';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get applyFilter => 'تطبيق التصفية';

  @override
  String get nightsWord => 'ليالي';

  @override
  String get bookedOn => 'تم الحجز في';

  @override
  String get commission => 'العمولة';

  @override
  String get unknownHotel => 'فندق غير معروف';

  @override
  String get unknownRoom => 'غرفة غير معروفة';

  @override
  String errorLoadingBookings(Object error) {
    return 'خطأ في تحميل الحجوزات: $error';
  }

  @override
  String get dismiss => 'تجاهل';

  @override
  String get startDateBeforeEndDate => 'يجب أن يكون تاريخ البدء قبل تاريخ الانتهاء';

  @override
  String get endDateAfterStartDate => 'يجب أن يكون تاريخ الانتهاء بعد تاريخ البدء';

  @override
  String get selectBothDates => 'الرجاء تحديد تاريخي البدء والانتهاء';

  @override
  String get loadingBookings => 'جاري تحميل الحجوزات...';

  @override
  String get admins => 'المسؤولين';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get wavingHand => '👋';

  @override
  String get subscriptionPending => 'اشتراكك لا يزال قيد الانتظار';

  @override
  String get subscriptionPendingMessage => 'لا يمكنك استخدام التطبيق حتى يتم تفعيل حسابك من قبل المسؤول. يرجى التحقق لاحقاً.';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get contact => 'الاتصال';

  @override
  String get reviewApplicationNote => 'سيقوم فريقنا بمراجعة طلبك قريباً';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String errorLoadingDashboard(Object error) {
    return 'خطأ في تحميل بيانات لوحة التحكم: $error';
  }

  @override
  String get performanceAnalytics => 'تحليل الأداء';

  @override
  String get earnings => 'الأرباح';

  @override
  String get dailyEarnings => 'الأرباح اليومية (دولار)';

  @override
  String get dailyBookings => 'عدد الحجوزات اليومية';

  @override
  String get topPerformingHotels => 'أفضل الفنادق أداءً';

  @override
  String get top5 => 'أفضل 5';

  @override
  String get dashboardOverview => 'نظرة عامة على لوحة التحكم';

  @override
  String get monitorPerformance => 'مراقبة أداء منصتك';

  @override
  String get activeHotels => 'الفنادق النشطة';

  @override
  String get totalVisitors => 'إجمالي الزوار';

  @override
  String get recentBookings => 'الحجوزات الحديثة';

  @override
  String get noBookingsAvailable => 'لا توجد حجوزات متاحة';

  @override
  String get booking => 'حجز';

  @override
  String get active => 'نشط';
}
