import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for a course within a department.
class Course {
  final String id;
  final String title;
  final String departmentId;
  final String coverImageUrl;
  final List<Map<String, dynamic>> lectures;
  final bool isActive;
  final DateTime? createdAt;

  /// Resolved department name (not persisted).
  final String departmentName;

  const Course({
    required this.id,
    required this.title,
    required this.departmentId,
    this.coverImageUrl = '',
    this.lectures = const [],
    this.isActive = true,
    this.createdAt,
    this.departmentName = '',
  });

  factory Course.fromFirestore(DocumentSnapshot doc,
      {String departmentName = ''}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Course(
      id: doc.id,
      title: data['title'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      lectures: (data['lectures'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      departmentName: departmentName,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'departmentId': departmentId,
        'coverImageUrl': coverImageUrl,
        'lectures': lectures,
        'isActive': isActive,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };
}
