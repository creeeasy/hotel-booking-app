import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      await showErrorDialog(
        context,
        L10n.of(context).passwordMismatch,
        // backgroundColor: ThemeColors.error.withOpacity(0.9),
        // textColor: ThemeColors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(
          AuthEventUpdatePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          ),
        );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ThemeColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Iconsax.eye_slash : Iconsax.eye,
            color: ThemeColors.primary,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThemeColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThemeColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThemeColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThemeColors.error,
          ),
        ),
        filled: true,
        fillColor: ThemeColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ThemeColors.textPrimary,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateUpdatePassword) {
            setState(() => _isLoading = state.isLoading);

            if (state.exception == null && !state.isLoading) {
              await showGenericDialog<void>(
                context: context,
                title: L10n.of(context).success,
                content: L10n.of(context).passwordUpdatedSuccessfully,
                optionBuilder: () => {'OK': true},
              );
              if (mounted) {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthEventInitialize());
              }
            } else if (state.exception != null) {
              final errorMessage = _getErrorMessage(state.exception, context);
              await showErrorDialog(
                context,
                errorMessage,
                // backgroundColor: ThemeColors.error.withOpacity(0.9),
                // textColor: ThemeColors.white,
              );
            }
          }
        },
        child: Scaffold(
          backgroundColor: ThemeColors.background,
          appBar: CustomBackAppBar(
            title: L10n.of(context).updatePassword,
            titleColor: ThemeColors.primary,
            iconColor: ThemeColors.primary,
            backgroundColor: ThemeColors.background,
            onBack: () => Navigator.of(context).pop(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: L10n.of(context).currentPassword,
                    obscureText: _obscureCurrentPassword,
                    onToggleVisibility: () => setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return L10n.of(context).pleaseEnterCurrentPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: L10n.of(context).newPassword,
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return L10n.of(context).pleaseEnterNewPassword;
                      }
                      if (value.length < 6) {
                        return L10n.of(context)
                            .passwordMustBeAtLeast6Characters;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: L10n.of(context).confirmPassword,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return L10n.of(context).passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primary,
                        disabledBackgroundColor: ThemeColors.grey300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: ThemeColors.shadow,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ThemeColors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.lock_1,
                                    size: 20, color: ThemeColors.white),
                                const SizedBox(width: 8),
                                Text(
                                  L10n.of(context).updatePassword,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeColors.white,
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
        ),
      ),
    );
  }

  String _getErrorMessage(Exception? exception, BuildContext context) {
    if (exception is WeakPasswordException) {
      return L10n.of(context).weakPassword;
    } else if (exception is WrongPasswordException) {
      return L10n.of(context).wrongPassword;
    } else if (exception is RequiresRecentLoginException) {
      return L10n.of(context).requiresRecentLogin;
    } else if (exception is GenericException) {
      return L10n.of(context).genericError;
    }
    return L10n.of(context).failedToUpdatePassword;
  }
}
