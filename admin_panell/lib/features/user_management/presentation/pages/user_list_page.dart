import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared_libs/lib/models/models.dart'; // Use main export
// Use main export

import '../../application/user_management_notifier.dart';

class UserListPage extends ConsumerStatefulWidget {
  // Changed to StatefulWidget
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  String _searchText = '';
  String _selectedRoleFilter = 'All'; // Default: Show all
  final _searchController = TextEditingController();

  // Define available roles (adjust as needed, match UserModel roles)
  final List<String> _roleOptions = [
    'All',
    'Admin',
    'Seller',
    'User',
    'Delivery'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userManagementProvider);

    // Show error SnackBar if needed
    ref.listen<AsyncValue<List<UserModel>>>(userManagementProvider,
        (previous, next) {
      if (next is AsyncError && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${next.error}'),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          _buildFilterAndSearchBar(),
          Expanded(
            child: userListState.when(
              data: (users) => _buildUserList(users, ref),
              error: (error, stackTrace) => Center(
                  child: Text(
                      'Failed to load users. Pull down to retry. Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      // Admin might not add users, users register themselves.
      // If needed, add FloatingActionButton for adding users.
      // floatingActionButton: FloatingActionButton(onPressed: ..., child: Icon(Icons.add)),
    );
  }

  Widget _buildFilterAndSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Role Filter Dropdown
          DropdownButton<String>(
            value: _selectedRoleFilter,
            hint: const Text("Filter by Role"),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRoleFilter = newValue ?? 'All';
              });
            },
            items: _roleOptions.map<DropdownMenuItem<String>>((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
          ),
          const SizedBox(width: 10),
          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, WidgetRef ref) {
    // Filter users locally
    final filteredUsers = users.where((user) {
      final roleMatch = _selectedRoleFilter == 'All' ||
          (user.role.toLowerCase() == _selectedRoleFilter.toLowerCase());
      final searchMatch = _searchText.isEmpty ||
          (user.name.toLowerCase().contains(_searchText)) ||
          (user.email.toLowerCase().contains(_searchText));
      return roleMatch && searchMatch;
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(child: Text('No users match the criteria.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(userManagementProvider.notifier).fetchUsers(),
      child: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return UserListItem(
            user: user,
            availableRoles: _roleOptions
                .where((r) => r != 'All')
                .toList(), // Pass actual roles
            onDelete: () {
              _showConfirmationDialog(context, ref, user.id, 'delete');
            },
            onEditRole: (newRole) {
              if (newRole != user.role) {
                _showConfirmationDialog(context, ref, user.id, 'editRole',
                    newRole: newRole, currentUser: user);
              }
            },
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, WidgetRef ref, String userId, String action,
      {String? newRole, UserModel? currentUser}) {
    String title;
    String content;
    VoidCallback onConfirm;

    switch (action) {
      case 'delete':
        title = 'Confirm Deletion';
        content = 'Are you sure you want to delete this user?';
        onConfirm = () async {
          final success = await ref
              .read(userManagementProvider.notifier)
              .deleteUser(userId);
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Failed to delete user'),
                backgroundColor: Colors.red));
          }
        };
        break;
      case 'editRole':
        if (newRole == null || currentUser == null) return;
        title = 'Confirm Role Change';
        content = 'Change role for ${currentUser.name} to $newRole?';
        onConfirm = () async {
          final success = await ref
              .read(userManagementProvider.notifier)
              .editUser(currentUser.copyWith(
                  role: newRole)); // Assuming copyWith exists
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Failed to update role'),
                backgroundColor: Colors.red));
          }
        };
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    action == 'delete' ? Colors.red : Colors.green),
            onPressed: () {
              onConfirm();
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Confirm',
                style:
                    TextStyle(color: action == 'delete' ? Colors.white : null)),
          ),
        ],
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final UserModel user;
  final List<String> availableRoles;
  final Function(String) onEditRole;
  final VoidCallback onDelete;

  const UserListItem({
    Key? key,
    required this.user,
    required this.availableRoles,
    required this.onEditRole,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
        ),
        title: Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Role Dropdown
            DropdownButton<String>(
              value: user.role, // Current role
              icon: const Icon(Icons.edit, size: 18), // Use edit icon
              underline: Container(), // Hide underline
              items: availableRoles
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (String? newRole) {
                if (newRole != null) {
                  onEditRole(newRole);
                }
              },
            ),
            const SizedBox(width: 4),
            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
              tooltip: 'Delete User',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
