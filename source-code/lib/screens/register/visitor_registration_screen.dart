import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisitorRegistrationView extends StatefulWidget {
  const VisitorRegistrationView({super.key});

  @override
  State<StatefulWidget> createState() => _VisitorRegistrationViewState();
}

class _VisitorRegistrationViewState extends State<VisitorRegistrationView> {
  final TextEditingController id = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool notVisiblePassword = true;

  void passwordVisibility() {
    setState(() {
      notVisiblePassword = !notVisiblePassword;
    });
  }

  void createVisitorAccount() {
    // Implement registration logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.lightGrayColor,
      appBar: AppBar(
        leading: IconButton(
          color: ThemeColors.blackColor,
          icon: const Icon(
            Icons.chevron_left,
            size: 32, // Slightly increased for better visibility
          ),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventShouldRegister());
          },
        ),
        backgroundColor: ThemeColors.lightGrayColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Visitor Registration',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: ThemeColors.blackColor,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 24.0), // Adjusted padding for better layout
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create an account",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: ThemeColors.blackColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12), // Improved spacing
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email ID',
                icon: Icon(Icons.alternate_email_outlined,
                    color: ThemeColors.blackColor),
                labelStyle: TextStyle(
                  color: ThemeColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
              ),
              controller: id,
              cursorColor: ThemeColors.primaryColor,
            ),
            const SizedBox(height: 15),
            TextFormField(
              obscureText: notVisiblePassword,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock_outline_rounded,
                    color: ThemeColors.blackColor),
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: ThemeColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeColors.primaryColor),
                ),
                suffixIcon: IconButton(
                  onPressed: passwordVisibility,
                  icon: Icon(
                    notVisiblePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: ThemeColors.blackColor,
                  ),
                ),
              ),
              controller: password,
              cursorColor: ThemeColors.primaryColor,
            ),
            const SizedBox(height: 40), // Improved spacing for better structure
            ElevatedButton(
              onPressed: createVisitorAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primaryColor,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Sign Up",
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
    );
  }
}
