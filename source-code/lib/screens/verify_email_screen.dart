import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.greyColor,
        appBar: AppBar(
          backgroundColor: ThemeColors.greyColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Verification Email',
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
          padding: const EdgeInsets.symmetric(
              horizontal: 24.0), // Adjusted padding for better layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'We\'ve sent you an email verification,\ncheck your email!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeColors
                      .blackColor, // Keeps the dark text for readability
                  fontSize: 18, // Slightly larger text for better visibility
                  fontWeight: FontWeight
                      .w600, // Use a semi-bold weight for more emphasis
                  letterSpacing:
                      1, // Adds spacing between letters for improved readability
                  height:
                      1.5, // Line height for better spacing between the two lines
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () =>
                    {context.read<AuthBloc>().add(const AuthEventLogOut())},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: ThemeColors.whiteColor,
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
