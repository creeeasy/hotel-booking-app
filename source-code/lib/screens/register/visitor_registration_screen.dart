import 'package:fatiel/constants/colors/ThemeColorss.dart';
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
          content: const Text("Please enter your first and last name."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: ThemeColors.error,
        ),
      );
      return;
    }

    if (mail.isEmpty || !mail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid email address."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: ThemeColors.error,
        ),
      );
      return;
    }

    if (pwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password must be at least 6 characters long."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: ThemeColors.error,
        ),
      );
      return;
    }

    if (pwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Passwords do not match."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: ThemeColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthEventVisitorRegistering(
          fname,
          lname,
          mail,
          pwd,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateVisitorRegistering) {
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
        backgroundColor: ThemeColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left_2, size: 24),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventShouldRegister());
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: ThemeColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
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
                  const Text(
                    "Join Fatiel",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.primaryDark,
                      letterSpacing: 0.8,
                    ),
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
                ],
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildInputField(
                controller: _firstNameController,
                icon: Iconsax.user,
                label: 'First Name',
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _lastNameController,
                icon: Iconsax.user,
                label: 'Last Name',
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _emailController,
                icon: Iconsax.sms,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _passwordController,
                label: 'Password',
                isVisible: notVisiblePassword,
                onVisibilityChanged: passwordVisibility,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                isVisible: notVisibleConfirmPassword,
                onVisibilityChanged: confirmPasswordVisibility,
              ),
              const SizedBox(height: 40),

              // Register Button
              ElevatedButton(
                onPressed: createVisitorAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: ThemeColors.textOnPrimary,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: ThemeColors.border.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: ThemeColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: ThemeColors.border.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Social Login Options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: Icons.local_bar, // Example: Using a different icon
                    color: ThemeColors.accentPink,
                  ),
                  const SizedBox(width: 20),
                  _buildSocialButton(
                    icon: Icons.apple, // Material Icons has an apple icon
                    color: ThemeColors.accentDeep,
                  ),
                  const SizedBox(width: 20),
                  _buildSocialButton(
                    icon: Icons.g_mobiledata, // Alternative for Google
                    color: ThemeColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Terms and Privacy
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: ThemeColors.textSecondary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'By signing up, you agree to our '),
                      const TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: ThemeColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      const TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: ThemeColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: ThemeColors.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ThemeColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: ThemeColors.primaryLight,
        ),
        filled: true,
        fillColor: ThemeColors.surface.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      cursorColor: ThemeColors.primary,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isVisible,
      style: const TextStyle(
        color: ThemeColors.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ThemeColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Iconsax.lock,
          size: 20,
          color: ThemeColors.primaryLight,
        ),
        suffixIcon: IconButton(
          onPressed: onVisibilityChanged,
          icon: Icon(
            isVisible ? Iconsax.eye_slash : Iconsax.eye,
            size: 20,
            color: ThemeColors.primaryLight,
          ),
        ),
        filled: true,
        fillColor: ThemeColors.surface.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      cursorColor: ThemeColors.primary,
    );
  }

  Widget _buildSocialButton({required IconData icon, required Color color}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }
}
