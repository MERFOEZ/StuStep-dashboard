import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for a college.
class College {
  final String id;
  final String name;
  final bool isActive;
  final DateTime? createdAt;

  const College({
    required this.id,
    required this.name,
    this.isActive = true,
    this.createdAt,
  });

  factory College.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return College(
      id: doc.id,
      name: data['name'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'isActive': isActive,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };
}
