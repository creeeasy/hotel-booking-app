import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'Connexion';

  @override
  String get welcomeBackSimple => 'Content de vous revoir';

  @override
  String welcomeBack(Object hotelName) {
    return 'Content de vous revoir, $hotelName !';
  }

  @override
  String get signInToAccount => 'Connectez-vous pour accéder à votre compte';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get emailHint => 'votre@email.com';

  @override
  String get emailValidationError => 'Veuillez entrer votre e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordValidationError => 'Veuillez entrer votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get orDivider => 'OU';

  @override
  String get noAccountPrompt => 'Vous n\'avez pas de compte ? ';

  @override
  String get register => 'S\'inscrire';

  @override
  String get userNotFound => 'Utilisateur non trouvé';

  @override
  String get invalidEmail => 'E-mail invalide';

  @override
  String get missingPassword => 'Mot de passe manquant';

  @override
  String get wrongCredentials => 'Identifiants incorrects';

  @override
  String get authError => 'Erreur d\'authentification';

  @override
  String get bookings => 'Réservations';

  @override
  String get noHotelsFound => 'Aucun hôtel trouvé';

  @override
  String roomCapacity(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# invités',
      one: '# invité',
    );
    return '$_temp0';
  }

  @override
  String get completed => 'Terminé';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get filterRating => 'Note';

  @override
  String get filterPrice => 'Prix';

  @override
  String get filterMinPeople => 'Invités';

  @override
  String get filterLocation => 'Localisation';

  @override
  String get logoutTitle => 'Déconnexion';

  @override
  String get logoutContent => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(Object minutes) {
    return 'Il y a $minutes minutes';
  }

  @override
  String hoursAgo(Object hours) {
    return 'Il y a $hours heures';
  }

  @override
  String daysAgo(Object days) {
    return 'Il y a $days jours';
  }

  @override
  String get amenityWifi => 'WiFi';

  @override
  String get amenityPool => 'Piscine';

  @override
  String get amenityGym => 'Salle de sport';

  @override
  String get amenityRestaurant => 'Restaurant';

  @override
  String get amenitySpa => 'Spa';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityRoomService => 'Service en chambre';

  @override
  String get amenityPlayground => 'Aire de jeux';

  @override
  String get amenityBar => 'Bar';

  @override
  String get amenityConcierge => 'Conciergerie';

  @override
  String get amenityBusinessCenter => 'Centre d\'affaires';

  @override
  String get amenityLaundry => 'Blanchisserie';

  @override
  String get amenityAirportShuttle => 'Navette aéroport';

  @override
  String get amenityPetFriendly => 'Animaux acceptés';

  @override
  String get amenityAccessible => 'Accessible';

  @override
  String get amenitySmokeFree => 'Non-fumeur';

  @override
  String get amenityBeachAccess => 'Accès à la plage';

  @override
  String get amenityTv => 'TV';

  @override
  String get amenityAc => 'Climatisation';

  @override
  String get amenityHeating => 'Chauffage';

  @override
  String get amenitySafe => 'Coffre-fort';

  @override
  String get amenityKitchen => 'Cuisine';

  @override
  String get amenityMinibar => 'Minibar';

  @override
  String get amenityBathtub => 'Baignoire';

  @override
  String get amenityToiletries => 'Articles de toilette';

  @override
  String get noHotelsTitle => 'Aucun hôtel trouvé';

  @override
  String get noHotelsDefaultMessage => 'Nous n\'avons trouvé aucun hôtel correspondant à vos critères. Essayez d\'ajuster vos filtres de recherche ou explorez les lieux à proximité.';

  @override
  String get bookingsTitle => 'Réservations';

  @override
  String get bookingsNavTitle => 'Réservations';

  @override
  String get filterBookingsTitle => 'Filtrer les réservations';

  @override
  String get bookingDetailsTitle => 'Détails de la réservation';

  @override
  String get roomInformation => 'Informations sur la chambre';

  @override
  String get guestInformation => 'Informations sur l\'invité';

  @override
  String get bookingDates => 'Dates de réservation';

  @override
  String get paymentInformation => 'Informations de paiement';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get paymentStatus => 'Statut du paiement';

  @override
  String get paid => 'Payé';

  @override
  String get markCompleted => 'Marquer comme terminé';

  @override
  String get checkIn => 'Arrivée';

  @override
  String get checkOut => 'Départ';

  @override
  String perNight(Object price) {
    return '$price par nuit';
  }

  @override
  String get noBookingsFound => 'Aucune réservation trouvée';

  @override
  String get noBookingsDefault => 'Vous n\'avez pas encore de réservations';

  @override
  String noFilteredBookings(Object status) {
    return 'Aucune réservation $status trouvée';
  }

  @override
  String get failedToLoadBookings => 'Échec du chargement des réservations';

  @override
  String get retry => 'Réessayer';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryPending => 'En attente';

  @override
  String get summaryCompleted => 'Terminé';

  @override
  String get summaryRevenue => 'Revenu';

  @override
  String get complete => 'Terminer';

  @override
  String nights(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nuits',
      one: 'nuit',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSubtitle => 'Voici ce qui se passe aujourd\'hui';

  @override
  String get activeBookings => 'Réservations actives';

  @override
  String get roomsAvailable => 'Chambres disponibles';

  @override
  String get totalReviews => 'Total des avis';

  @override
  String get pendingBookings => 'Réservations en attente';

  @override
  String get quickAccess => 'Accès rapide';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get noRecentActivity => 'Aucune activité récente';

  @override
  String get roomsTitle => 'Chambres';

  @override
  String get roomsDescription => 'Gérer les détails des chambres';

  @override
  String get bookingsDescription => 'Voir toutes les réservations';

  @override
  String get reviewsTitle => 'Avis';

  @override
  String get reviewsDescription => 'Consulter les retours des clients';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDescription => 'Profil de l\'hôtel';

  @override
  String get validUrl => 'Saisissez une URL valide !';

  @override
  String get emptyInput => 'Le champ ne peut pas être vide !';

  @override
  String get updateLocation => 'Mettre à jour l\'emplacement';

  @override
  String get updateDescription => 'Mettre à jour la description';

  @override
  String get updateMapLink => 'Mettre à jour le lien de la carte';

  @override
  String get updateContactInfo => 'Mettre à jour les informations de contact';

  @override
  String get completeHotelProfile => 'Complétez votre profil d\'hôtel';

  @override
  String get selectWilaya => 'Sélectionnez une wilaya';

  @override
  String get back => 'Retour';

  @override
  String get finish => 'Terminer';

  @override
  String get next => 'Suivant';

  @override
  String get loadingPlaceholder => 'Chargement';

  @override
  String get inputEmpty => 'Le champ ne peut pas être vide !';

  @override
  String get updateContactInformation => 'Mettre à jour les informations de contact';

  @override
  String enterField(Object field) {
    return 'Entrez $field...';
  }

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get hotelPhotos => 'Photos de l\'hôtel';

  @override
  String get noPhotosAdded => 'Aucune photo ajoutée';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get basicInformation => 'Informations de base';

  @override
  String get hotelName => 'Nom de l\'hôtel';

  @override
  String get required => 'Requis';

  @override
  String get description => 'Description';

  @override
  String get contactInformation => 'Informations de contact';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get location => 'Emplacement';

  @override
  String get wilaya => 'Wilaya';

  @override
  String get mapLink => 'Lien de la carte';

  @override
  String get profileUpdatedSuccessfully => 'Vos données de profil ont été mises à jour avec succès.';

  @override
  String get errorUpdatingProfile => 'Erreur lors de la mise à jour du profil';

  @override
  String get imageUploadedSuccessfully => 'Image téléchargée avec succès';

  @override
  String errorUploadingImage(Object error) {
    return 'Erreur lors du téléchargement de l\'image : $error';
  }

  @override
  String get imageRemovedSuccessfully => 'Image supprimée avec succès';

  @override
  String errorRemovingImage(Object error) {
    return 'Erreur lors de la suppression de l\'image : $error';
  }

  @override
  String get guestReviews => 'Avis des clients';

  @override
  String get all => 'Tous';

  @override
  String stars(Object count) {
    return '$count étoiles';
  }

  @override
  String reviewsCount(Object count) {
    return '$count avis';
  }

  @override
  String get errorLoadingReviews => 'Erreur lors du chargement des avis';

  @override
  String get home => 'Accueil';

  @override
  String get rooms => 'chambres';

  @override
  String get reviews => 'avis';

  @override
  String get hotelRegistration => 'Enregistrement de l\'hôtel';

  @override
  String get registerHotel => 'Enregistrez votre hôtel';

  @override
  String get email => 'E-mail';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerHotelButton => 'Enregistrer l\'hôtel';

  @override
  String get enterHotelName => 'Veuillez entrer le nom de votre hôtel.';

  @override
  String get validEmail => 'Veuillez entrer une adresse e-mail valide.';

  @override
  String get passwordLength => 'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get passwordMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get weakPassword => 'Le mot de passe fourni est trop faible.';

  @override
  String get emailInUse => 'L\'e-mail est déjà utilisé';

  @override
  String get registerFailed => 'Échec de l\'enregistrement';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinFatiel => 'Rejoindre Fatiel';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get createAccountButton => 'Créer un compte';

  @override
  String get firstNameLastNameRequired => 'Veuillez entrer votre prénom et votre nom.';

  @override
  String get confirmBooking => 'Confirmer la réservation';

  @override
  String get checkInDate => 'Date d\'arrivée';

  @override
  String get checkOutDate => 'Date de départ';

  @override
  String get totalNights => 'Nombre total de nuits';

  @override
  String get totalPrice => 'Prix total';

  @override
  String get confirmAndPay => 'Confirmer et payer';

  @override
  String get selectCheckInDate => 'Sélectionner la date d\'arrivée';

  @override
  String get selectCheckOutDate => 'Sélectionner la date de départ';

  @override
  String get confirm => 'Confirmer';

  @override
  String get bookingConfirmed => 'Réservation confirmée avec succès !';

  @override
  String get from => 'À partir de';

  @override
  String get night => 'nuit';

  @override
  String get bookNow => 'Réserver maintenant';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get oopsSomethingWentWrong => 'Oups ! Quelque chose s\'est mal passé';

  @override
  String get goToHome => 'Retour à l\'accueil';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get removeHotelFromFavoritesConfirmation => 'Êtes-vous sûr de vouloir retirer cet hôtel de vos favoris ?';

  @override
  String get remove => 'Retirer';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get failedToUpdateFavorites => 'Échec de la mise à jour des favoris';

  @override
  String get removeFromFavoritesSemantic => 'Retirer des favoris';

  @override
  String get addToFavoritesSemantic => 'Ajouter aux favoris';

  @override
  String get imageNotAvailable => 'Image non disponible';

  @override
  String get locationNotSpecified => 'Emplacement non spécifié';

  @override
  String get noImageAvailable => 'Aucune image disponible';

  @override
  String get hotel => 'hôtel';

  @override
  String get hotels => 'hôtels';

  @override
  String get tryAdjustingSearchFilters => 'Essayez d\'ajuster vos filtres de recherche';

  @override
  String get noDataFound => 'Aucune donnée trouvée';

  @override
  String get noPopularDestinationsAvailable => 'Aucune destination populaire disponible pour le moment.';

  @override
  String get error => 'Erreur';

  @override
  String get guests => 'Invités';

  @override
  String get available => 'Disponible';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get allWilayas => 'Toutes les wilayas';

  @override
  String get failedToLoadWilayaData => 'Échec du chargement des données de la wilaya';

  @override
  String get noHotelsListedInAnyWilaya => 'Aucun hôtel actuellement listé dans aucune wilaya';

  @override
  String get discoveringAmazingPlaces => 'Découvrez des endroits incroyables pour vous';

  @override
  String get bookingSummary => 'Récapitulatif de la réservation';

  @override
  String get priceSummary => 'Récapitulatif des prix';

  @override
  String get roomRate => 'Tarif de la chambre';

  @override
  String get duration => 'Durée';

  @override
  String get roomDetails => 'Détails de la chambre';

  @override
  String get capacity => 'Capacité';

  @override
  String get exploreHotel => 'Explorer l\'hôtel';

  @override
  String get bookingError => 'Erreur de réservation';

  @override
  String get goBack => 'Retour';

  @override
  String get noBookingFound => 'Aucune réservation trouvée';

  @override
  String get noBookingDetails => 'Nous n\'avons trouvé aucun détail de réservation';

  @override
  String get myBookings => 'Mes réservations';

  @override
  String get failedToLoadBookingDetails => 'Échec du chargement des détails de la réservation';

  @override
  String get bookingDetailsNotAvailable => 'Détails de réservation non disponibles';

  @override
  String get unknownLocation => 'Emplacement inconnu';

  @override
  String get cancelled => 'Annulé';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get writeAReview => 'Écrire un avis';

  @override
  String get editReview => 'Modifier l\'avis';

  @override
  String get shareYourExperience => 'Partagez votre expérience...';

  @override
  String get pleaseWriteAComment => 'Veuillez écrire un commentaire';

  @override
  String get submit => 'Soumettre';

  @override
  String get update => 'Mettre à jour';

  @override
  String get deleteReview => 'Supprimer l\'avis';

  @override
  String get areYouSureDeleteReview => 'Êtes-vous sûr de vouloir supprimer cet avis ?';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancelBooking => 'Annuler la réservation';

  @override
  String get areYouSureCancelBooking => 'Êtes-vous sûr de vouloir annuler cette réservation ?';

  @override
  String get no => 'Non';

  @override
  String get yesCancel => 'Oui, annuler';

  @override
  String get exploreHotels => 'Explorer les hôtels';

  @override
  String get noPendingBookings => 'Aucune réservation en attente !';

  @override
  String get noCompletedBookings => 'Aucune réservation terminée !';

  @override
  String get noCancelledBookings => 'Aucune réservation annulée !';

  @override
  String get startYourJourney => 'Commencez votre voyage aujourd\'hui ! Trouvez les meilleurs hôtels\net réservez votre séjour de rêve en toute simplicité.';

  @override
  String get completedBookingsAppearHere => 'Vos réservations terminées apparaîtront ici.\nPartagez votre expérience en laissant des avis !';

  @override
  String get cancelledBookingsAppearHere => 'Vos réservations annulées apparaîtront ici.\nVous pouvez toujours réserver à nouveau !';

  @override
  String get pending => 'En attente';

  @override
  String get amenities => 'Équipements';

  @override
  String get recommended => 'Recommandé';

  @override
  String get nearMe => 'À proximité';

  @override
  String get recommendedHotels => 'Hôtels recommandés';

  @override
  String get hotelsNearYou => 'Hôtels près de chez vous';

  @override
  String get success => 'Succès';

  @override
  String get failedToLoadHotels => 'Échec du chargement des hôtels';

  @override
  String get noHotelsAvailable => 'Aucun hôtel disponible';

  @override
  String get noHotelsMatchingCriteria => 'Nous n\'avons trouvé aucun hôtel correspondant à vos critères.';

  @override
  String get findHotelsInCities => 'Trouver des hôtels dans les villes';

  @override
  String get failedToLoadCityData => 'Échec du chargement des données de la ville';

  @override
  String get noHotelsListedInCities => 'Aucun hôtel n\'est actuellement listé dans ces villes.';

  @override
  String get loadingYourFavorites => 'Chargement de vos favoris';

  @override
  String get couldntLoadFavorites => 'Impossible de charger les favoris';

  @override
  String get checkConnectionAndTryAgain => 'Veuillez vérifier votre connexion et réessayer';

  @override
  String get noFavoritesYet => 'Aucun favori pour le moment';

  @override
  String get saveFavoritesMessage => 'Enregistrez vos hôtels préférés en appuyant sur l\'icône cœur lors de la navigation';

  @override
  String get browseHotels => 'Parcourir les hôtels';

  @override
  String recommendedHotelsCount(Object count) {
    return 'Hôtels recommandés ($count)';
  }

  @override
  String hotelsNearYouCount(Object count) {
    return 'Hôtels près de chez vous ($count)';
  }

  @override
  String get weCouldntFindAnyHotels => 'Nous n\'avons trouvé aucun hôtel correspondant à vos critères.';

  @override
  String get noReviewsDataAvailable => 'Aucune donnée d\'avis disponible';

  @override
  String get guestFavorite => 'Préféré des clients';

  @override
  String basedOnReviews(Object totalRatings) {
    return 'Basé sur $totalRatings avis';
  }

  @override
  String starsCount(Object ratingCount) {
    return '$ratingCount étoiles';
  }

  @override
  String get exploreRoomOffers => 'Découvrir les offres de chambres';

  @override
  String get perNightSimple => 'Par nuit';

  @override
  String get roomType => 'Type de chambre';

  @override
  String get dates => 'Dates';

  @override
  String get successfullyBooked => 'Réservé avec succès';

  @override
  String get noAmenitiesListed => 'Aucun équipement listé';

  @override
  String get availableFrom => 'Disponible à partir du';

  @override
  String get notCurrentlyAvailable => 'Actuellement indisponible';

  @override
  String get failedToLoadRooms => 'Échec du chargement des chambres';

  @override
  String get noRoomsAvailable => 'Aucune chambre disponible';

  @override
  String get searchHotels => 'Rechercher des hôtels';

  @override
  String get searchHotelsLocations => 'Rechercher des hôtels, lieux...';

  @override
  String get searchForHotels => 'Rechercher des hôtels';

  @override
  String get enterHotelNameLocation => 'Entrez le nom de l\'hôtel, le lieu ou les équipements pour trouver votre séjour parfait';

  @override
  String get searchFailed => 'Échec de la recherche';

  @override
  String get inputCantBeEmpty => 'Le champ ne peut pas être vide !';

  @override
  String get anErrorOccurred => 'Une erreur est survenue';

  @override
  String get updateFirstName => 'Mettre à jour le prénom';

  @override
  String get updateLastName => 'Mettre à jour le nom';

  @override
  String get selectLocation => 'Sélectionner l\'emplacement';

  @override
  String get updateYourInformation => 'Mettre à jour vos informations';

  @override
  String get selectAWilaya => 'Sélectionner une wilaya';

  @override
  String get enter => 'Entrer';

  @override
  String get passwordUpdatedSuccessfully => 'Votre mot de passe a été mis à jour avec succès';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get pleaseEnterCurrentPassword => 'Veuillez entrer votre mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get pleaseEnterNewPassword => 'Veuillez entrer un nouveau mot de passe';

  @override
  String get passwordMustBeAtLeast6Characters => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get wrongPassword => 'Votre mot de passe actuel est incorrect.';

  @override
  String get requiresRecentLogin => 'Veuillez vous réauthentifier pour mettre à jour votre mot de passe.';

  @override
  String get genericError => 'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get failedToUpdatePassword => 'Échec de la mise à jour du mot de passe. Veuillez réessayer.';

  @override
  String get passwordMismatch => 'Incompatibilité des mots de passe';

  @override
  String get explore => 'Explorer';

  @override
  String get favorites => 'Favoris';

  @override
  String get profileSettings => 'Paramètres du profil';

  @override
  String get imageUploadFailed => 'Échec du téléchargement de l\'image';

  @override
  String get profileImageUpdatedSuccessfully => 'Image de profil mise à jour avec succès';

  @override
  String get failedToUploadImage => 'Échec du téléchargement de l\'image';

  @override
  String get removeProfileImage => 'Supprimer l\'image de profil';

  @override
  String get removeProfileImageConfirmation => 'Êtes-vous sûr de vouloir supprimer votre image de profil ?';

  @override
  String get profileImageRemoved => 'Image de profil supprimée';

  @override
  String get failedToRemoveImage => 'Échec de la suppression de l\'image';

  @override
  String get ok => 'OK';

  @override
  String get uploading => 'Téléchargement en cours...';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get wilayaNotFound => 'Wilaya non trouvée';

  @override
  String get wilayaDataNotAvailable => 'Données de wilaya non disponibles';

  @override
  String get failedToLoadImage => 'Échec du chargement de l\'image';

  @override
  String noHotelsRegistered(Object wilayaName) {
    return 'Aucun hôtel n\'est actuellement enregistré dans $wilayaName';
  }

  @override
  String get pleaseWaitAMoment => 'Veuillez patienter un moment';

  @override
  String get pressBackAgainToExit => 'Appuyez à nouveau sur retour pour quitter';

  @override
  String get passwordReset => 'Réinitialisation du mot de passe';

  @override
  String get passwordResetSentMessage => 'Nous vous avons envoyé un lien de réinitialisation de mot de passe.';

  @override
  String get forgotPasswordGenericError => 'Nous n\'avons pas pu traiter votre demande. Veuillez vous assurer que vous êtes un utilisateur enregistré, ou sinon, inscrivez-vous maintenant en revenant d\'une étape.';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordInstructions => 'Entrez votre adresse e-mail enregistrée pour recevoir un lien de réinitialisation de mot de passe';

  @override
  String get enterYourEmail => 'Veuillez entrer votre e-mail';

  @override
  String get enterValidEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get failedToLoadHotelDetails => 'Échec du chargement des détails de l\'hôtel';

  @override
  String get noHotelInformationAvailable => 'Aucune information sur l\'hôtel disponible';

  @override
  String get room => 'Chambre';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible';

  @override
  String get noContactInformationAvailable => 'Aucune information de contact disponible';

  @override
  String get ratingsAndReviews => 'Notes et avis';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get noReviewsYet => 'Aucun avis pour le moment';

  @override
  String get averageRating => 'Note moyenne';

  @override
  String get locationOnMap => 'Emplacement sur la carte';

  @override
  String get openInMaps => 'Ouvrir dans les cartes';

  @override
  String get mapLocationNotAvailable => 'Emplacement sur carte non disponible';

  @override
  String get roomOffers => 'Offres de chambres';

  @override
  String get viewRoomOffers => 'Voir les offres de chambres';

  @override
  String get selectAccountType => 'Sélectionnez votre type de compte pour commencer';

  @override
  String get traveler => 'Voyageur';

  @override
  String get travelerSubtitle => 'Découvrez et réservez des séjours de luxe dans le monde entier';

  @override
  String get hotelPartner => 'Partenaire hôtelier';

  @override
  String get hotelPartnerSubtitle => 'Listez et gérez vos propriétés de luxe';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get hotelInformationNotAvailable => 'Informations sur l\'hôtel non disponibles';

  @override
  String get roomAvailable => 'chambre disponible';

  @override
  String get premium => 'PREMIUM';

  @override
  String get perPage => 'par page';

  @override
  String get failedToLoadReviewerDetails => 'Échec du chargement des détails du critique';

  @override
  String get reviewedBy => 'Critiqué par';

  @override
  String get noCommentProvided => 'Aucun commentaire fourni';

  @override
  String get addRoom => 'Ajouter une chambre';

  @override
  String get roomMarkedAsUnavailable => 'Chambre marquée comme indisponible';

  @override
  String get roomMarkedAsAvailable => 'Chambre marquée comme disponible';

  @override
  String failedToUpdateRoom(Object error) {
    return 'Échec de la mise à jour de la chambre : $error';
  }

  @override
  String get deleteRoom => 'Supprimer la chambre';

  @override
  String get deleteRoomConfirmation => 'Cette action est irréversible. Êtes-vous sûr ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get roomDeletedSuccessfully => 'Chambre supprimée avec succès';

  @override
  String failedToDeleteRoom(Object error) {
    return 'Échec de la suppression de la chambre : $error';
  }

  @override
  String get editRoom => 'Modifier la chambre';

  @override
  String get addNewRoom => 'Ajouter une nouvelle chambre';

  @override
  String get roomName => 'Nom de la chambre';

  @override
  String get pricePerNight => 'Prix par nuit';

  @override
  String get availableForBooking => 'Disponible pour la réservation';

  @override
  String get roomPhotos => 'Photos de la chambre';

  @override
  String get updateRoom => 'Mettre à jour la chambre';

  @override
  String get roomUpdatedSuccessfully => 'Chambre mise à jour avec succès';

  @override
  String get roomAddedSuccessfully => 'Chambre ajoutée avec succès';

  @override
  String failedToAddRoom(Object error) {
    return 'Échec de l\'ajout de la chambre : $error';
  }

  @override
  String failedToUpdateRoomGeneric(Object error) {
    return 'Échec de la mise à jour de la chambre : $error';
  }

  @override
  String guest(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'invités',
      one: 'invité',
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
  String get edit => 'Modifier';

  @override
  String get markUnavailable => 'Marquer comme indisponible';

  @override
  String get markAvailable => 'Marquer comme disponible';

  @override
  String get pricingAvailability => 'Tarification et disponibilité';

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get resetFiltersTitle => 'Réinitialiser les filtres';

  @override
  String get resetFiltersContent => 'Êtes-vous sûr de vouloir réinitialiser tous les filtres ?';

  @override
  String get resetFiltersCancel => 'Annuler';

  @override
  String get resetFiltersConfirm => 'Réinitialiser';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get filterByMinGuests => 'Nombre minimum d\'invités';

  @override
  String get filterByPriceRange => 'Fourchette de prix';

  @override
  String get filterByCustomerRating => 'Note des clients';

  @override
  String get filterByLocation => 'Localisation (Wilaya)';

  @override
  String get allHotels => 'Tous les Hôtels';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get selectDatesFirst => 'Sélectionnez d\'abord les dates';

  @override
  String get refresh => 'Actualiser';

  @override
  String get noItemsToDisplay => 'Aucun élément à afficher';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get noHotelsDescription => 'Nous n\'avons trouvé aucun hôtel correspondant à vos critères';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get hello => 'Bonjour';

  @override
  String get findYourPerfectStay => 'Trouvez votre séjour parfait';

  @override
  String get discoverAmazingHotels => 'Découvrez des hôtels incroyables faits pour vous';

  @override
  String get startingFrom => 'À partir de';

  @override
  String get currencySymbol => 'DZD';

  @override
  String get popularDestinations => 'Destinations populaires';

  @override
  String get tryAdjustingFilters => 'Essayez d\'ajuster vos filtres ou revenez plus tard';

  @override
  String get exploreAll => 'Tout explorer';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get luxury => 'Luxe';

  @override
  String get hotelsFound => 'Hôtels trouvés';

  @override
  String get facilities => 'Équipements';

  @override
  String get availability => 'Disponibilité';

  @override
  String get activityNewBooking => 'Nouvelle réservation';

  @override
  String activityBookingDescription(Object firstName, Object lastName, Object roomName) {
    return '$firstName $lastName a réservé $roomName';
  }

  @override
  String get activityNewReview => 'Nouvel avis';

  @override
  String activityReviewDescription(Object firstName, Object lastName, Object rating) {
    return '$firstName $lastName a laissé un avis $rating étoiles';
  }

  @override
  String hotelsInWilaya(Object wilaya) {
    return 'Hôtels à $wilaya';
  }

  @override
  String get currentlyAvailable => 'Actuellement disponible';

  @override
  String get availableSoon => 'Bientôt disponible';

  @override
  String get hotelsManagement => 'Gestion des Hôtels';

  @override
  String get searchByHotelNameOrEmail => 'Rechercher par nom d\'hôtel ou e-mail';

  @override
  String get subscribed => 'Abonnés';

  @override
  String get unsubscribed => 'Non Abonnés';

  @override
  String get inactive => 'Inactif';

  @override
  String get unknown => 'Inconnu';

  @override
  String get noHotelsInDatabase => 'Aucun hôtel trouvé dans la base de données';

  @override
  String get noHotelsMatchFilters => 'Aucun hôtel ne correspond à vos filtres actuels';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get subscribe => 'Abon';

  @override
  String get unsubscribe => 'Désab';

  @override
  String get errorLoadingHotels => 'Erreur lors du chargement des hôtels';

  @override
  String get errorUpdatingSubscription => 'Erreur lors de la mise à jour du statut d\'abonnement';

  @override
  String hotelNowSubscribed(String hotelName) {
    return '$hotelName est maintenant abonné';
  }

  @override
  String hotelNowUnsubscribed(String hotelName) {
    return '$hotelName est maintenant désabonné';
  }

  @override
  String ratingValue(String rating, String count) {
    return '$rating ($count)';
  }

  @override
  String get adminsManagement => 'Gestion des administrateurs';

  @override
  String get administratorAccounts => 'Comptes administrateurs';

  @override
  String get manageAdminAccounts => 'Gérer tous les comptes administrateurs et permissions';

  @override
  String get searchByName => 'Rechercher par nom...';

  @override
  String get noAdminAccounts => 'Aucun compte administrateur trouvé';

  @override
  String get noAdminsMatch => 'Aucun administrateur ne correspond à votre recherche';

  @override
  String get createNewAdmin => 'Créez un nouveau compte administrateur pour commencer';

  @override
  String get adjustSearchCriteria => 'Essayez d\'ajuster vos critères de recherche';

  @override
  String get addAdmin => 'Ajouter un administrateur';

  @override
  String get name => 'Nom';

  @override
  String get createdAt => 'Créé le';

  @override
  String get actions => 'Actions';

  @override
  String get editAdmin => 'Modifier l\'administrateur';

  @override
  String get deleteAdmin => 'Supprimer l\'administrateur';

  @override
  String get totalAdmins => 'Total administrateurs';

  @override
  String get filtered => 'Filtré';

  @override
  String get ofWord => 'sur';

  @override
  String get adminId => 'ID administrateur';

  @override
  String get addNewAdmin => 'Ajouter un nouvel administrateur';

  @override
  String get createNewAdminAccount => 'Créer un nouveau compte administrateur';

  @override
  String get fullName => 'Nom complet';

  @override
  String get pleaseEnterName => 'Veuillez entrer un nom';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer un e-mail';

  @override
  String get pleaseEnterValidEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer un mot de passe';

  @override
  String get passwordLengthError => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordMustBeLong => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get creatingAdminAccount => 'Création du compte administrateur...';

  @override
  String get adminCreatedSuccessfully => 'Compte administrateur créé avec succès';

  @override
  String get updateAdminInfo => 'Mettre à jour les informations de l\'administrateur';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get deleteAdminAccount => 'Supprimer le compte administrateur';

  @override
  String get confirmDeleteAdmin => 'Êtes-vous sûr de vouloir supprimer ce compte administrateur ?';

  @override
  String get createdOn => 'Créé le';

  @override
  String get actionCannotBeUndone => 'Cette action ne peut pas être annulée.';

  @override
  String get updatingAdminAccount => 'Mise à jour du compte administrateur...';

  @override
  String get adminUpdatedSuccessfully => 'Compte administrateur mis à jour avec succès';

  @override
  String failedToLoadAdmins(Object error) {
    return 'Échec du chargement des administrateurs : $error';
  }

  @override
  String get bookingsManagement => 'Gestion des réservations';

  @override
  String get totalBookings => 'Réservations totales';

  @override
  String get totalEarnings => 'Gains totaux';

  @override
  String get filterByDate => 'Filtrer par date';

  @override
  String get allTime => 'Toutes les dates';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get last7Days => '7 derniers jours';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get lastMonth => 'Le mois dernier';

  @override
  String get customRange => 'Plage personnalisée';

  @override
  String get selectDateRange => 'Sélectionner une plage de dates';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get applyFilter => 'Appliquer le filtre';

  @override
  String get nightsWord => 'nuits';

  @override
  String get bookedOn => 'Réservé le';

  @override
  String get commission => 'Commission';

  @override
  String get unknownHotel => 'Hôtel inconnu';

  @override
  String get unknownRoom => 'Chambre inconnue';

  @override
  String errorLoadingBookings(Object error) {
    return 'Erreur de chargement des réservations : $error';
  }

  @override
  String get dismiss => 'Ignorer';

  @override
  String get startDateBeforeEndDate => 'La date de début doit être avant la date de fin';

  @override
  String get endDateAfterStartDate => 'La date de fin doit être après la date de début';

  @override
  String get selectBothDates => 'Veuillez sélectionner les dates de début et de fin';

  @override
  String get loadingBookings => 'Chargement des réservations...';

  @override
  String get admins => 'Admins';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get wavingHand => '👋';

  @override
  String get subscriptionPending => 'Votre abonnement est toujours en attente';

  @override
  String get subscriptionPendingMessage => 'Vous ne pouvez pas utiliser l\'application tant que votre compte n\'est pas activé par l\'administrateur. Veuillez vérifier plus tard.';

  @override
  String get accountInformation => 'Informations du compte';

  @override
  String get contact => 'Contact';

  @override
  String get reviewApplicationNote => 'Notre équipe examinera votre demande sous peu';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String errorLoadingDashboard(Object error) {
    return 'Erreur lors du chargement des données du tableau de bord : $error';
  }

  @override
  String get performanceAnalytics => 'Analyse de performance';

  @override
  String get earnings => 'Gains';

  @override
  String get dailyEarnings => 'Gains quotidiens (USD)';

  @override
  String get dailyBookings => 'Nombre de réservations quotidiennes';

  @override
  String get topPerformingHotels => 'Hôtels les plus performants';

  @override
  String get top5 => 'Top 5';

  @override
  String get dashboardOverview => 'Aperçu du tableau de bord';

  @override
  String get monitorPerformance => 'Surveillez les performances de votre plateforme';

  @override
  String get activeHotels => 'Hôtels actifs';

  @override
  String get totalVisitors => 'Visiteurs totaux';

  @override
  String get recentBookings => 'Réservations récentes';

  @override
  String get noBookingsAvailable => 'Aucune réservation disponible';

  @override
  String get booking => 'Réservation';

  @override
  String get active => 'Actif';
}
