import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_paths.dart';

/// Handles admin authentication and role verification.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// Check if the given UID has admin role in Firestore.
  Future<bool> isAdmin(String uid) async {
    final doc =
        await _firestore.collection(FirestorePaths.users).doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data?['role'] == 'admin';
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
