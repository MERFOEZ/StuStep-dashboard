import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/core/models/admin_user_model.dart';
import 'package:dashboard/core/constants/firestore_paths.dart';

/// Manages users CRUD operations.
class UsersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AdminUserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<AdminUserModel> get users {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _users.length;
  int get adminCount => _users.where((u) => u.role == 'admin').length;
  int get studentCount => _users.where((u) => u.role == 'student').length;
  int get disabledCount => _users.where((u) => u.isDisabled).length;

  /// Fetch all users from Firestore.
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.users)
          .orderBy('createdAt', descending: true)
          .get();

      _users =
          snapshot.docs.map((d) => AdminUserModel.fromFirestore(d)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل المستخدمين: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update search query.
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update a user's role.
  Future<void> updateRole(String uid, String newRole) async {
    try {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'role': newRole});

      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: newRole);
        notifyListeners();
      }
    } catch (e) {
      _error = 'فشل تحديث الدور: $e';
      notifyListeners();
    }
  }

  /// Toggle user disabled status.
  Future<void> toggleDisable(String uid) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index == -1) return;

    final newStatus = !_users[index].isDisabled;
    try {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({'isDisabled': newStatus});

      _users[index] = _users[index].copyWith(isDisabled: newStatus);
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحديث الحالة: $e';
      notifyListeners();
    }
  }

  /// Delete a user document from Firestore.
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(FirestorePaths.users).doc(uid).delete();
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
    } catch (e) {
      _error = 'فشل حذف المستخدم: $e';
      notifyListeners();
    }
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
