import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _demoUsers = [
    {
      'id': 'usr_101',
      'name': 'Ibtisam Ali',
      'email': 'ibtisam@laptopharbor.com',
      'phone': '+92 300 1234567',
      'role': 'admin',
      'ordersCount': 12,
    },
    {
      'id': 'usr_102',
      'name': 'Muhammad Ahmed',
      'email': 'ahmed.m@gmail.com',
      'phone': '+92 321 7654321',
      'role': 'user',
      'ordersCount': 3,
    },
    {
      'id': 'usr_103',
      'name': 'Fatima Zahra',
      'email': 'fatima.z@outlook.com',
      'phone': '+92 333 9876543',
      'role': 'user',
      'ordersCount': 1,
    },
    {
      'id': 'usr_104',
      'name': 'Zaid Hassan',
      'email': 'zaid.hassan@yahoo.com',
      'phone': '+92 345 5551234',
      'role': 'user',
      'ordersCount': 5,
    },
    {
      'id': 'usr_105',
      'name': 'Admin Super',
      'email': 'admin@laptopharbor.com',
      'phone': '+92 300 0000000',
      'role': 'admin',
      'ordersCount': 0,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDeleteUser(String userId, String userName) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete User "$userName"?',
            style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this user account? Their saved cart and wishlist will also be removed.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .delete();
              } catch (_) {}
              setState(() {
                _demoUsers.removeWhere((u) => u['id'] == userId);
              });
              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User "$userName" deleted'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleUserRole(String userId, String currentRole) {
    final newRole = currentRole.toLowerCase() == 'admin' ? 'user' : 'admin';
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'role': newRole});
    } catch (_) {}
    setState(() {
      final idx = _demoUsers.indexWhere((u) => u['id'] == userId);
      if (idx != -1) {
        _demoUsers[idx]['role'] = newRole;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Role changed to "$newRole"'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _demoUsers.where((u) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Users (120)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
                    child: Text('No users match search',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final u = filteredUsers[index];
                      final isAdmin =
                          (u['role'] ?? '').toString().toLowerCase() == 'admin';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isAdmin
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.surfaceLight,
                              child: Icon(
                                isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person_rounded,
                                color: isAdmin
                                    ? AppColors.primaryLight
                                    : Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        u['name'] ?? 'User',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isAdmin
                                                  ? AppColors.primary
                                                  : AppColors.accent)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAdmin ? 'ADMIN' : 'USER',
                                          style: TextStyle(
                                            color: isAdmin
                                                ? AppColors.primaryLight
                                                : AppColors.accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    u['email'] ?? '',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Phone: ${u['phone']} • Orders: ${u['ordersCount']}',
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              color: AppColors.surface,
                              onSelected: (val) {
                                if (val == 'toggle_role') {
                                  _toggleUserRole(u['id'], u['role']);
                                } else if (val == 'delete') {
                                  _confirmDeleteUser(u['id'], u['name']);
                                }
                              },
                              itemBuilder: (popCtx) => [
                                PopupMenuItem(
                                  value: 'toggle_role',
                                  child: Text(
                                      isAdmin ? 'Revoke Admin' : 'Make Admin',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete User',
                                      style:
                                          TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
