import 'package:fatiel/constants/colors/hotel_theme_colors.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/wilaya.dart';
import 'package:fatiel/screens/hotel/widget/headline_text_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/services/cloudinary/cloudinary_service.dart';
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
      await Hotel.updateHotel(hotel: updatedHotel);
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
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showSettingsBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.setting_2, color: colorScheme.primary),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page if you have one
              },
            ),
            ListTile(
              leading: Icon(Iconsax.logout, color: colorScheme.error),
              title: const Text('Log Out'),
              onTap: _confirmLogout,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close settings sheet
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const HeadlineText(text: "Profile"),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Iconsax.tick_circle),
                                onPressed: _updateHotelProfile,
                              );
                      },
                    )
                  : IconButton(
                      icon: const Icon(Iconsax.edit_2),
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
              ? const CircularProgressIndicatorWidget(
                  indicatorColor: BoutiqueHotelTheme.primaryBlue)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection(colorScheme),
                        const SizedBox(height: 24),
                        _buildBasicInfoSection(colorScheme),
                        const SizedBox(height: 24),
                        _buildContactInfoSection(colorScheme),
                        const SizedBox(height: 24),
                        _buildLocationSection(colorScheme),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme) {
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
          color: colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  icon: Iconsax.gallery,
                  title: 'Hotel Photos',
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: isImageLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        )
                      : images.isEmpty && !isEditing
                          ? Center(
                              child: Text(
                                'No photos added',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            )
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (isEditing)
                                  _buildAddPhotoButton(colorScheme),
                                ...images.map(
                                  (url) => _buildImageThumbnail(
                                    url,
                                    images.indexOf(url),
                                    colorScheme,
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
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _uploadImage,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add, size: 24, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text('Add Photo', style: TextStyle(color: colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String url, int index, ColorScheme colorScheme) {
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
                            color: colorScheme.surfaceVariant,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
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
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection(ColorScheme colorScheme) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEditing,
      builder: (context, isEditing, _) {
        return _buildSectionCard(
          colorScheme: colorScheme,
          icon: Iconsax.info_circle,
          title: 'Basic Information',
          children: [
            TextFormField(
              initialValue: _currentHotel.hotelName,
              decoration: _buildInputDecoration(
                label: 'Hotel Name',
                icon: Iconsax.building,
                colorScheme: colorScheme,
              ),
              enabled: isEditing,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onSaved: (value) => _currentHotel =
                  _currentHotel.copyWith(hotelName: value ?? ''),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _currentHotel.description,
              decoration: _buildInputDecoration(
                label: 'Description',
                icon: Iconsax.note_text,
                colorScheme: colorScheme,
              ),
              enabled: isEditing,
              maxLines: 3,
              onSaved: (value) =>
                  _currentHotel = _currentHotel.copyWith(description: value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactInfoSection(ColorScheme colorScheme) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEditing,
      builder: (context, isEditing, _) {
        return _buildSectionCard(
          colorScheme: colorScheme,
          icon: Iconsax.call,
          title: 'Contact Information',
          children: [
            TextFormField(
              initialValue: _currentHotel.contactInfo,
              decoration: _buildInputDecoration(
                label: 'Phone Number',
                icon: Iconsax.call,
                colorScheme: colorScheme,
              ),
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onSaved: (value) => _currentHotel =
                  _currentHotel.copyWith(contactInfo: value ?? ''),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationSection(ColorScheme colorScheme) {
    return ValueListenableBuilder<int?>(
      valueListenable: _selectedWilayaIndex,
      builder: (context, selectedWilaya, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isEditing,
          builder: (context, isEditing, _) {
            return _buildSectionCard(
              colorScheme: colorScheme,
              icon: Iconsax.location,
              title: 'Location',
              children: [
                DropdownButtonFormField<int>(
                  value: selectedWilaya,
                  decoration: _buildInputDecoration(
                    label: 'Wilaya',
                    icon: Iconsax.map,
                    colorScheme: colorScheme,
                  ),
                  dropdownColor: colorScheme.surface,
                  items: Wilaya.values.map((wilaya) {
                    return DropdownMenuItem<int>(
                      value: wilaya.ind,
                      child: Text(
                        wilaya.name,
                        style: TextStyle(color: colorScheme.onSurface),
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
                    colorScheme: colorScheme,
                  ),
                  enabled: isEditing,
                  onSaved: (value) =>
                      _currentHotel = _currentHotel.copyWith(mapLink: value),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                icon: icon, title: title, colorScheme: colorScheme),
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
    required ColorScheme colorScheme,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      filled: true,
      fillColor: colorScheme.surface,
    );
  }
}
