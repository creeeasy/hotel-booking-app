import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPassowrdView extends StatefulWidget {
  const ResetPassowrdView({super.key});

  @override
  State<StatefulWidget> createState() => _RESETpassword();
}

class _RESETpassword extends State<ResetPassowrdView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: ThemeColors.greyColor, // Light background
          appBar: AppBar(
            backgroundColor:
                ThemeColors.greyColor, // AppBar matches the background
            elevation:
                0, // Optional: Remove shadow for a clean light theme look
            centerTitle: true,
            title: const Text(
              'Reset Password',
              style: TextStyle(
                color: ThemeColors.blackColor,
                fontSize: 22,
                fontFamily: 'Poppins',
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
                    'We\'ve sent an email to reset your password,\nplease check your inbox!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          ThemeColors.blackColor, // Dark text for readability
                      fontSize:
                          18, // Slightly larger text for better visibility
                      fontWeight: FontWeight.w600, // Semi-bold for emphasis
                      letterSpacing:
                          1, // Adds spacing between letters for readability
                      height: 1.5, // Line height for spacing between lines
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(const AuthEventLogOut()),
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
              ))),
    );
  }
}
