/// Simple model representing a user fetched from Firestore `users/{uid}`.
class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  /// Admin roles that grant dashboard access.
  static const Set<String> adminRoles = {'admin', 'sub-admin'};

  /// Whether this user has administrative privileges.
  bool get isAdmin => adminRoles.contains(role);

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      // Default to 'student' (least privilege) if role is missing.
      role: data['role'] as String? ?? 'student',
    );
  }
}
