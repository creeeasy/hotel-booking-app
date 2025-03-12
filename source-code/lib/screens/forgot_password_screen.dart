// ignore_for_file: prefer_const_constructors

import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:fatiel/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';

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

  void _resetPassword() {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email")),
      );
      return;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
            await showErrorDialog(context,
                'We could not process your request. Please make sure that you are a registered user, or if not, register a user now by going back one step.');
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ThemeColors.lightGrayColor,
          appBar: AppBar(
            leading: IconButton(
              color: ThemeColors.blackColor,
              icon: const Icon(
                Icons.chevron_left,
                size: 32, // Slightly increased for better visibility
              ),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
            ),
            backgroundColor: ThemeColors.lightGrayColor,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Forgot Password',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: ThemeColors.blackColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Spacing for other widgets
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Instruction text
                Text(
                  'Enter the email associated with your account, and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ThemeColors.blackColor,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),

                SizedBox(height: height * 0.05), // Space after instruction

                // Wrap email and button in a separate column
                Column(
                  children: [
                    // Email field
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.alternate_email_outlined,
                            color: ThemeColors.blackColor),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: ThemeColors.primaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: ThemeColors.primaryColor),
                        ),
                      ),
                      controller: _emailController,
                      cursorColor: ThemeColors.primaryColor,
                    ),

                    SizedBox(
                        height: height * 0.06), // Space after the input field

                    // Reset Password Button
                    ElevatedButton(
                      onPressed: () => context.read<AuthBloc>().add(
                          AuthEventForgotPassword(
                              email: _emailController.text)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primaryColor,
                        minimumSize: Size(width * 0.8, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0, // Removes shadow
                      ),
                      child: Text(
                        'Send reset link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ThemeColors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.04), // Space after the button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
