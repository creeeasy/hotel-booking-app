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

class VisitorRegistrationView extends StatefulWidget {
  const VisitorRegistrationView({super.key});

  @override
  State<StatefulWidget> createState() => _VisitorRegistrationViewState();
}

class _VisitorRegistrationViewState extends State<VisitorRegistrationView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool notVisiblePassword = true;
  bool notVisibleConfirmPassword = true;
  bool _isLoading = false;

  void passwordVisibility() {
    setState(() {
      notVisiblePassword = !notVisiblePassword;
    });
  }

  void confirmPasswordVisibility() {
    setState(() {
      notVisibleConfirmPassword = !notVisibleConfirmPassword;
    });
  }

  void createVisitorAccount() {
    final fname = _firstNameController.text.trim();
    final lname = _lastNameController.text.trim();
    final mail = _emailController.text.trim();
    final pwd = _passwordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();

    if (fname.isEmpty || lname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context).firstNameLastNameRequired),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: ThemeColors.error,
          elevation: 4,
        ),
      );
      return;
    }

    if (mail.isEmpty || !mail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context).validEmail),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: ThemeColors.error,
          elevation: 4,
        ),
      );
      return;
    }

    if (pwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context).passwordLength),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: ThemeColors.error,
          elevation: 4,
        ),
      );
      return;
    }

    if (pwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context).passwordMatch),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: ThemeColors.error,
          elevation: 4,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(AuthEventVisitorRegistering(
          fname,
          lname,
          mail,
          pwd,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateVisitorRegistering) {
            setState(() => _isLoading = false);
            if (state.exception is WeakPasswordException) {
              await showErrorDialog(context, L10n.of(context).weakPassword);
            } else if (state.exception is MissingPasswordException) {
              await showErrorDialog(context, L10n.of(context).missingPassword);
            } else if (state.exception is EmailAlreadyInUseException) {
              await showErrorDialog(context, L10n.of(context).emailInUse);
            } else if (state.exception is GenericException) {
              await showErrorDialog(context, L10n.of(context).registerFailed);
            } else if (state.exception is InvalidEmailException) {
              await showErrorDialog(context, L10n.of(context).invalidEmail);
            }
          }
        },
        child: Scaffold(
          backgroundColor: ThemeColors.background,
          appBar: CustomBackAppBar(
            title: L10n.of(context).createAccount,
            onBack: () =>
                context.read<AuthBloc>().add(const AuthEventShouldRegister()),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header with decorative element
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.of(context).joinFatiel,
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
                            ThemeColors.primaryLight,
                            ThemeColors.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildInputField(
                  controller: _firstNameController,
                  icon: Iconsax.user,
                  label: L10n.of(context).firstName,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _lastNameController,
                  icon: Iconsax.user,
                  label: L10n.of(context).lastName,
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
                  isVisible: notVisiblePassword,
                  onVisibilityChanged: passwordVisibility,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: L10n.of(context).confirmPassword,
                  isVisible: notVisibleConfirmPassword,
                  onVisibilityChanged: confirmPasswordVisibility,
                ),
                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : createVisitorAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.primary,
                      foregroundColor: ThemeColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      shadowColor: ThemeColors.shadowDark,
                      disabledBackgroundColor:
                          ThemeColors.primary.withOpacity(0.6),
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
                            L10n.of(context).createAccountButton,
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
            color: ThemeColors.primary.withOpacity(0.05),
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
            color: ThemeColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: ThemeColors.primary,
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
              color: ThemeColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
        cursorColor: ThemeColors.primary,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isVisible,
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
            color: ThemeColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(
              Iconsax.lock_1,
              size: 20,
              color: ThemeColors.primary,
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: onVisibilityChanged,
              icon: Icon(
                isVisible ? Iconsax.eye_slash : Iconsax.eye,
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
              color: ThemeColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
        cursorColor: ThemeColors.primary,
      ),
    );
  }
}
