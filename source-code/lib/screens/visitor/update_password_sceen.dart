import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      showGenericDialog<void>(
        context: context,
        title: "Error",
        content: "New password and confirmation do not match.",
        optionBuilder: () => {'OK': true},
      );
      return;
    }

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
    required VoidCallback toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
              color: VisitorThemeColors.primaryColor),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: VisitorThemeColors.lightGrayColor,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your $label.";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters.";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateUpdatePassword) {
          if (state.exception == null && !state.isLoading) {
            await showGenericDialog<void>(
              context: context,
              title: "Success",
              content: "Your password has been updated successfully.",
              optionBuilder: () => {'OK': true},
            );
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          } else if (state.exception is WeakPasswordException) {
            await showErrorDialog(context, 'Weak password.');
          } else if (state.exception is WrongPasswordException) {
            await showErrorDialog(context, 'Wrong credentials.');
          } else if (state.exception is RequiresRecentLoginException) {
            await showErrorDialog(context, 'Reauthentication required.');
          } else if (state.exception is GenericException) {
            await showErrorDialog(context, 'Authentication error.');
          }
        }
      },
      child: Scaffold(
        backgroundColor: VisitorThemeColors.whiteColor,
        appBar: CustomBackAppBar(
          title: "Update Password",
          titleColor: VisitorThemeColors.deepBlueAccent,
          iconColor: VisitorThemeColors.deepBlueAccent,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: "Current Password",
                  obscureText: _obscureCurrentPassword,
                  toggleVisibility: () {
                    setState(() =>
                        _obscureCurrentPassword = !_obscureCurrentPassword);
                  },
                ),
                const SizedBox(height: 15),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: "New Password",
                  obscureText: _obscureNewPassword,
                  toggleVisibility: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                ),
                const SizedBox(height: 15),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  obscureText: _obscureConfirmPassword,
                  toggleVisibility: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _updatePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: VisitorThemeColors.primaryColor,
                    foregroundColor: VisitorThemeColors.whiteColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.lock_reset, size: 24),
                  label: const Text(
                    "Update Password",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
