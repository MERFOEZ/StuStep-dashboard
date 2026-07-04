import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String instructorId;
  final String instructorName;
  final String coverImageUrl;
  final int totalDuration; // in minutes
  final int totalLessons;
  final String? relatedChatGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.instructorId,
    required this.instructorName,
    required this.coverImageUrl,
    required this.totalDuration,
    required this.totalLessons,
    this.relatedChatGroupId,
    this.createdAt,
    this.updatedAt,
  });

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? instructorId,
    String? instructorName,
    String? coverImageUrl,
    int? totalDuration,
    int? totalLessons,
    String? relatedChatGroupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      totalDuration: totalDuration ?? this.totalDuration,
      totalLessons: totalLessons ?? this.totalLessons,
      relatedChatGroupId: relatedChatGroupId ?? this.relatedChatGroupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String documentId) {
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

    return CourseModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      totalDuration: map['totalDuration'] ?? 0,
      totalLessons: map['totalLessons'] ?? 0,
      relatedChatGroupId: map['relatedChatGroupId'],
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'coverImageUrl': coverImageUrl,
      'totalDuration': totalDuration,
      'totalLessons': totalLessons,
      'relatedChatGroupId': relatedChatGroupId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
