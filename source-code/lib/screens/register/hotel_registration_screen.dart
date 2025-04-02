import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
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
  bool _isLoading = false;

  void _togglePasswordVisibility() =>
      setState(() => _isPasswordVisible = !_isPasswordVisible);

  void _createHotelAccount() {
    final hotelName = _hotelNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (hotelName.isEmpty) {
      _showSnackBar(L10n.of(context).enterHotelName);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar(L10n.of(context).validEmail);
      return;
    }
    if (password.length < 6) {
      _showSnackBar(L10n.of(context).passwordLength);
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar(L10n.of(context).passwordMatch);
      return;
    }

    setState(() => _isLoading = true);
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
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: ThemeColors.error,
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateHotelRegistering) {
            setState(() => _isLoading = false);
            if (state.exception != null) {
              final errorMessage = _getErrorMessage(state.exception);
              if (errorMessage != null) {
                await showErrorDialog(context, errorMessage);
              }
            }
          }
        },
        child: Scaffold(
          backgroundColor: ThemeColors.background,
          appBar: CustomBackAppBar(
            title: L10n.of(context).hotelRegistration,
            onBack: () =>
                context.read<AuthBloc>().add(const AuthEventShouldRegister()),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.of(context).registerHotel,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.primaryDark,
                        letterSpacing: 0.8,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ThemeColors.secondaryLight,
                            ThemeColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildInputField(
                  controller: _hotelNameController,
                  icon: Iconsax.building,
                  label: L10n.of(context).hotelName,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _emailController,
                  icon: Iconsax.sms,
                  label: L10n.of(context).email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _passwordController,
                  label: L10n.of(context).password,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: L10n.of(context).confirmPassword,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createHotelAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.secondary,
                      foregroundColor: ThemeColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      shadowColor: ThemeColors.shadowDark,
                      disabledBackgroundColor:
                          ThemeColors.secondary.withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            L10n.of(context).registerHotelButton,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.secondary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: ThemeColors.secondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: ThemeColors.secondary.withOpacity(0.08),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: ThemeColors.secondary,
            ),
          ),
          filled: true,
          fillColor: ThemeColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: ThemeColors.secondary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
        cursorColor: ThemeColors.secondary,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.secondary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: ThemeColors.secondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: ThemeColors.secondary.withOpacity(0.08),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(
              Iconsax.lock_1,
              size: 20,
              color: ThemeColors.secondary,
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _isPasswordVisible ? Iconsax.eye_slash : Iconsax.eye,
                size: 20,
                color: ThemeColors.textSecondary.withOpacity(0.6),
              ),
            ),
          ),
          filled: true,
          fillColor: ThemeColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: ThemeColors.secondary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
        cursorColor: ThemeColors.secondary,
      ),
    );
  }

  String? _getErrorMessage(Exception? exception) {
    if (exception is WeakPasswordException) {
      return L10n.of(context).weakPassword;
    }
    if (exception is MissingPasswordException) {
      return L10n.of(context).missingPassword;
    }
    if (exception is EmailAlreadyInUseException) {
      return L10n.of(context).emailInUse;
    }
    if (exception is InvalidEmailException) {
      return L10n.of(context).invalidEmail;
    }
    if (exception is GenericException) return L10n.of(context).registerFailed;
    return null;
  }
}
