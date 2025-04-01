import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/helpers/auth_helper.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/cloudinary/cloudinary_service.dart';
import 'package:fatiel/services/hotel/hotel_service.dart';
import 'package:fatiel/utils/multi_value_listenable_builder.dart';
import 'package:fatiel/widgets/circular_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class HotelProfileView extends StatefulWidget {
  const HotelProfileView({super.key});

  @override
  State<HotelProfileView> createState() => _HotelProfileViewState();
}

class _HotelProfileViewState extends State<HotelProfileView> {
  final _formKey = GlobalKey<FormState>();
  late Hotel _currentHotel;
  final _isEditing = ValueNotifier<bool>(false);
  final _isLoading = ValueNotifier<bool>(false);
  final _tempImages = ValueNotifier<List<String>>([]);
  final _isImageLoading = ValueNotifier<bool>(false);
  final _selectedWilayaIndex = ValueNotifier<int?>(null);
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _currentHotel = context.read<AuthBloc>().state.currentUser as Hotel;
    _tempImages.value = List.from(_currentHotel.images);
    _selectedWilayaIndex.value = _currentHotel.location;
  }

  @override
  void dispose() {
    _isEditing.dispose();
    _isLoading.dispose();
    _tempImages.dispose();
    _selectedWilayaIndex.dispose();
    _isImageLoading.dispose();
    super.dispose();
  }

  Future<void> _updateHotelProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    _isLoading.value = true;

    final updatedHotel = _currentHotel.copyWith(
      images: _tempImages.value,
      location: _selectedWilayaIndex.value,
    );

    try {
      await HotelService.updateHotel(hotel: updatedHotel);
      if (context.mounted) {
        context.read<AuthBloc>().add(const AuthEventInitialize());
      }
      _isEditing.value = false;
      _showSnackbar('Profile updated successfully', isError: false);
    } catch (e) {
      _showSnackbar('Error updating profile: $e', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _uploadImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      _isImageLoading.value = true;

      final fileBytes = await image.readAsBytes();
      final fileName =
          'hotel_${_currentHotel.id}_${DateTime.now().millisecondsSinceEpoch}';
      final imageUrl =
          await CloudinaryService.uploadImageWeb(fileBytes, fileName);

      if (imageUrl == null) throw Exception("Image upload failed");

      _tempImages.value = [..._tempImages.value, imageUrl];
      _showSnackbar('Image uploaded successfully', isError: false);
    } catch (e) {
      _showSnackbar('Error uploading image: $e', isError: true);
    } finally {
      _isImageLoading.value = false;
    }
  }

  Future<void> _removeImage(int index) async {
    try {
      _isImageLoading.value = true;
      final url = _tempImages.value[index];
      final publicId = CloudinaryService.extractPublicIdFromUrl(url);

      if (publicId != null) {
        await CloudinaryService.deleteImage(publicId);
      }

      _tempImages.value = List.from(_tempImages.value)..removeAt(index);
      _showSnackbar('Image removed successfully', isError: false);
    } catch (e) {
      _showSnackbar('Error removing image: $e', isError: true);
    } finally {
      _isImageLoading.value = false;
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? ThemeColors.error : ThemeColors.success,
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ThemeColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadowDark,
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ThemeColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Iconsax.setting_2, color: ThemeColors.primary),
              title: const Text('Settings',
                  style: TextStyle(color: ThemeColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page if you have one
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.logout, color: ThemeColors.error),
              title: const Text('Log Out',
                  style: TextStyle(color: ThemeColors.error)),
              onTap: () => handleLogout(context),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ThemeColors.primary),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: ThemeColors.primary)),
              ),
            ),
          ],
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
          title: 'Profile',
          actions: [
            IconButton(
              icon:
                  const Icon(Iconsax.setting_2, color: ThemeColors.primaryDark),
              onPressed: _showSettingsBottomSheet,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isEditing,
              builder: (context, isEditing, _) {
                return isEditing
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _isLoading,
                        builder: (context, isLoading, _) {
                          return isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ThemeColors.primaryDark,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Iconsax.tick_circle,
                                      color: ThemeColors.primaryDark),
                                  onPressed: _updateHotelProfile,
                                );
                        },
                      )
                    : IconButton(
                        icon: const Icon(Iconsax.edit_2,
                            color: ThemeColors.primaryDark),
                        onPressed: () => _isEditing.value = true,
                      );
              },
            ),
          ],
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, isLoading, _) {
            return isLoading
                ? const CircularProgressIndicatorWidget()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(),
                          const SizedBox(height: 24),
                          _buildBasicInfoSection(),
                          const SizedBox(height: 24),
                          _buildContactInfoSection(),
                          const SizedBox(height: 24),
                          _buildLocationSection(),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return MultiValueListenableBuilder<List<String>, bool, bool>(
      valueListenable1: _tempImages,
      valueListenable2: _isEditing,
      valueListenable3: _isImageLoading,
      builder: (context, images, isEditing, isImageLoading) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: ThemeColors.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  icon: Iconsax.gallery,
                  title: 'Hotel Photos',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: isImageLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ThemeColors.primary,
                          ),
                        )
                      : images.isEmpty && !isEditing
                          ? const Center(
                              child: Text(
                                'No photos added',
                                style: TextStyle(
                                  color: ThemeColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (isEditing) _buildAddPhotoButton(),
                                ...images.map(
                                  (url) => _buildImageThumbnail(
                                    url,
                                    images.indexOf(url),
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ThemeColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _uploadImage,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: ThemeColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.primary.withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add, size: 24, color: ThemeColors.primary),
            SizedBox(height: 8),
            Text('Add Photo', style: TextStyle(color: ThemeColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String url, int index) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEditing,
      builder: (context, isEditing, _) {
        return Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    return loadingProgress == null
                        ? child
                        : Container(
                            width: 120,
                            height: 120,
                            color: ThemeColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ThemeColors.primary,
                              ),
                            ),
                          );
                  },
                ),
              ),
              if (isEditing)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: ThemeColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: ThemeColors.textOnPrimary),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEditing,
      builder: (context, isEditing, _) {
        return _buildSectionCard(
          icon: Iconsax.info_circle,
          title: 'Basic Information',
          children: [
            TextFormField(
              initialValue: _currentHotel.hotelName,
              decoration: _buildInputDecoration(
                label: 'Hotel Name',
                icon: Iconsax.building,
              ),
              enabled: isEditing,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onSaved: (value) => _currentHotel =
                  _currentHotel.copyWith(hotelName: value ?? ''),
              style: const TextStyle(color: ThemeColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _currentHotel.description,
              decoration: _buildInputDecoration(
                label: 'Description',
                icon: Iconsax.note_text,
              ),
              enabled: isEditing,
              maxLines: 3,
              onSaved: (value) =>
                  _currentHotel = _currentHotel.copyWith(description: value),
              style: const TextStyle(color: ThemeColors.textPrimary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactInfoSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEditing,
      builder: (context, isEditing, _) {
        return _buildSectionCard(
          icon: Iconsax.call,
          title: 'Contact Information',
          children: [
            TextFormField(
              initialValue: _currentHotel.contactInfo,
              decoration: _buildInputDecoration(
                label: 'Phone Number',
                icon: Iconsax.call,
              ),
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onSaved: (value) => _currentHotel =
                  _currentHotel.copyWith(contactInfo: value ?? ''),
              style: const TextStyle(color: ThemeColors.textPrimary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationSection() {
    return ValueListenableBuilder<int?>(
      valueListenable: _selectedWilayaIndex,
      builder: (context, selectedWilaya, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isEditing,
          builder: (context, isEditing, _) {
            return _buildSectionCard(
              icon: Iconsax.location,
              title: 'Location',
              children: [
                DropdownButtonFormField<int>(
                  value: selectedWilaya,
                  decoration: _buildInputDecoration(
                    label: 'Wilaya',
                    icon: Iconsax.map,
                  ),
                  dropdownColor: ThemeColors.card,
                  style: const TextStyle(color: ThemeColors.textPrimary),
                  items: Wilaya.values.map((wilaya) {
                    return DropdownMenuItem<int>(
                      value: wilaya.ind,
                      child: Text(
                        wilaya.name,
                        style: const TextStyle(color: ThemeColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: isEditing
                      ? (value) => _selectedWilayaIndex.value = value
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _currentHotel.mapLink,
                  decoration: _buildInputDecoration(
                    label: 'Map Link',
                    icon: Iconsax.link,
                  ),
                  enabled: isEditing,
                  onSaved: (value) =>
                      _currentHotel = _currentHotel.copyWith(mapLink: value),
                  style: const TextStyle(color: ThemeColors.textPrimary),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: ThemeColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(icon: icon, title: title),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ThemeColors.textSecondary),
      prefixIcon: Icon(icon, color: ThemeColors.primary),
      filled: true,
      fillColor: ThemeColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeColors.error),
      ),
    );
  }
}
