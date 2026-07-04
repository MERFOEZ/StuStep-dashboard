import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'All';
  String _searchQuery = '';

  // Local state for mock users (so we can edit/delete them in simulation mode and see changes live!)
  List<UserModel> _mockUsersList = [
    UserModel(uid: 'u1', name: 'Dr. Sarah Jenkins', email: 'sarah.j@stustep.edu', role: 'teacher', status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 30))),
    UserModel(uid: 'u2', name: 'Eng. Ahmad Qasim', email: 'ahmad.q@stustep.edu', role: 'teacher', status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 25))),
    UserModel(uid: 'u3', name: 'Hussain Ali', email: 'hussain.a@stustep.org', role: 'student', status: 'suspended', createdAt: DateTime.now().subtract(const Duration(days: 15))),
    UserModel(uid: 'u4', name: 'Fatima Al-Sayed', email: 'fatima.s@stustep.org', role: 'student', status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 12))),
    UserModel(uid: 'u5', name: 'Omar Farooq', email: 'omar.f@stustep.com', role: 'admin', status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 45))),
    UserModel(uid: 'u6', name: 'Ali Reda', email: 'ali.r@stustep.org', role: 'student', status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    UserModel(uid: 'u7', name: 'Lina Khalfan', email: 'lina.k@stustep.org', role: 'student', status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 2))),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditRoleDialog(UserModel user, String Function(String, String) t) {
    String tempRole = user.role;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(t('Modify Role: ${user.name}', 'تعديل صلاحية: ${user.name}'), style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Select new role:', 'اختر الصلاحية الجديدة:'), style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: tempRole,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    items: ['admin', 'teacher', 'student'].map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role == 'admin' ? t('ADMIN', 'مدير') : role == 'teacher' ? t('TEACHER', 'معلم') : t('STUDENT', 'طالب')),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          tempRole = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (authProvider.useMock) {
                      setState(() {
                        final idx = _mockUsersList.indexWhere((u) => u.uid == user.uid);
                        if (idx != -1) {
                          _mockUsersList[idx] = _mockUsersList[idx].copyWith(role: tempRole);
                        }
                      });
                    } else {
                      FirebaseFirestore.instance.collection('users').doc(user.uid).update({'role': tempRole});
                      FirebaseFirestore.instance.collection('activity_logs').add({
                        'action': 'role_changed',
                        'actorName': authProvider.currentUser?.name ?? 'Admin',
                        'targetName': user.name,
                        'details': tempRole,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                    }
                    Navigator.pop(context);
                    _showSuccessSnackBar(t('Role updated successfully.', 'تم تحديث الصلاحية بنجاح.'));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF)),
                  child: Text(t('Update', 'تحديث'), style: const TextStyle(color: Color(0xFF0F172A))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showToggleStatusDialog(UserModel user, String Function(String, String) t) {
    final nextStatus = user.status == 'active' ? 'suspended' : 'active';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            nextStatus == 'suspended' ? t('Suspend Account?', 'إيقاف الحساب؟') : t('Unsuspend Account?', 'تنشيط الحساب؟'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            t(
              'Are you sure you want to change the status of ${user.name} to ${nextStatus.toUpperCase()}?',
              'هل أنت متأكد من تغيير حالة حساب ${user.name} إلى ${nextStatus == 'active' ? 'نشط' : 'موقف'}؟',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.useMock) {
                  setState(() {
                    final idx = _mockUsersList.indexWhere((u) => u.uid == user.uid);
                    if (idx != -1) {
                      _mockUsersList[idx] = _mockUsersList[idx].copyWith(status: nextStatus);
                    }
                  });
                } else {
                  FirebaseFirestore.instance.collection('users').doc(user.uid).update({'status': nextStatus});
                  FirebaseFirestore.instance.collection('activity_logs').add({
                    'action': nextStatus == 'active' ? 'user_activated' : 'user_suspended',
                    'actorName': authProvider.currentUser?.name ?? 'Admin',
                    'targetName': user.name,
                    'details': nextStatus,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(context);
                _showSuccessSnackBar(
                  nextStatus == 'active'
                      ? t('User status changed to active.', 'تم تنشيط حساب المستخدم.')
                      : t('User status changed to suspended.', 'تم إيقاف حساب المستخدم.'),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: nextStatus == 'suspended' ? Colors.redAccent : const Color(0xFF2DD4BF),
              ),
              child: Text(
                nextStatus == 'suspended' ? t('Suspend', 'إيقاف') : t('Activate', 'تنشيط'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(UserModel user, String Function(String, String) t) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t('Delete User Account?', 'حذف حساب المستخدم؟'), style: const TextStyle(color: Colors.redAccent)),
          content: Text(
            t(
              'Are you sure you want to permanently delete the account of ${user.name} (${user.email})?\nThis action is irreversible.',
              'هل أنت متأكد من حذف حساب ${user.name} (${user.email}) بشكل نهائي؟\nلا يمكن التراجع عن هذا الإجراء.',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.useMock) {
                  setState(() {
                    _mockUsersList.removeWhere((u) => u.uid == user.uid);
                  });
                } else {
                  FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                  FirebaseFirestore.instance.collection('activity_logs').add({
                    'action': 'user_deleted',
                    'actorName': authProvider.currentUser?.name ?? 'Admin',
                    'targetName': user.name,
                    'details': user.email,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(context);
                _showSuccessSnackBar(t('User record deleted.', 'تم حذف سجل المستخدم.'));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text(t('Delete', 'حذف'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'All' || user.role.toLowerCase() == _selectedRoleFilter.toLowerCase();
      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accentColor = const Color(0xFF2DD4BF);
    final cardColor = const Color(0xFF1E293B);

    String t(String en, String ar) => authProvider.isArabic ? ar : en;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: t('Search by name or email...', 'بحث بالاسم أو البريد الإلكتروني...'),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor.withOpacity(0.4)),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRoleFilter,
                      dropdownColor: cardColor,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: ['All', 'Admin', 'Teacher', 'Student'].map((role) {
                        String label = role;
                        if (role == 'All') label = t('All Roles', 'جميع الصلاحيات');
                        if (role == 'Admin') label = t('Admin', 'المديرين');
                        if (role == 'Teacher') label = t('Teacher', 'المعلمين');
                        if (role == 'Student') label = t('Student', 'الطلاب');
                        
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedRoleFilter = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User list container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              clipBehavior: Clip.antiAlias,
              child: authProvider.useMock
                  ? _buildUserTable(_filterUsers(_mockUsersList), t)
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final users = snapshot.data!.docs.map((doc) {
                          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                        }).toList();

                        return _buildUserTable(_filterUsers(users), t);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(List<UserModel> users, String Function(String, String) t) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          t('No users found matching filters.', 'لم يتم العثور على مستخدمين يطابقون الفلاتر.'),
          style: const TextStyle(color: Colors.white30, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 700;

        return ListView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.02)),
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 64,
                  columns: [
                    DataColumn(label: Text(t('User Profile', 'ملف المستخدم'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(t('Email Address', 'البريد الإلكتروني'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(t('Role', 'الصلاحية'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(t('Status', 'الحالة'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    if (isDesktop) DataColumn(label: Text(t('Registered At', 'تاريخ التسجيل'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(t('Actions', 'الإجراءات'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                  rows: users.map((user) {
                    return DataRow(
                      cells: [
                        // Profile (Avatar + Name)
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: _getRoleColor(user.role).withOpacity(0.15),
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: TextStyle(color: _getRoleColor(user.role), fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        // Email
                        DataCell(Text(user.email, style: const TextStyle(color: Colors.white70))),
                        // Role tag
                        DataCell(_buildRoleTag(user.role, t)),
                        // Status
                        DataCell(Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: user.status == 'active' ? const Color(0xFF10B981) : Colors.redAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.status == 'active' ? t('ACTIVE', 'نشط') : t('SUSPENDED', 'موقف'),
                              style: TextStyle(
                                color: user.status == 'active' ? const Color(0xFF10B981) : Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )),
                        // Registered
                        if (isDesktop)
                          DataCell(Text(
                            user.createdAt != null
                                ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                                : 'N/A',
                            style: const TextStyle(color: Colors.white30),
                          )),
                        // Actions
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shield_rounded, size: 20),
                                color: Colors.blueAccent,
                                tooltip: t('Modify Role', 'تعديل الصلاحية'),
                                onPressed: () => _showEditRoleDialog(user, t),
                              ),
                              IconButton(
                                icon: Icon(user.status == 'active' ? Icons.block_flipped : Icons.check_circle_outline, size: 20),
                                color: user.status == 'active' ? Colors.orangeAccent : const Color(0xFF10B981),
                                tooltip: user.status == 'active' ? t('Suspend', 'إيقاف') : t('Activate', 'تنشيط'),
                                onPressed: () => _showToggleStatusDialog(user, t),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                color: Colors.redAccent,
                                tooltip: t('Delete Account', 'حذف الحساب'),
                                onPressed: () => _showDeleteUserDialog(user, t),
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
          ],
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent;
      case 'teacher':
        return Colors.blueAccent;
      default:
        return const Color(0xFF2DD4BF); // student
    }
  }

  Widget _buildRoleTag(String role, String Function(String, String) t) {
    final color = _getRoleColor(role);
    final roleLabel = role.toLowerCase() == 'admin'
        ? t('ADMIN', 'مدير')
        : role.toLowerCase() == 'teacher'
            ? t('TEACHER', 'معلم')
            : t('STUDENT', 'طالب');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        roleLabel,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
