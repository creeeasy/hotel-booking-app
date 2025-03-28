import 'dart:ui';

import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:fatiel/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _emailController.clear();
            await showPasswordResetSentDialog(context);
          } else if (state.exception is InvalidEmailException) {
            await showErrorDialog(context, 'Invalid email');
          } else if (state.exception is UserNotFoundException) {
            await showErrorDialog(context, 'User Not found exception');
          } else if (state.exception is GenericException) {
            await showErrorDialog(
              context,
              'We could not process your request. Please make sure that you are a registered user, or if not, register a user now by going back one step.',
            );
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background with Parallax Effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
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
                        ThemeColors.primary.withOpacity(0.4),
                        ThemeColors.primaryDark.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Frosted Glass Content Panel
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Back Button and Title
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Iconsax.arrow_left,
                                  color: ThemeColors.textOnPrimary,
                                  size: 28,
                                ),
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(const AuthEventLogOut());
                                },
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: ThemeColors.textOnPrimary,
                                  letterSpacing: 0.8,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Instruction Text
                          Text(
                            'Enter your email address and we\'ll send you a link to reset your password',
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeColors.textOnPrimary.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Email Input Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: ThemeColors.textOnPrimary,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  icon: Icon(
                                    Iconsax.sms,
                                    color: ThemeColors.textOnPrimary
                                        .withOpacity(0.8),
                                  ),
                                  hintText: 'your@email.com',
                                  hintStyle: TextStyle(
                                    color: ThemeColors.textOnPrimary
                                        .withOpacity(0.6),
                                  ),
                                  border: InputBorder.none,
                                  labelText: 'Email Address',
                                  labelStyle: TextStyle(
                                    color: ThemeColors.textOnPrimary
                                        .withOpacity(0.8),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: ThemeColors.textOnPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Reset Password Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => context.read<AuthBloc>().add(
                                    AuthEventForgotPassword(
                                        email: _emailController.text),
                                  ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ThemeColors.primaryLight.withOpacity(0.9),
                                      ThemeColors.primary.withOpacity(0.9),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Back to Login
                          TextButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEventLogOut());
                            },
                            child: Text(
                              'Back to Login',
                              style: TextStyle(
                                color:
                                    ThemeColors.textOnPrimary.withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    ThemeColors.textOnPrimary.withOpacity(0.4),
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
    );
  }
}
