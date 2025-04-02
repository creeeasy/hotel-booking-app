import 'dart:typed_data';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/enum/avatar_action.dart';
import 'package:fatiel/helpers/auth_helper.dart';
import 'package:fatiel/providers/locale_provider.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/visitor/visitor_service.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fatiel/constants/routes/routes.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/cloudinary/cloudinary_service.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final fileBytes = await pickedFile.readAsBytes();
      final imageUrl =
          await CloudinaryService.uploadImageWeb(fileBytes, pickedFile.name);
      if (imageUrl == null) throw Exception(L10n.of(context).imageUploadFailed);

      final visitorId =
          (context.read<AuthBloc>().state.currentUser as Visitor).id;
      await VisitorService.modifyVisitorAvatar(
        action: AvatarAction.update,
        visitorId: visitorId,
        newAvatarUrl: imageUrl,
      );

      setState(() {
        _imageBytes = fileBytes;
        _imageUrl = imageUrl;
      });
      _showSnackBar(L10n.of(context).profileImageUpdatedSuccessfully);
      context.read<AuthBloc>().add(const AuthEventInitialize());
    } catch (e) {
      _showSnackBar("${L10n.of(context).failedToUploadImage}: ${e.toString()}");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteProfileImage() async {
    final shouldDelete = await showGenericDialog<bool>(
      context: context,
      title: L10n.of(context).removeProfileImage,
      content: L10n.of(context).removeProfileImageConfirmation,
      optionBuilder: () =>
          {L10n.of(context).cancel: false, L10n.of(context).remove: true},
    ).then((value) => value ?? false);

    if (!shouldDelete) return;

    try {
      final visitorId =
          (context.read<AuthBloc>().state.currentUser as Visitor).id;
      await VisitorService.modifyVisitorAvatar(
        action: AvatarAction.remove,
        visitorId: visitorId,
      );

      setState(() {
        _imageBytes = null;
        _imageUrl = null;
      });

      _showSnackBar(L10n.of(context).profileImageRemoved);
    } catch (e) {
      _showSnackBar("${L10n.of(context).failedToRemoveImage}: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: ThemeColors.textOnDark),
        ),
        backgroundColor: ThemeColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: L10n.of(context).ok,
          textColor: ThemeColors.textOnDark,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: CustomBackAppBar(
          title: L10n.of(context).profileSettings,
          titleColor: ThemeColors.primary,
          iconColor: ThemeColors.primary,
          backgroundColor: ThemeColors.background,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildProfileSection(),
              const SizedBox(height: 32),
              _buildAccountSettingsSection(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        _buildProfileAvatar(),
        const SizedBox(height: 16),
        if (_isUploading) _buildUploadIndicator(),
        if (_imageUrl != null || _imageBytes != null) _buildDeleteImageButton(),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.grey200,
            image: _buildProfileImage(),
            border: Border.all(
              color: ThemeColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        _buildEditPhotoButton(),
      ],
    );
  }

  DecorationImage? _buildProfileImage() {
    if (_imageBytes != null) {
      return DecorationImage(
        image: MemoryImage(_imageBytes!),
        fit: BoxFit.cover,
      );
    } else if (_imageUrl != null) {
      return DecorationImage(
        image: NetworkImage(_imageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildEditPhotoButton() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ThemeColors.primaryGradient,
          border: Border.all(color: ThemeColors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeColors.white,
                ),
              )
            : const Icon(
                Iconsax.camera,
                color: ThemeColors.white,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildUploadIndicator() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          L10n.of(context).uploading,
          style: const TextStyle(
            fontSize: 14,
            color: ThemeColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteImageButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: _deleteProfileImage,
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeColors.error,
          side: BorderSide(color: ThemeColors.error.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Iconsax.trash, size: 18, color: ThemeColors.error),
        label: Text(
          L10n.of(context).removePhoto,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: ThemeColors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsOption(
          icon: Iconsax.global,
          title: L10n.of(context).changeLanguage,
          onTap: () {
            _showLanguagePopup(context);
          },
        ),
        _buildSettingsOption(
          icon: Iconsax.user_edit,
          title: L10n.of(context).updateProfile,
          onTap: () => Navigator.pushNamed(context, updateInformationRoute),
        ),
        _buildSettingsOption(
          icon: Iconsax.lock,
          title: L10n.of(context).changePassword,
          onTap: () => Navigator.pushNamed(context, updatePasswordRoute),
        ),
      ],
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: ThemeColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ThemeColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        color: ThemeColors.textSecondary.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => handleLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeColors.error,
          side: BorderSide(color: ThemeColors.error.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.logout, size: 20, color: ThemeColors.error),
            const SizedBox(width: 8),
            Text(
              L10n.of(context).logOut,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ThemeColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePopup(BuildContext context) {
    final currentLocale =
        Provider.of<LocaleProvider>(context, listen: false).locale ??
            const Locale('en');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          L10n.of(context).selectLanguage,
          style: const TextStyle(
            color: ThemeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: L10n.supportedLocales.map((locale) {
            final isSelected =
                locale.languageCode == currentLocale.languageCode;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: isSelected
                  ? const Icon(Iconsax.tick_circle, color: ThemeColors.primary)
                  : const SizedBox(width: 24),
              title: Text(
                L10n.getLanguageName(locale.languageCode),
                style: TextStyle(
                  color: isSelected
                      ? ThemeColors.primary
                      : ThemeColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('languageCode', locale.languageCode);
                if (context.mounted) {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(locale);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              L10n.of(context).cancel,
              style: const TextStyle(color: ThemeColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
