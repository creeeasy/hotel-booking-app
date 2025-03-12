import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelRegistrationView extends StatefulWidget {
  const HotelRegistrationView({super.key});

  @override
  State<StatefulWidget> createState() => _HotelRegistrationViewState();
}

class _HotelRegistrationViewState extends State<HotelRegistrationView> {
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool notVisiblePassword = true;

  void passwordVisibility() {
    setState(() {
      notVisiblePassword = !notVisiblePassword;
    });
  }

  void createHotelAccount() {
    if (_hotelNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthEventHotelRegistering(
            _hotelNameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateHotelRegistering) {
          if (state.exception is WeakPasswordException) {
            await showErrorDialog(context, 'Weak password');
          } else if (state.exception is MissingPasswordException) {
            await showErrorDialog(context, 'Missing password');
          } else if (state.exception is EmailAlreadyInUseException) {
            await showErrorDialog(context, 'Email is already in use');
          } else if (state.exception is GenericException) {
            await showErrorDialog(context, 'Failed to register');
          } else if (state.exception is InvalidEmailException) {
            await showErrorDialog(context, 'Invalid email');
          }
        }
      },
      child: Scaffold(
        backgroundColor: ThemeColors.lightGrayColor,
        appBar: AppBar(
          leading: IconButton(
            color: ThemeColors.blackColor,
            icon: const Icon(
              Icons.chevron_left,
              size: 32, // Matching Visitor screen
            ),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventShouldRegister());
            },
          ),
          backgroundColor: ThemeColors.lightGrayColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Hotel Registration',
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: ThemeColors.blackColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 24.0), // Consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Register your hotel",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.blackColor,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12), // Consistent spacing
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Hotel Name',
                  icon: Icon(Icons.business, color: ThemeColors.blackColor),
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
                controller: _hotelNameController,
                cursorColor: ThemeColors.primaryColor,
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
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
                controller: _emailController,
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
                controller: _passwordController,
                cursorColor: ThemeColors.primaryColor,
              ),
              const SizedBox(height: 40), // Matched spacing
              ElevatedButton(
                onPressed: createHotelAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primaryColor,
                  minimumSize: const Size.fromHeight(50), // Matched button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Next Step",
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
