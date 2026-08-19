import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user document from the `users` collection.
/// Extends the original student app model with `role` and `isDisabled`.
class AdminUserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' | 'student'
  final bool isDisabled;
  final DateTime createdAt;

  AdminUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'student',
    this.isDisabled = false,
    required this.createdAt,
  });

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      isDisabled: data['isDisabled'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isDisabled': isDisabled,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AdminUserModel copyWith({
    String? name,
    String? email,
    String? role,
    bool? isDisabled,
  }) {
    return AdminUserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isDisabled: isDisabled ?? this.isDisabled,
      createdAt: createdAt,
    );
  }
}
