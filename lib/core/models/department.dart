import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for a department within a college.
class Department {
  final String id;
  final String name;
  final String collegeId;
  final bool isActive;
  final DateTime? createdAt;

  /// Resolved college name (not persisted, populated at read-time).
  final String collegeName;

  const Department({
    required this.id,
    required this.name,
    required this.collegeId,
    this.isActive = true,
    this.createdAt,
    this.collegeName = '',
  });

  factory Department.fromFirestore(DocumentSnapshot doc,
      {String collegeName = ''}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Department(
      id: doc.id,
      name: data['name'] as String? ?? '',
      collegeId: data['collegeId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      collegeName: collegeName,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'collegeId': collegeId,
        'isActive': isActive,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };
}
