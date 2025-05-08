import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/models/admin.dart';
import 'package:fatiel/services/admin/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminsManagementPage extends StatefulWidget {
  const AdminsManagementPage({super.key});

  @override
  State<AdminsManagementPage> createState() => _AdminsManagementPageState();
}

class _AdminsManagementPageState extends State<AdminsManagementPage> {
  List<Admin> _admins = [];
  List<Admin> _filteredAdmins = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _fetchAdmins();
  }

  Future<void> _fetchCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
      });
    }
  }

  Future<void> _fetchAdmins() async {
    try {
      final adminsList = await AdminService.getAllAdmins();
      if (mounted) {
        setState(() {
          _admins = adminsList;
          _applySearch();
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load admins: $error');
      }
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredAdmins = List.from(_admins);
    } else {
      _filteredAdmins = _admins
          .where((admin) => admin.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ThemeColors.background, ThemeColors.surface],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: ThemeColors.shadow,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: ThemeColors.primary,
                              ),
                            )
                          : _buildAdminsTable(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAdmins,
        backgroundColor: ThemeColors.primary,
        foregroundColor: ThemeColors.textOnPrimary,
        child: const Icon(Iconsax.refresh),
        tooltip: 'Refresh',
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Admins Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddAdminDialog();
              },
              icon: const Icon(Iconsax.add),
              label: const Text('Add Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage all administrator accounts',
          style: TextStyle(
            fontSize: 16,
            color: ThemeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Iconsax.search_normal,
                color: ThemeColors.primary,
              ),
              hintText: 'Search by name...',
              hintStyle: const TextStyle(
                color: ThemeColors.textSecondary,
              ),
              filled: true,
              fillColor: ThemeColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ThemeColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ThemeColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applySearch();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: ThemeColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeColors.border,
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _applySearch();
              });
            },
            icon: const Icon(
              Iconsax.filter_remove,
              color: ThemeColors.primary,
            ),
            tooltip: 'Clear filter',
          ),
        ),
      ],
    );
  }

  Widget _buildAdminsTable() {
    if (_filteredAdmins.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(
              Iconsax.user_minus,
              size: 48,
              color: ThemeColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No admins found'
                  : 'No admins match your search',
              style: const TextStyle(
                fontSize: 18,
                color: ThemeColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            ThemeColors.primaryTransparent,
          ),
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: const [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Created At',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ),
          ],
          rows: _filteredAdmins.map((admin) {
            return DataRow(
              cells: [
                DataCell(Text(
                  admin.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                )),
                DataCell(Text(
                  '${admin.createdAt.day}/${admin.createdAt.month}/${admin.createdAt.year}',
                )),
                DataCell(
                  IconButton(
                    onPressed: () {
                      _showEditAdminDialog(admin);
                    },
                    icon: const Icon(
                      Iconsax.edit,
                      size: 20,
                      color: ThemeColors.primary,
                    ),
                    tooltip: 'Edit',
                    style: IconButton.styleFrom(
                      backgroundColor: ThemeColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add New Admin',
            style: TextStyle(
              color: ThemeColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Information',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(
                        color: ThemeColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.user,
                        color: ThemeColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ThemeColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(
                        color: ThemeColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.sms,
                        color: ThemeColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ThemeColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: ThemeColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.lock,
                        color: ThemeColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ThemeColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await _addAdmin(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Add Admin'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAdmin(String name, String email, String password) async {
    try {
      // Show loading indicator
      _showLoadingDialog('Creating admin account...');

      // Create user with Firebase Auth and add to Firestore
      await AdminService.createAdmin(
        email: email,
        name: name,
        password: password,
      );
      
      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Refresh the admins list
      await _fetchAdmins();
      
      // Show success message
      _showSuccessSnackBar('Admin account created successfully');
    } catch (e) {
      if (context.mounted) {
        // Hide loading indicator
        Navigator.of(context, rootNavigator: true).pop();

        // Show error message
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showEditAdminDialog(Admin admin) {
    final nameController = TextEditingController(text: admin.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Admin',
            style: TextStyle(
              color: ThemeColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Information',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(
                        color: ThemeColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.user,
                        color: ThemeColors.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ThemeColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await _updateAdmin(admin, nameController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAdmin(Admin admin, String name) async {
    try {
      _showLoadingDialog('Updating admin...');

      // Update admin name using service
      await AdminService.updateAdminName(
        adminId: admin.id,
        newName: name,
      );

      // Hide loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      // Refresh the admins list
      await _fetchAdmins();

      // Show success message
      _showSuccessSnackBar('Admin updated successfully');
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      // Show error message
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(
                color: ThemeColors.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}