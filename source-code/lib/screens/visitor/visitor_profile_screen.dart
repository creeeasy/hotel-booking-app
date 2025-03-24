import 'dart:typed_data';
import 'package:fatiel/enum/avatar_action.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/cloudinary/cloudinary_service.dart';
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
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final visitor = context.read<AuthBloc>().state.currentUser as Visitor;
    setState(() => _imageUrl = visitor.avatarURL);
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      Uint8List fileBytes = await pickedFile.readAsBytes();
      String? imageUrl =
          await CloudinaryService.uploadImageWeb(fileBytes, pickedFile.name);
      if (imageUrl == null) throw Exception("Image upload failed");

      final visitorId =
          (context.read<AuthBloc>().state.currentUser as Visitor).id;
      await Visitor.modifyVisitorAvatar(
        action: AvatarAction.update,
        visitorId: visitorId,
        newAvatarUrl: imageUrl,
      );

      setState(() {
        _imageBytes = fileBytes;
        _imageUrl = imageUrl;
      });

      _showSnackBar("Image updated successfully");
    } catch (e) {
      _showSnackBar("Failed to upload image");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteProfileImage() async {
    final shouldDelete = await _showConfirmationDialog(
        "Delete Image", "Are you sure you want to delete your profile image?");
    if (!shouldDelete) return;

    try {
      final visitorId =
          (context.read<AuthBloc>().state.currentUser as Visitor).id;
      await Visitor.modifyVisitorAvatar(
          action: AvatarAction.remove, visitorId: visitorId);
      setState(() {
        _imageBytes = null;
        _imageUrl = null;
      });
      _showSnackBar("Image deleted successfully");
    } catch (e) {
      _showSnackBar("Failed to delete image");
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await _showConfirmationDialog(
        "Logout", "Are you sure you want to log out?");
    if (!shouldLogout) return;
    if (!context.mounted) return;

    context.read<AuthBloc>().add(const AuthEventLogOut());
    Navigator.of(context).pop();
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showGenericDialog<bool>(
      context: context,
      title: title,
      content: content,
      optionBuilder: () => {"No": false, "Yes": true},
    ).then((value) => value ?? false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomBackAppBar(
          title: "Your Profile",
          titleColor: VisitorThemeColors.joyfulPurple,
          iconColor: VisitorThemeColors.joyfulPurple,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildProfileAvatar(),
              if (_isUploading) _buildUploadingText(),
              const SizedBox(height: 7),
              if (_imageUrl != null || _imageBytes != null)
                _buildDeleteButton(),
              const SizedBox(height: 25),
              _buildProfileActions(),
              const Spacer(),
              _buildLogoutButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey[300],
          backgroundImage: _imageBytes != null
              ? MemoryImage(_imageBytes!)
              : _imageUrl != null
                  ? NetworkImage(_imageUrl!)
                  : const AssetImage("assets/images/default-avatar-icon.jpg")
                      as ImageProvider,
        ),
        GestureDetector(
          onTap: _pickAndUploadImage,
          child: _buildCameraIcon(),
        ),
      ],
    );
  }

  Widget _buildCameraIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: VisitorThemeColors.joyfulPurple,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isUploading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
    );
  }

  Widget _buildUploadingText() {
    return const Padding(
      padding: EdgeInsets.only(top: 7),
      child: Text(
        'Uploading...',
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: VisitorThemeColors.joyfulPurple,
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return TextButton.icon(
        onPressed: _deleteProfileImage,
        style: TextButton.styleFrom(
            foregroundColor: VisitorThemeColors.vibrantRed,
            backgroundColor: VisitorThemeColors.vibrantRed.withOpacity(0.16)),
        icon: const Icon(Icons.delete,
            size: 20, color: VisitorThemeColors.vibrantRed),
        label: const Text("DELETE IMAGE",
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: VisitorThemeColors.vibrantRed,
            )));
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        ProfileActionButton(
            text: "Update Information",
            icon: Icons.person_outline,
            onTap: () =>
                Navigator.of(context).pushNamed(updateInformationRoute)),
        ProfileActionButton(
            text: "Update Password",
            icon: Icons.lock_outline,
            onTap: () => Navigator.of(context).pushNamed(updatePasswordRoute)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: _logout,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.redAccent.withOpacity(0.16),
        foregroundColor: VisitorThemeColors.vibrantRed,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.redAccent, size: 22),
          SizedBox(width: 10),
          Text(
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
              VisitorThemeColors.lavenderPurple.withOpacity(0.1),
              VisitorThemeColors.lavenderPurple.withOpacity(0.16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: VisitorThemeColors.lavenderPurple, size: 26),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: VisitorThemeColors.lavenderPurple,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: VisitorThemeColors.lavenderPurple, size: 26),
          ],
        ),
      ),
    );
  }
}
