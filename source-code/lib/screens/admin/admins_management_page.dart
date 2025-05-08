import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/models/admin.dart';
import 'package:fatiel/screens/visitor/widget/custom_back_app_bar_widget.dart';
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
  String? _sortColumn;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _fetchAdmins();
  }

  Future<void> _fetchCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _fetchAdmins() async {
    try {
      setState(() {
        _isLoading = true;
      });

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
        _showErrorSnackBar(
            L10n.of(context).failedToLoadAdmins(error.toString()));
      }
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredAdmins = List.from(_admins);
    } else {
      _filteredAdmins = _admins
          .where((admin) =>
              admin.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting if active
    if (_sortColumn != null) {
      _sortData(_sortColumn!, _isAscending);
    }
  }

  void _sortData(String column, bool ascending) {
    setState(() {
      _sortColumn = column;
      _isAscending = ascending;

      _filteredAdmins.sort((a, b) {
        if (column == 'name') {
          return ascending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
        } else if (column == 'date') {
          return ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        }
        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        appBar: CustomBackAppBar(
          title: L10n.of(context).adminsManagement,
        ),
        body: RefreshIndicator(
          onRefresh: _fetchAdmins,
          color: ThemeColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildAdminsCard(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddAdminDialog(),
          backgroundColor: ThemeColors.primary,
          foregroundColor: ThemeColors.textOnPrimary,
          elevation: 4,
          child: const Icon(Iconsax.add),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L10n.of(context).administratorAccounts,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ThemeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context).manageAdminAccounts,
          style: const TextStyle(
            fontSize: 16,
            color: ThemeColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminsCard() {
    return Card(
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
            _buildTableHeader(),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: ThemeColors.primary,
                      ),
                    ),
                  )
                : _filteredAdmins.isEmpty
                    ? _buildEmptyState()
                    : _buildAdminsTable(),
            const SizedBox(height: 8),
            if (!_isLoading && _filteredAdmins.isNotEmpty) _buildTableFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Iconsax.search_normal,
                color: ThemeColors.primary,
                size: 20,
              ),
              hintText: L10n.of(context).searchByName,
              hintStyle: const TextStyle(
                color: ThemeColors.textSecondary,
              ),
              filled: true,
              fillColor: ThemeColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
        Material(
          borderRadius: BorderRadius.circular(12),
          color: ThemeColors.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _searchQuery = '';
                _applySearch();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeColors.border,
                  width: 1,
                ),
              ),
              child: const Icon(
                Iconsax.filter_remove,
                color: ThemeColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          borderRadius: BorderRadius.circular(12),
          color: ThemeColors.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _fetchAdmins();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeColors.border,
                  width: 1,
                ),
              ),
              child: const Icon(
                Iconsax.refresh,
                color: ThemeColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.primaryTransparent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isEmpty ? Iconsax.user_minus : Iconsax.search_status,
              size: 48,
              color: ThemeColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty
                ? L10n.of(context).noAdminAccounts
                : L10n.of(context).noAdminsMatch,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isEmpty
                ? L10n.of(context).createNewAdmin
                : L10n.of(context).adjustSearchCriteria,
            style: const TextStyle(
              fontSize: 16,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () {
                _showAddAdminDialog();
              },
              icon: const Icon(Iconsax.add),
              label: Text(L10n.of(context).addAdmin),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: ThemeColors.textOnPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminsTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.border),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: ThemeColors.border.withOpacity(0.6),
          dataTableTheme: DataTableTheme.of(context).copyWith(
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
              fontSize: 15,
            ),
            dataTextStyle: const TextStyle(
              color: ThemeColors.textPrimary,
              fontSize: 14,
            ),
            headingRowHeight: 56,
            dataRowHeight: 60,
            dividerThickness: 1,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              ThemeColors.primaryTransparent.withOpacity(0.15),
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return ThemeColors.primaryTransparent.withOpacity(0.08);
                }
                if (states.contains(MaterialState.hovered)) {
                  return ThemeColors.primaryTransparent.withOpacity(0.05);
                }

                // Use index for alternating row colors
                final index = _filteredAdmins.indexWhere((admin) {
                  for (final state in states) {
                    if (_filteredAdmins.indexOf(admin) == state.index) {
                      return true;
                    }
                  }
                  return false;
                });

                return index.isEven
                    ? Colors.transparent
                    : ThemeColors.surface.withOpacity(0.4);
              },
            ),
            border: TableBorder(
              horizontalInside: BorderSide(
                width: 1,
                color: ThemeColors.border.withOpacity(0.6),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            columnSpacing: 24,
            horizontalMargin: 16,
            showCheckboxColumn: false,
            sortColumnIndex:
                _sortColumn == 'name' ? 0 : (_sortColumn == 'date' ? 1 : null),
            sortAscending: _isAscending,
            columns: [
              DataColumn(
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    L10n.of(context).name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onSort: (columnIndex, ascending) {
                  _sortData('name', ascending);
                },
              ),
              DataColumn(
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    L10n.of(context).createdAt,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onSort: (columnIndex, ascending) {
                  _sortData('date', ascending);
                },
              ),
              DataColumn(
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    L10n.of(context).actions,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            rows: _filteredAdmins.map((admin) {
              return DataRow(
                onSelectChanged: (selected) {
                  if (selected == true) {
                    _showAdminDetailsDialog(admin);
                  }
                },
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              ThemeColors.primary.withOpacity(0.15),
                          child: Text(
                            admin.name.isNotEmpty
                                ? admin.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: ThemeColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          admin.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeColors.border.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${admin.createdAt.day}/${admin.createdAt.month}/${admin.createdAt.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: ThemeColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Iconsax.edit,
                          color: ThemeColors.primary,
                          tooltip: L10n.of(context).editAdmin,
                          onPressed: () => _showEditAdminDialog(admin),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Iconsax.trash,
                          color: ThemeColors.error,
                          tooltip: L10n.of(context).deleteAdmin,
                          onPressed: () => _showDeleteConfirmation(admin),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Text(
            '${L10n.of(context).totalAdmins}: ${_filteredAdmins.length}',
            style: const TextStyle(
              color: ThemeColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_filteredAdmins.length != _admins.length)
            Text(
              '${L10n.of(context).filtered}: ${_filteredAdmins.length} ${L10n.of(context).ofWord} ${_admins.length}',
              style: const TextStyle(
                color: ThemeColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  void _showAdminDetailsDialog(Admin admin) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ThemeColors.primary.withOpacity(0.15),
                child: Text(
                  admin.name.isNotEmpty ? admin.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: ThemeColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin.name,
                      style: const TextStyle(
                        color: ThemeColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${L10n.of(context).adminId}: ${admin.id.substring(0, 8)}...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem(
                icon: Iconsax.calendar,
                title: L10n.of(context).createdAt,
                value:
                    '${admin.createdAt.day}/${admin.createdAt.month}/${admin.createdAt.year}',
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditAdminDialog(admin);
                    },
                    icon: const Icon(
                      Iconsax.edit,
                      size: 18,
                    ),
                    label: Text(L10n.of(context).edit),
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeColors.primary,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.primaryTransparent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ThemeColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10n.of(context).addNewAdmin,
                    style: const TextStyle(
                      color: ThemeColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L10n.of(context).createNewAdminAccount,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
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
                      _buildFormField(
                        controller: nameController,
                        label: L10n.of(context).fullName,
                        icon: Iconsax.user,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return L10n.of(context).pleaseEnterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: emailController,
                        label: L10n.of(context).emailAddress,
                        icon: Iconsax.sms,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return L10n.of(context).pleaseEnterEmail;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return L10n.of(context).pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: L10n.of(context).password,
                          labelStyle: const TextStyle(
                            color: ThemeColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Iconsax.lock,
                            color: ThemeColors.primary,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Iconsax.eye
                                  : Iconsax.eye_slash,
                              color: ThemeColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ThemeColors.error,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return L10n.of(context).pleaseEnterPassword;
                          }
                          if (value.length < 6) {
                            return L10n.of(context).passwordLengthError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        L10n.of(context).passwordMustBeLong,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    L10n.of(context).cancel,
                    style: const TextStyle(
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
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(L10n.of(context).addAdmin),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: ThemeColors.textSecondary,
        ),
        prefixIcon: Icon(
          icon,
          color: ThemeColors.primary,
          size: 20,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThemeColors.error,
            width: 1,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _addAdmin(String name, String email, String password) async {
    try {
      // Show loading indicator
      _showLoadingDialog(L10n.of(context).creatingAdminAccount);

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
      _showSuccessSnackBar(L10n.of(context).adminCreatedSuccessfully);
    } catch (e) {
      if (context.mounted) {
        // Hide loading indicator
        Navigator.of(context, rootNavigator: true).pop();

        // Show error message
        _showErrorSnackBar('${L10n.of(context).error}: ${e.toString()}');
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L10n.of(context).editAdmin,
                style: const TextStyle(
                  color: ThemeColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L10n.of(context).updateAdminInfo,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.primaryTransparent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThemeColors.primaryTransparent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: ThemeColors.primary.withOpacity(0.2),
                          child: Text(
                            admin.name.isNotEmpty
                                ? admin.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: ThemeColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                L10n.of(context).adminId,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ThemeColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                admin.id.length > 10
                                    ? '${admin.id.substring(0, 10)}...'
                                    : admin.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFormField(
                    controller: nameController,
                    label: L10n.of(context).fullName,
                    icon: Iconsax.user,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return L10n.of(context).pleaseEnterName;
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
              child: Text(
                L10n.of(context).cancel,
                style: const TextStyle(
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
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(L10n.of(context).saveChanges),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Admin admin) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            L10n.of(context).deleteAdminAccount,
            style: const TextStyle(
              color: ThemeColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L10n.of(context).confirmDeleteAdmin,
                style: const TextStyle(
                  fontSize: 16,
                  color: ThemeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: ThemeColors.error.withOpacity(0.1),
                      child: Text(
                        admin.name.isNotEmpty
                            ? admin.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: ThemeColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${L10n.of(context).createdOn} ${admin.createdAt.day}/${admin.createdAt.month}/${admin.createdAt.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                L10n.of(context).actionCannotBeUndone,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                L10n.of(context).cancel,
                style: const TextStyle(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAdmin(Admin admin, String newName) async {
    try {
      // Show loading indicator
      _showLoadingDialog(L10n.of(context).updatingAdminAccount);

      // Update admin in Firestore
      await AdminService.updateAdminName(
        adminId: admin.id,
        newName: newName,
      );

      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Refresh the admins list
      await _fetchAdmins();

      // Show success message
      _showSuccessSnackBar(L10n.of(context).adminUpdatedSuccessfully);
    } catch (e) {
      if (context.mounted) {
        // Hide loading indicator
        Navigator.of(context, rootNavigator: true).pop();

        // Show error message
        _showErrorSnackBar('${L10n.of(context).error}: ${e.toString()}');
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Iconsax.tick_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: ThemeColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Iconsax.danger,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: ThemeColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
