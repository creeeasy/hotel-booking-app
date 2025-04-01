import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/cloudinary/cloudinary_service.dart';
import 'package:fatiel/services/room/room_service.dart';
import 'package:fatiel/utils/value_listenable_builder2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class HotelRoomsPage extends StatefulWidget {
  const HotelRoomsPage({super.key});

  @override
  State<HotelRoomsPage> createState() => _HotelRoomsPageState();
}

class _HotelRoomsPageState extends State<HotelRoomsPage> {
  late Future<List<Room>> _roomsFuture;
  late String _hotelId;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final currentUser = context.read<AuthBloc>().state.currentUser;
    if (currentUser is Hotel) {
      _hotelId = currentUser.id;
      _refreshRooms();
    } else {
      _roomsFuture = Future.value([]);
    }
  }

  Future<List<Room>> _fetchRooms() async {
    try {
      return await RoomService.getHotelRoomsById(_hotelId);
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
      throw Exception('Failed to load rooms');
    }
  }

  Future<void> _refreshRooms() async {
    setState(() {
      _roomsFuture = _fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: const CustomBackAppBar(
          title: 'Rooms',
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEditRoomDialog(),
          backgroundColor: ThemeColors.primary,
          child: const Icon(Iconsax.add, color: ThemeColors.textOnPrimary),
        ),
        body: RefreshIndicator(
          color: ThemeColors.primary,
          onRefresh: _refreshRooms,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: _buildRoomList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: ThemeColors.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: _buildErrorState(snapshot.error.toString()),
          );
        }

        final rooms = snapshot.data ?? [];
        if (rooms.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RoomCard(
                room: rooms[index],
                onEdit: () => _showAddEditRoomDialog(room: rooms[index]),
                onToggleAvailability: () =>
                    _toggleRoomAvailability(rooms[index]),
                onDelete: () => _confirmDeleteRoom(rooms[index]),
              ),
            ),
            childCount: rooms.length,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.house,
              size: 64, color: ThemeColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No rooms available',
            style: TextStyle(
              fontSize: 18,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddEditRoomDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Add Room'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, size: 64, color: ThemeColors.error),
          const SizedBox(height: 16),
          const Text(
            'Failed to load rooms',
            style: TextStyle(
              fontSize: 18,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: const TextStyle(
                color: ThemeColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshRooms,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRoomAvailability(Room room) async {
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
        'availability.isAvailable': !room.availability.isAvailable,
        'availability.nextAvailableDate': null,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            room.availability.isAvailable
                ? 'Room marked as unavailable'
                : 'Room marked as available',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: ThemeColors.primary,
        ),
      );
      await _refreshRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update room: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ThemeColors.error,
        ),
      );
    }
  }

  void _confirmDeleteRoom(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.card,
        title: const Text(
          'Delete Room',
          style: TextStyle(color: ThemeColors.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone. Are you sure?',
          style: TextStyle(color: ThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ThemeColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteRoom(room);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: ThemeColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(Room room) async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(room.id)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room deleted successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ThemeColors.primary,
        ),
      );
      await _refreshRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete room: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ThemeColors.error,
        ),
      );
    }
  }

  void _showAddEditRoomDialog({Room? room}) {
    final isEditing = room != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: room?.name ?? '');
    final descController = TextEditingController(text: room?.description ?? '');
    final priceController = TextEditingController(
      text: room?.pricePerNight.toStringAsFixed(2) ?? '0.00',
    );

    int capacity = room?.capacity ?? 1;
    List<String> amenities = List.from(room?.amenities ?? []);
    bool isAvailable = room?.availability.isAvailable ?? true;
    final tempImages = ValueNotifier<List<String>>(room?.images ?? []);
    final isImageLoading = ValueNotifier<bool>(false);
    final picker = ImagePicker();

    Future<void> _uploadImage() async {
      try {
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) return;
        isImageLoading.value = true;

        final fileBytes = await image.readAsBytes();
        final fileName =
            'room_${room?.id ?? 'new'}_${DateTime.now().millisecondsSinceEpoch}';
        final imageUrl =
            await CloudinaryService.uploadImageWeb(fileBytes, fileName);

        if (imageUrl == null) throw Exception("Image upload failed");

        tempImages.value = [...tempImages.value, imageUrl];

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeColors.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeColors.error,
          ),
        );
      } finally {
        isImageLoading.value = false;
      }
    }

    Future<void> _removeImage(int index) async {
      try {
        isImageLoading.value = true;
        final url = tempImages.value[index];
        final publicId = CloudinaryService.extractPublicIdFromUrl(url);

        if (publicId != null) {
          final success = await CloudinaryService.deleteImage(publicId);
          if (!success)
            throw Exception("Failed to delete image from Cloudinary");
        }

        tempImages.value = List.from(tempImages.value)..removeAt(index);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image removed successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeColors.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeColors.error,
          ),
        );
      } finally {
        isImageLoading.value = false;
      }
    }

    Widget _buildSectionHeader(IconData icon, String title) {
      return Row(
        children: [
          Icon(icon, size: 20, color: ThemeColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemeColors.primary,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    Widget _buildImageThumbnail(String url, int index) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ThemeColors.surface,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Iconsax.gallery_slash,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: ThemeColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.trash,
                    size: 16,
                    color: ThemeColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildAddPhotoButton() {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: _uploadImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ThemeColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemeColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.add, color: ThemeColors.primary, size: 24),
                SizedBox(height: 4),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildImageSection() {
      return ValueListenableBuilder2<List<String>, bool>(
        valueListenable1: tempImages,
        valueListenable2: isImageLoading,
        builder: (context, images, isLoading, _) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: ThemeColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Iconsax.gallery, 'Room Photos'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: ThemeColors.primary,
                            ),
                          )
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildAddPhotoButton(),
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

    Widget _buildAmenitiesSection() {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: ThemeColors.card,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(Iconsax.tick_circle, 'Amenities'),
              const SizedBox(height: 12),
              StatefulBuilder(builder: (context, setState) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AmenityIcons.amenities.entries.map((entry) {
                    final isSelected = amenities.contains(entry.value.label);
                    return InputChip(
                      label: Text(entry.value.label),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? ThemeColors.textOnPrimary
                            : ThemeColors.textPrimary,
                      ),
                      selected: isSelected,
                      avatar: Icon(
                        entry.value.icon,
                        size: 18,
                        color: isSelected
                            ? ThemeColors.textOnPrimary
                            : ThemeColors.primary,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            amenities.add(entry.value.label);
                          } else {
                            amenities.remove(entry.value.label);
                          }
                        });
                      },
                      selectedColor: ThemeColors.primary,
                      backgroundColor: ThemeColors.surface,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: ThemeColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      isEditing ? 'Edit Room' : 'Add New Room',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic Info Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: ThemeColors.card,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSectionHeader(
                                Iconsax.info_circle, 'Basic Information'),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: nameController,
                              style: const TextStyle(
                                  color: ThemeColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Room Name',
                                labelStyle: const TextStyle(
                                    color: ThemeColors.textSecondary),
                                prefixIcon: const Icon(Iconsax.house,
                                    color: ThemeColors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.primary),
                                ),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: descController,
                              style: const TextStyle(
                                  color: ThemeColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: const TextStyle(
                                    color: ThemeColors.textSecondary),
                                prefixIcon: const Icon(Iconsax.note,
                                    color: ThemeColors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.primary),
                                ),
                              ),
                              maxLines: 3,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pricing & Availability Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: ThemeColors.card,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSectionHeader(Iconsax.dollar_circle,
                                'Pricing & Availability'),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: priceController,
                              style: const TextStyle(
                                  color: ThemeColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Price per night',
                                labelStyle: const TextStyle(
                                    color: ThemeColors.textSecondary),
                                prefixIcon: const Icon(Iconsax.dollar_circle,
                                    color: ThemeColors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.primary),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(value!) == null)
                                  return 'Invalid number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: capacity,
                              dropdownColor: ThemeColors.card,
                              style: const TextStyle(
                                  color: ThemeColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Capacity',
                                labelStyle: const TextStyle(
                                    color: ThemeColors.textSecondary),
                                prefixIcon: const Icon(Iconsax.profile_2user,
                                    color: ThemeColors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ThemeColors.primary),
                                ),
                              ),
                              items: List.generate(10, (i) => i + 1)
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                            '$e ${e == 1 ? 'guest' : 'guests'}'),
                                      ))
                                  .toList(),
                              onChanged: (value) => capacity = value ?? 1,
                            ),
                            const SizedBox(height: 16),
                            StatefulBuilder(builder: (context, setState) {
                              return SwitchListTile(
                                title: const Text(
                                  'Available for booking',
                                  style: TextStyle(
                                    color: ThemeColors.textPrimary,
                                  ),
                                ),
                                value: isAvailable,
                                onChanged: (value) => setState(() {
                                  isAvailable = value;
                                }),
                                contentPadding: EdgeInsets.zero,
                                activeColor: ThemeColors.primary,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Photos Section
                    buildImageSection(),

                    const SizedBox(height: 16),

                    // Amenities Section
                    _buildAmenitiesSection(),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            final roomData = {
                              'hotelId': _hotelId,
                              'name': nameController.text.trim(),
                              'description': descController.text.trim(),
                              'pricePerNight':
                                  double.parse(priceController.text),
                              'capacity': capacity,
                              'amenities': amenities,
                              'images': tempImages.value,
                              'availability': {
                                'isAvailable': isAvailable,
                                'nextAvailableDate': null,
                              },
                            };

                            try {
                              if (isEditing) {
                                await FirebaseFirestore.instance
                                    .collection('rooms')
                                    .doc(room.id)
                                    .update(roomData);
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('rooms')
                                    .add(roomData);
                              }

                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Room updated successfully'
                                        : 'Room added successfully',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: ThemeColors.primary,
                                ),
                              );
                              await _refreshRooms();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to ${isEditing ? 'update' : 'add'} room: $e',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: ThemeColors.error,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.primary,
                          foregroundColor: ThemeColors.textOnPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update Room' : 'Add Room',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onToggleAvailability;
  final VoidCallback onDelete;

  const _RoomCard({
    required this.room,
    required this.onEdit,
    required this.onToggleAvailability,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: ThemeColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRoomImage(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${room.pricePerNight.toStringAsFixed(2)} per night',
                          style: const TextStyle(
                            color: ThemeColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _buildInfoChip(
                                icon: Iconsax.profile_2user,
                                text:
                                    '${room.capacity} ${room.capacity == 1 ? 'guest' : 'guests'}'),
                            _buildInfoChip(
                                icon: Iconsax.calendar,
                                text: room.availability.isAvailable
                                    ? 'Available'
                                    : 'Unavailable',
                                color: room.availability.isAvailable
                                    ? ThemeColors.primary
                                    : ThemeColors.error),
                            if (room.images.isNotEmpty)
                              _buildInfoChip(
                                  icon: Iconsax.gallery,
                                  text:
                                      '${room.images.length} photo${room.images.length > 1 ? 's' : ''}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildMoreOptionsButton(),
                ],
              ),
              if (room.amenities.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: room.amenities.take(3).map((amenity) {
                    final iconData = AmenityIcons.amenities.entries
                        .firstWhere(
                          (entry) => entry.value.label == amenity,
                          orElse: () =>
                              const MapEntry('', AmenityIcon(Iconsax.box, '')),
                        )
                        .value
                        .icon;
                    return Chip(
                      label: Text(
                        amenity,
                        style: const TextStyle(color: ThemeColors.textPrimary),
                      ),
                      avatar:
                          Icon(iconData, size: 16, color: ThemeColors.primary),
                      backgroundColor: ThemeColors.surface,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                if (room.amenities.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${room.amenities.length - 3} more',
                      style: const TextStyle(
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 100,
        color: ThemeColors.surface,
        child: room.images.isNotEmpty
            ? Image.network(
                room.images.first,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Iconsax.image,
                    color: ThemeColors.textSecondary,
                  ),
                ),
              )
            : const Center(
                child: Icon(
                  Iconsax.image,
                  color: ThemeColors.textSecondary,
                ),
              ),
      ),
    );
  }

  Widget _buildMoreOptionsButton() {
    return PopupMenuButton(
      icon: const Icon(
        Iconsax.more,
        color: ThemeColors.textPrimary,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Text(
            'Edit',
            style: TextStyle(color: ThemeColors.textPrimary),
          ),
          onTap: onEdit,
        ),
        PopupMenuItem(
          child: Text(
            room.availability.isAvailable
                ? 'Mark Unavailable'
                : 'Mark Available',
            style: const TextStyle(color: ThemeColors.textPrimary),
          ),
          onTap: onToggleAvailability,
        ),
        PopupMenuItem(
          child: const Text(
            'Delete',
            style: TextStyle(
              color: ThemeColors.error,
            ),
          ),
          onTap: onDelete,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      avatar: Icon(icon, size: 14, color: color ?? ThemeColors.primary),
      label: Text(
        text,
        style: TextStyle(color: color ?? ThemeColors.textPrimary),
      ),
      backgroundColor:
          color?.withOpacity(0.1) ?? ThemeColors.primary.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}
