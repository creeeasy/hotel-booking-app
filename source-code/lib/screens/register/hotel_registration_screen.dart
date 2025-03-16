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
  final _hotelNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() =>
      setState(() => _isPasswordVisible = !_isPasswordVisible);

  void _createHotelAccount() {
    final hotelName = _hotelNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (hotelName.isEmpty) {
      _showSnackBar("Please enter your hotel's name.");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Please enter a valid email address.");
      return;
    }
    if (password.length < 6) {
      _showSnackBar("Password must be at least 6 characters long.");
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match.");
      return;
    }

    context
        .read<AuthBloc>()
        .add(AuthEventHotelRegistering(hotelName, email, password));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateHotelRegistering) {
          if (state.exception != null) {
            final errorMessage = _getErrorMessage(state.exception);
            if (errorMessage != null)
              await showErrorDialog(context, errorMessage);
          }
        }
      },
      child: Scaffold(
        backgroundColor: ThemeColors.lightGrayColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left,
                size: 32, color: ThemeColors.blackColor),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthEventShouldRegister()),
          ),
          backgroundColor: ThemeColors.lightGrayColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Hotel Registration',
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: ThemeColors.blackColor,
                letterSpacing: 0.3),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Register your hotel",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.blackColor)),
              const SizedBox(height: 12),
              _buildTextField(
                  _hotelNameController, 'Hotel Name', Icons.business),
              const SizedBox(height: 15),
              _buildTextField(
                  _emailController, 'Email', Icons.alternate_email_outlined),
              const SizedBox(height: 15),
              _buildPasswordField(_passwordController),
              const SizedBox(height: 15),
              _buildPasswordField(_confirmPasswordController),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _createHotelAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text("Next Step",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.whiteColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        icon: Icon(icon, color: ThemeColors.blackColor),
        labelStyle: const TextStyle(
            color: ThemeColors.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: ThemeColors.primaryColor)),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: ThemeColors.primaryColor)),
      ),
      cursorColor: ThemeColors.primaryColor,
    );
  }

  TextFormField _buildPasswordField(TextEditingController _passController) {
    return TextFormField(
      controller: _passController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        icon: const Icon(Icons.lock_outline_rounded,
            color: ThemeColors.blackColor),
        labelText: 'Password',
        labelStyle: const TextStyle(
            color: ThemeColors.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: ThemeColors.primaryColor)),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: ThemeColors.primaryColor)),
        suffixIcon: IconButton(
          onPressed: _togglePasswordVisibility,
          icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: ThemeColors.blackColor),
        ),
      ),
      cursorColor: ThemeColors.primaryColor,
    );
  }

  String? _getErrorMessage(Exception? exception) {
    if (exception is WeakPasswordException) return 'Weak password';
    if (exception is MissingPasswordException) return 'Missing password';
    if (exception is EmailAlreadyInUseException)
      return 'Email is already in use';
    if (exception is InvalidEmailException) return 'Invalid email';
    if (exception is GenericException) return 'Failed to register';
    return null;
  }
}
