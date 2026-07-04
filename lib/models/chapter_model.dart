import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterModel {
  final String id;
  final String title;
  final int order;
  final DateTime? createdAt;

  ChapterModel({
    required this.id,
    required this.title,
    required this.order,
    this.createdAt,
  });

  ChapterModel copyWith({
    String? id,
    String? title,
    int? order,
    DateTime? createdAt,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    return ChapterModel(
      id: documentId,
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'order': order,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
