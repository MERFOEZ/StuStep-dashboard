import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';

/// Manages admin authentication state.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && _isAdmin;
  bool get isAdmin => _isAdmin;
  String? get error => _error;
  String get displayName => _user?.displayName ?? _user?.email ?? 'Admin';

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _isAdmin = await _authService.isAdmin(user.uid);
        if (!_isAdmin) {
          // Not an admin → sign out immediately
          await _authService.signOut();
          _user = null;
          _error = 'ليس لديك صلاحية الدخول إلى لوحة التحكم';
        }
      } else {
        _isAdmin = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Login with email/password then verify admin role.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user == null) {
        _error = 'فشل تسجيل الدخول';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final isAdmin = await _authService.isAdmin(user.uid);
      if (!isAdmin) {
        await _authService.signOut();
        _user = null;
        _isAdmin = false;
        _error = 'ليس لديك صلاحية الدخول إلى لوحة التحكم';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = user;
      _isAdmin = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _error = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (e.code == 'too-many-requests') {
        _error = 'محاولات كثيرة جداً. حاول لاحقاً';
      } else {
        _error = 'حدث خطأ: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'حدث خطأ غير متوقع';
      notifyListeners();
      return false;
    }
  }

  /// Logout.
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _isAdmin = false;
    _error = null;
    notifyListeners();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
