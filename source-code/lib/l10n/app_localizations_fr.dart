import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'Connexion';

  @override
  String get welcomeBack => 'Content de te revoir';

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
}
