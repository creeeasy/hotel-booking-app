import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/amenity.dart';
import 'package:fatiel/models/hotel.dart';
import 'package:fatiel/models/room.dart';
import 'package:fatiel/screens/hotel/widget/headline_text_widget.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/cloudinary/cloudinary_service.dart';
import 'package:fatiel/utils/value_listenable_builder2.dart';
import 'package:flutter/foundation.dart';
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
      return await Room.getHotelRoomsById(_hotelId);
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditRoomDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child:
            Icon(Iconsax.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRooms,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: HeadlineText(text: "Bookings"),
              floating: true,
              snap: true,
              elevation: 2,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: _buildRoomList(),
            ),
          ],
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
            child: Center(child: CircularProgressIndicator()),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.house,
              size: 64, color: colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No rooms available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddEditRoomDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load rooms',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshRooms,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
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
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      await _refreshRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update room: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _confirmDeleteRoom(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteRoom(room);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
        SnackBar(
          content: const Text('Room deleted successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      await _refreshRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete room: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showAddEditRoomDialog({Room? room}) {
    final isEditing = room != null;
    final formKey = GlobalKey<FormState>();
    final colorScheme = Theme.of(context).colorScheme;

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
          SnackBar(
            content: const Text('Image uploaded successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.error,
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
          SnackBar(
            content: const Text('Image removed successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.error,
          ),
        );
      } finally {
        isImageLoading.value = false;
      }
    }

    Widget _buildSectionHeader(IconData icon, String title) {
      return Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
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
                color: colorScheme.surfaceVariant,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Iconsax.gallery_slash,
                      color: colorScheme.onSurfaceVariant,
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
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.trash,
                    size: 16,
                    color: colorScheme.onErrorContainer,
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
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.add, color: colorScheme.primary, size: 24),
                const SizedBox(height: 4),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.primary,
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
            color: colorScheme.surfaceVariant,
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
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          )
                        : images.isEmpty
                            ? Center(
                                child: Text(
                                  'No photos added yet',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
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
        color: colorScheme.surfaceVariant,
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
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                      selected: isSelected,
                      avatar: Icon(
                        entry.value.icon,
                        size: 18,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
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
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceVariant,
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
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                        color: colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    isEditing ? 'Edit Room' : 'Add New Room',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Info Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSectionHeader(
                              Iconsax.info_circle, 'Basic Information'),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Room Name',
                              prefixIcon: const Icon(Iconsax.house),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: const Icon(Iconsax.note),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSectionHeader(
                              Iconsax.dollar_circle, 'Pricing & Availability'),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: priceController,
                            decoration: InputDecoration(
                              labelText: 'Price per night',
                              prefixIcon: const Icon(Iconsax.dollar_circle),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
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
                            decoration: InputDecoration(
                              labelText: 'Capacity',
                              prefixIcon: const Icon(Iconsax.profile_2user),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
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
                              title: Text(
                                'Available for booking',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              value: isAvailable,
                              onChanged: (value) => setState(() {
                                isAvailable = value;
                              }),
                              contentPadding: EdgeInsets.zero,
                              activeColor: colorScheme.primary,
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
                            'pricePerNight': double.parse(priceController.text),
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
                                backgroundColor: colorScheme.primary,
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
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
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
    );
  }

  void _showFilterOptions() {
    // Implement filter options as needed
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
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
                  _buildRoomImage(context: context),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${room.pricePerNight.toStringAsFixed(2)} per night',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
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
                                    '${room.capacity} ${room.capacity == 1 ? 'guest' : 'guests'}',
                                context: context),
                            _buildInfoChip(
                                icon: Iconsax.calendar,
                                text: room.availability.isAvailable
                                    ? 'Available'
                                    : 'Unavailable',
                                color: room.availability.isAvailable
                                    ? colorScheme.primary
                                    : colorScheme.error,
                                context: context),
                            if (room.images.isNotEmpty)
                              _buildInfoChip(
                                  icon: Iconsax.gallery,
                                  text:
                                      '${room.images.length} photo${room.images.length > 1 ? 's' : ''}',
                                  context: context),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildMoreOptionsButton(context: context),
                ],
              ),
              if (room.amenities.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  'Amenities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withOpacity(0.8),
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
                      label: Text(amenity),
                      avatar: Icon(iconData, size: 16),
                      backgroundColor: colorScheme.surfaceVariant,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                if (room.amenities.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${room.amenities.length - 3} more',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildRoomImage({required BuildContext context}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 100,
        color: colorScheme.surfaceVariant,
        child: room.images.isNotEmpty
            ? Image.network(
                room.images.first,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Iconsax.image,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Iconsax.image,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  Widget _buildMoreOptionsButton({required BuildContext context}) {
    return PopupMenuButton(
      icon: Icon(
        Iconsax.more,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Text('Edit'),
          onTap: onEdit,
        ),
        PopupMenuItem(
          child: Text(
            room.availability.isAvailable
                ? 'Mark Unavailable'
                : 'Mark Available',
          ),
          onTap: onToggleAvailability,
        ),
        PopupMenuItem(
          child: Text(
            'Delete',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
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
    required BuildContext context,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      avatar: Icon(icon, size: 14, color: color ?? theme.colorScheme.primary),
      label: Text(
        text,
        style: TextStyle(color: color ?? theme.colorScheme.onSurface),
      ),
      backgroundColor:
          color?.withOpacity(0.1) ?? theme.colorScheme.surfaceVariant,
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}
