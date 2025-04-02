import 'dart:ui';

import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  Future<void> showPasswordResetSentDialog(BuildContext context) {
    return showGenericDialog(
        context: context,
        title: L10n.of(context).passwordReset,
        content: L10n.of(context).passwordResetSentMessage,
        optionBuilder: () => {
              L10n.of(context).ok: null,
            });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateForgotPassword) {
            setState(() => _isLoading = false);
            if (state.hasSentEmail) {
              _emailController.clear();
              await showPasswordResetSentDialog(context);
            } else if (state.exception is InvalidEmailException) {
              await showErrorDialog(context, L10n.of(context).invalidEmail);
            } else if (state.exception is UserNotFoundException) {
              await showErrorDialog(context, L10n.of(context).userNotFound);
            } else if (state.exception is GenericException) {
              await showErrorDialog(
                context,
                L10n.of(context).forgotPasswordGenericError,
              );
            }
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // Enhanced Background with Parallax Effect
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/hotel.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ThemeColors.primary.withOpacity(0.5),
                          ThemeColors.primaryDark.withOpacity(0.9),
                        ],
                        stops: const [0.2, 0.8],
                      ),
                    ),
                  ),
                ),
              ),

              // Frosted Glass Content Panel with improved styling
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button with better spacing
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Iconsax.arrow_left_2,
                                  color: ThemeColors.textOnPrimary,
                                  size: 24,
                                ),
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(const AuthEventLogOut());
                                },
                                splashRadius: 24,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title with improved typography
                            Text(
                              L10n.of(context).resetPassword,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: ThemeColors.textOnPrimary,
                                letterSpacing: 0.5,
                                fontFamily: 'Poppins',
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Instruction Text with better readability
                            Text(
                              L10n.of(context).forgotPasswordInstructions,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color:
                                    ThemeColors.textOnPrimary.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Email Input Field with enhanced styling
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                style: const TextStyle(
                                  color: ThemeColors.textOnPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 18),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Iconsax.sms,
                                      color: ThemeColors.textOnPrimary
                                          .withOpacity(0.8),
                                      size: 22,
                                    ),
                                  ),
                                  hintText: 'your@email.com',
                                  hintStyle: TextStyle(
                                    color: ThemeColors.textOnPrimary
                                        .withOpacity(0.6),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  labelText: L10n.of(context).emailAddress,
                                  labelStyle: TextStyle(
                                    color: ThemeColors.textOnPrimary
                                        .withOpacity(0.8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: ThemeColors.textOnPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: ThemeColors.textOnPrimary,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return L10n.of(context).enterYourEmail;
                                  }
                                  if (!_isValidEmail(value)) {
                                    return L10n.of(context).enterValidEmail;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Reset Password Button with improved feedback
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_isValidEmail(
                                            _emailController.text)) {
                                          setState(() => _isLoading = true);
                                          context.read<AuthBloc>().add(
                                                AuthEventForgotPassword(
                                                    email:
                                                        _emailController.text),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: ThemeColors.textOnPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  disabledBackgroundColor:
                                      ThemeColors.primary.withOpacity(0.5),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ThemeColors.primaryLight
                                            .withOpacity(0.9),
                                        ThemeColors.primary.withOpacity(0.9),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Iconsax.send_2,
                                                  size: 20),
                                              const SizedBox(width: 12),
                                              Text(
                                                L10n.of(context).sendResetLink,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Back to Login with better alignment
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(const AuthEventLogOut());
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  L10n.of(context).backToLogin,
                                  style: TextStyle(
                                    color: ThemeColors.textOnPrimary
                                        .withOpacity(0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: ThemeColors.textOnPrimary
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
