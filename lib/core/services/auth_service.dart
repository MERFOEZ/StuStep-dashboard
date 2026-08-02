import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dashboard/core/models/app_user.dart';

/// Wraps FirebaseAuth and Firestore role-check logic.
///
/// Follows the RBAC pattern: authenticate → check role → allow/deny.
/// Fails closed on any error (signs the user out).
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Current auth state stream.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user (nullable).
  User? get currentUser => _auth.currentUser;

  /// Sign in with email & password.
  /// Returns the [UserCredential] on success.
  /// Throws a user-friendly [String] message on failure.
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('=== FIREBASE_AUTH_ERROR_CODE: ${e.code} ===');
      print('=== FIREBASE_AUTH_ERROR_MESSAGE: ${e.message} ===');
      print('FIREBASE ERROR: ${e.code} - ${e.message}');
      throw _mapAuthException(e.code);
    } catch (e) {
      print('FIREBASE ERROR: UNKNOWN - $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check the user's role in Firestore `users/{uid}`.
  /// Returns an [AppUser] if the document exists.
  /// Defaults missing `role` to `'student'` (least privilege).
  Future<AppUser> checkUserRole(String uid) async {
    try {
      print('=== FIRESTORE_CHECK: Fetching document for UID: $uid ===');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        print('=== FIRESTORE_ERROR: User document missing or empty for UID: $uid ===');
        // No document → least privilege → will be denied by caller.
        return AppUser(
          uid: uid,
          email: _auth.currentUser?.email ?? '',
          name: '',
          role: 'student',
        );
      }

      return AppUser.fromFirestore(uid, doc.data()!);
    } catch (e) {
      print('=== FIRESTORE_EXCEPTION: Failed to check user role for UID: $uid - $e ===');
      print('FIREBASE ERROR: Failed to check user role - $e');
      // Fail closed: return non-admin so caller will sign out.
      return AppUser(
        uid: uid,
        email: _auth.currentUser?.email ?? '',
        name: '',
        role: 'student',
      );
    }
  }

  /// Maps FirebaseAuth error codes to user-friendly messages.
  String _mapAuthException(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-email':
        return 'Invalid email address format.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
