import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get welcomeBack => 'Welcome Back';

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
}
