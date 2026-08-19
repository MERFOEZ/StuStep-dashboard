import 'package:uuid/uuid.dart';

/// Represents a single lesson within a course.
/// Stored as an embedded map inside the course document.
class LessonModel {
  final String id;
  final String title;
  final int durationMinutes;
  final String? videoUrl;
  final String? archiveIdentifier;
  final int sortOrder;

  LessonModel({
    String? id,
    required this.title,
    this.durationMinutes = 0,
    this.videoUrl,
    this.archiveIdentifier,
    this.sortOrder = 0,
  }) : id = id ?? const Uuid().v4();

  factory LessonModel.fromMap(Map<String, dynamic> data) {
    return LessonModel(
      id: data['id'] ?? const Uuid().v4(),
      title: data['title'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      videoUrl: data['videoUrl'],
      archiveIdentifier: data['archiveIdentifier'],
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'durationMinutes': durationMinutes,
      'videoUrl': videoUrl,
      'archiveIdentifier': archiveIdentifier,
      'sortOrder': sortOrder,
    };
  }

  LessonModel copyWith({
    String? title,
    int? durationMinutes,
    String? videoUrl,
    String? archiveIdentifier,
    int? sortOrder,
  }) {
    return LessonModel(
      id: id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      videoUrl: videoUrl ?? this.videoUrl,
      archiveIdentifier: archiveIdentifier ?? this.archiveIdentifier,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
