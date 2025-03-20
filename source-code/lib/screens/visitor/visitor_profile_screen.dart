// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:typed_data';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';

class VisitorProfileScreen extends StatefulWidget {
  const VisitorProfileScreen({super.key});

  @override
  State<VisitorProfileScreen> createState() => _VisitorProfileScreenState();
}

class _VisitorProfileScreenState extends State<VisitorProfileScreen> {
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _logout() async {
    final context = this.context; // Capture context before the async call

    final shouldLogout = await showGenericDialog<bool>(
      context: context,
      title: "Logout",
      content: 'Are you sure you want to log out?',
      optionBuilder: () => {'No': false, 'Yes, Logout': true},
    ).then((value) => value ?? false);

    if (!shouldLogout) return;

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (context.mounted) {
      context.read<AuthBloc>().add(const AuthEventLogOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomBackAppBar(
        title: "Your Profile",
        titleColor: VisitorThemeColors.deepBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Profile Avatar with Camera Button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : const AssetImage(
                              "assets/images/default-avatar-icon.jpg")
                          as ImageProvider,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VisitorThemeColors.deepBlueAccent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Profile Action Buttons
            ProfileActionButton(
              text: "Update Information",
              icon: Icons.person_outline,
              onTap: () {},
            ),
            ProfileActionButton(
              text: "Update Password",
              icon: Icons.lock_outline,
              onTap: () => Navigator.of(context).pushNamed(updatePasswordRoute),
            ),

            const Spacer(),

            // Log Out Button
            TextButton(
              onPressed: _logout,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: VisitorThemeColors.deepBlueAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    "Log Out",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ProfileActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              VisitorThemeColors.deepBlueAccent.withOpacity(0.1),
              VisitorThemeColors.deepBlueAccent.withOpacity(0.16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: VisitorThemeColors.deepBlueAccent, size: 26),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: VisitorThemeColors.deepBlueAccent, size: 26),
          ],
        ),
      ),
    );
  }
}
