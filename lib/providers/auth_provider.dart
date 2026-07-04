import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _useMock = false; // Disabled by default to run on live Firebase
  bool _isArabic = true;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get useMock => _useMock;
  bool get isArabic => _isArabic;

  void setArabic(bool value) {
    _isArabic = value;
    notifyListeners();
  }

  AuthProvider() {
    _checkInitialAuth();
  }

  void toggleMockMode(bool enabled) {
    _useMock = enabled;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _checkInitialAuth() async {
    if (_useMock) return;

    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _fetchAndVerifyUser(firebaseUser.uid);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useMock) {
        // Mock authentication for immediate local testing
        await Future.delayed(const Duration(seconds: 1)); // Simulate network lag
        if (email.trim() == 'admin@stustep.com' && password == 'admin123') {
          _currentUser = UserModel(
            uid: 'mock_admin_uid',
            name: 'Academic Admin',
            email: email.trim(),
            role: 'admin',
            createdAt: DateTime.now(),
            status: 'active',
          );
          _isLoading = false;
          notifyListeners();
          return true;
        } else if (email.trim() == 'student@stustep.com' && password == 'student123') {
          _isLoading = false;
          _errorMessage = 'Access Denied: Admin role required.';
          notifyListeners();
          return false;
        } else {
          _isLoading = false;
          _errorMessage = 'Invalid email or password.';
          notifyListeners();
          return false;
        }
      } else {
        // Firebase Authentication
        final UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (credential.user != null) {
          final isVerifiedAdmin = await _fetchAndVerifyUser(credential.user!.uid);
          _isLoading = false;
          notifyListeners();
          return isVerifiedAdmin;
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: [${e.code}] ${e.message}");
      _errorMessage = _getFirebaseFriendlyMessage(e.code);
      _currentUser = null;
    } catch (e) {
      debugPrint("General Auth Exception: ${e.toString()}");
      _errorMessage = e.toString();
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> _fetchAndVerifyUser(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        _errorMessage = 'User record not found in Firestore.';
        return false;
      }

      final data = doc.data() as Map<String, dynamic>;
      final user = UserModel.fromMap(data, uid);

      if (user.isAdmin) {
        _currentUser = user;
        return true;
      } else {
        await _auth.signOut();
        _errorMessage = 'Access Denied: Admin role required.';
        return false;
      }
    } catch (e) {
      await _auth.signOut();
      _errorMessage = 'Failed to verify admin status: ${e.toString()}';
      return false;
    }
  }

  Future<bool> updateProfile({required String name, required String? photoUrl, String? phoneNumber}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(name: name, photoUrl: photoUrl, phoneNumber: phoneNumber);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        if (_currentUser == null) return false;
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'name': name,
          'photoUrl': photoUrl,
          'phoneNumber': phoneNumber,
        });
        _currentUser = _currentUser!.copyWith(name: name, photoUrl: photoUrl, phoneNumber: phoneNumber);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({required String currentPassword, required String newPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 800));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final user = _auth.currentUser;
        if (user == null || user.email == null) return false;

        // Re-authenticate user to update password
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseFriendlyMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_useMock) {
        await _auth.signOut();
      }
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  String _getFirebaseFriendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}
