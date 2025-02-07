import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';

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
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centers the content vertically
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'We\'ve sent an email to reset your password,\nplease check your inbox!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeColors
                              .blackColor, // Dark text for readability
                          fontSize:
                              18, // Slightly larger text for better visibility
                          fontWeight: FontWeight.w600, // Semi-bold for emphasis
                          letterSpacing:
                              1, // Adds spacing between letters for readability
                          height: 1.5, // Line height for spacing between lines
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          // context.read<auth_bloc>().add(const AuthEventLogOut());
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 14.0,
                                horizontal:
                                    28.0), // Slightly larger padding for better touch
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            ThemeColors.primaryColor, // Golden accent button
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // More rounded corners for a modern look
                            ),
                          ),
                        ),
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: ThemeColors
                                .whiteColor, // White text for contrast
                            fontSize:
                                16, // Slightly bigger text for better readability
                            fontWeight: FontWeight
                                .w500, // Medium weight for a balanced look
                            letterSpacing: 0.5, // Adds subtle letter spacing
                          ),
                        ),
                      ),
                    ],
                  )))),
    );
  }
}
