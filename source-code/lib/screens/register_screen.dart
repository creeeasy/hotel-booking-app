// ignore_for_file: prefer_const_constructors

import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hotel.jpg', // Your background image path
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth, // Take full width
              height: screenHeight *
                  0.45, // Limit container height to 45% of screen height
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.0,
                    0.5
                  ], // Gradient stops adjusted for a smoother fade
                  colors: [
                    Colors.transparent, // Start transparent
                    Colors.white.withOpacity(0.7), // Soft white fade
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Ensure buttons are centered
                  children: [
                    // Client Button
                    SizedBox(
                      width: screenWidth *
                          0.7, // Buttons take 70% of the screen width
                      child: TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventVisitorRegister());
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              ThemeColors.clientButtonColor, // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Slightly rounded corners
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15), // Vertical padding
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 8,
                        ),
                        child: Text(
                          'Visitor',
                          style: TextStyle(
                            fontFamily: 'Poppins',

                            color: Colors.white,
                            fontWeight: FontWeight
                                .w600, // Bold font weight for emphasis
                            fontSize: 18, // Larger font size for readability
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Spacer between buttons
                    // Hotel Owner Button
                    SizedBox(
                      width: screenWidth *
                          0.7, // Buttons take 70% of the screen width
                      child: TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventHotelRegister());
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              ThemeColors.hotelButtonColor, // Button color
                          primary: Colors.white, // Text color
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Slightly rounded corners
                          ),
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 8,
                        ),
                        child: Text(
                          'Hotel',
                          style: TextStyle(
                            fontFamily: 'Poppins',

                            fontWeight: FontWeight
                                .w600, // Bold font weight for emphasis
                            fontSize: 18, // Larger font size for readability
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Spacer between buttons
                    // Already Have an Account? Login
                    // RichText for "Already have an account? Login"
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: ThemeColors
                              .blackColor.withOpacity(0.77), // Color for the normal text
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Already have an account? ', // Non-clickable part
                          ),
                          TextSpan(
                            text: 'Login', // Clickable part
                            style: TextStyle(
                              color: ThemeColors
                                  .blackColor, // Primary color for the clickable text
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthEventLogOut());
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
