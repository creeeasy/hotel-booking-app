import 'package:fatiel/services/auth/auth_exceptions.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/auth/bloc/auth_state.dart';
import 'package:fatiel/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        const SnackBar(content: Text("Please enter your first and last name.")),
      );
      return;
    }

    if (mail.isEmpty || !mail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    if (pwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password must be at least 6 characters long.")),
      );
      return;
    }

    if (pwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
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
        backgroundColor: ThemeColors.lightGrayColor,
        appBar: AppBar(
          leading: IconButton(
            color: ThemeColors.blackColor,
            icon: const Icon(Icons.chevron_left, size: 32),
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
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: ThemeColors.blackColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  icon:
                      Icon(Icons.person_outline, color: ThemeColors.blackColor),
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
                      borderSide: BorderSide(color: ThemeColors.primaryColor)),
                ),
                cursorColor: ThemeColors.primaryColor,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  icon:
                      Icon(Icons.person_outline, color: ThemeColors.blackColor),
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
                      borderSide: BorderSide(color: ThemeColors.primaryColor)),
                ),
                cursorColor: ThemeColors.primaryColor,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
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
                      borderSide: BorderSide(color: ThemeColors.primaryColor)),
                ),
                cursorColor: ThemeColors.primaryColor,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: notVisiblePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  icon: const Icon(Icons.lock_outline_rounded,
                      color: ThemeColors.blackColor),
                  suffixIcon: IconButton(
                    onPressed: passwordVisibility,
                    icon: Icon(
                      notVisiblePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: ThemeColors.blackColor,
                    ),
                  ),
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
                      borderSide: BorderSide(color: ThemeColors.primaryColor)),
                ),
                cursorColor: ThemeColors.primaryColor,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: notVisibleConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  icon: const Icon(Icons.lock_outline_rounded,
                      color: ThemeColors.blackColor),
                  suffixIcon: IconButton(
                    onPressed: confirmPasswordVisibility,
                    icon: Icon(
                      notVisibleConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: ThemeColors.blackColor,
                    ),
                  ),
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
                      borderSide: BorderSide(color: ThemeColors.primaryColor)),
                ),
                cursorColor: ThemeColors.primaryColor,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: createVisitorAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
