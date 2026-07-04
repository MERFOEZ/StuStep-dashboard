import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'video' or 'pdf'
  final int order;
  final String? videoUrl;
  final String? pdfUrl;
  final int durationSeconds;
  final String? relatedChatGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    this.videoUrl,
    this.pdfUrl,
    required this.durationSeconds,
    this.relatedChatGroupId,
    this.createdAt,
    this.updatedAt,
  });

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? order,
    String? videoUrl,
    String? pdfUrl,
    int? durationSeconds,
    String? relatedChatGroupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      order: order ?? this.order,
      videoUrl: videoUrl ?? this.videoUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      relatedChatGroupId: relatedChatGroupId ?? this.relatedChatGroupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory LessonModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    DateTime? parsedUpdatedAt;
    if (map['updatedAt'] != null) {
      if (map['updatedAt'] is Timestamp) {
        parsedUpdatedAt = (map['updatedAt'] as Timestamp).toDate();
      } else if (map['updatedAt'] is String) {
        parsedUpdatedAt = DateTime.tryParse(map['updatedAt']);
      }
    }

    return LessonModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'video',
      order: map['order'] ?? 0,
      videoUrl: map['videoUrl'],
      pdfUrl: map['pdfUrl'],
      durationSeconds: map['durationSeconds'] ?? 0,
      relatedChatGroupId: map['relatedChatGroupId'],
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'order': order,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'durationSeconds': durationSeconds,
      'relatedChatGroupId': relatedChatGroupId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
