import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: ThemeColors.primaryDark,
      ),
    );
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
        backgroundColor: ThemeColors.background,
        body: Stack(
          children: [
            // Background with subtle gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ThemeColors.primary.withOpacity(0.05),
                      ThemeColors.primaryLight.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.arrow_left_2,
                            size: 28, color: ThemeColors.primaryDark),
                        onPressed: () => context
                            .read<AuthBloc>()
                            .add(const AuthEventShouldRegister()),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Hotel Registration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeColors.primaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form
                  Text(
                    'Register your hotel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in your hotel details to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    _hotelNameController,
                    'Hotel Name',
                    Iconsax.building,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    _emailController,
                    'Email',
                    Iconsax.sms,
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    _passwordController,
                    'Password',
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    _confirmPasswordController,
                    'Confirm Password',
                  ),
                  const SizedBox(height: 40),

                  // Register Button
                  Material(
                    borderRadius: BorderRadius.circular(16),
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _createHotelAccount,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              ThemeColors.secondary,
                              ThemeColors.primary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms and conditions
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: ThemeColors.textSecondary.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        children: [
                          const TextSpan(
                              text: 'By registering, you agree to our '),
                          TextSpan(
                            text: 'Terms',
                            style: TextStyle(
                              color: ThemeColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: ThemeColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: ThemeColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: ThemeColors.textSecondary.withOpacity(0.8),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: ThemeColors.primaryLight,
            size: 22,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeColors.primaryLight.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        cursorColor: ThemeColors.primary,
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
  ) {
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        style: TextStyle(
          color: ThemeColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: ThemeColors.textSecondary.withOpacity(0.8),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Iconsax.lock_1,
            color: ThemeColors.primaryLight,
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: _togglePasswordVisibility,
            icon: Icon(
              _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
              color: ThemeColors.primaryLight.withOpacity(0.6),
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeColors.primaryLight.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        cursorColor: ThemeColors.primary,
      ),
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
