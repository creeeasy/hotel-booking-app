import 'package:fatiel/constants/colors/ThemeColorss.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginPage();
}

class _LoginPage extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool notVisible = true;
  bool _isLoading = false;

  void togglePasswordVisibility() {
    setState(() {
      notVisible = !notVisible;
    });
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      context.read<AuthBloc>().add(AuthEventLogIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateLoggedOut) {
            setState(() => _isLoading = false);
            if (state.exception is UserNotFoundException) {
              await showErrorDialog(context, 'User not found');
            } else if (state.exception is InvalidEmailException) {
              await showErrorDialog(context, 'Invalid email');
            } else if (state.exception is MissingPasswordException) {
              await showErrorDialog(context, 'Missing password');
            } else if (state.exception is WrongPasswordException) {
              await showErrorDialog(context, 'Wrong credentials');
            } else if (state.exception is GenericException) {
              await showErrorDialog(context, 'Authentication error');
            }
          }
        },
        child: Scaffold(
          appBar: const CustomBackAppBar(
            title: 'Login',
          ),
          backgroundColor: ThemeColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                // Header with improved typography
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.primaryDark,
                        letterSpacing: 0.5,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Sign in to access your account",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ThemeColors.textSecondary.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 56),

                // Form with improved styling
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field with refined styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.primary.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ThemeColors.white,
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: ThemeColors.primary.withOpacity(0.08),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                              ),
                              child: const Icon(
                                Iconsax.sms,
                                color: ThemeColors.primary,
                                size: 22,
                              ),
                            ),
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              color: ThemeColors.textSecondary.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: ThemeColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                              vertical: 20,
                              horizontal: 18,
                            ),
                            hintText: 'your@email.com',
                            hintStyle: const TextStyle(
                              color: ThemeColors.grey400,
                              fontSize: 15,
                            ),
                          ),
                          controller: _emailController,
                          cursorColor: ThemeColors.primary,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            color: ThemeColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Password Field with refined styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.primary.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          obscureText: notVisible,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ThemeColors.white,
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: ThemeColors.primary.withOpacity(0.08),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                              ),
                              child: const Icon(
                                Iconsax.lock_1,
                                color: ThemeColors.primary,
                                size: 22,
                              ),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: ThemeColors.textSecondary.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: ThemeColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                              vertical: 20,
                              horizontal: 18,
                            ),
                            hintText: '••••••••',
                            hintStyle: const TextStyle(
                              color: ThemeColors.grey400,
                              fontSize: 15,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: IconButton(
                                onPressed: togglePasswordVisibility,
                                icon: Icon(
                                  notVisible ? Iconsax.eye : Iconsax.eye_slash,
                                  color: ThemeColors.textSecondary
                                      .withOpacity(0.6),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          controller: _passwordController,
                          cursorColor: ThemeColors.primary,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            color: ThemeColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Forgot Password with better styling
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventForgotPassword());
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  ThemeColors.primary.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Login Button with improved styling
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.primary,
                            foregroundColor: ThemeColors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: ThemeColors.primary.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Iconsax.login_1, size: 22),
                                    SizedBox(width: 12),
                                    Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 56),

                // Divider with improved styling
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: ThemeColors.textSecondary.withOpacity(0.15),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: ThemeColors.textSecondary.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: ThemeColors.textSecondary.withOpacity(0.15),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Register Prompt with improved styling
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: ThemeColors.textSecondary.withOpacity(0.8),
                        fontSize: 15,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: ThemeColors.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                ThemeColors.primary.withOpacity(0.4),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEventShouldRegister());
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
