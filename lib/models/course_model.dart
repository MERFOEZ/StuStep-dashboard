import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_model.dart';

/// Represents a course document from the `courses` collection.
class CourseModel {
  final String id;
  final String title;
  final String titleEn;
  final String instructor;
  final String categoryId;
  final String description;
  final String iconName;
  final String gradientStart;
  final String gradientEnd;
  final double rating;
  final int studentsCount;
  final int durationMinutes;
  final List<LessonModel> lessons;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel({
    required this.id,
    required this.title,
    this.titleEn = '',
    required this.instructor,
    required this.categoryId,
    this.description = '',
    this.iconName = 'play_circle',
    this.gradientStart = '#6C5CE7',
    this.gradientEnd = '#00CEFF',
    this.rating = 0.0,
    this.studentsCount = 0,
    this.durationMinutes = 0,
    this.lessons = const [],
    this.isPublished = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleEn: data['titleEn'] ?? '',
      instructor: data['instructor'] ?? '',
      categoryId: data['categoryId'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? 'play_circle',
      gradientStart: data['gradientStart'] ?? '#6C5CE7',
      gradientEnd: data['gradientEnd'] ?? '#00CEFF',
      rating: (data['rating'] ?? 0.0).toDouble(),
      studentsCount: data['studentsCount'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 0,
      lessons: (data['lessons'] as List<dynamic>?)
              ?.map((l) => LessonModel.fromMap(l as Map<String, dynamic>))
              .toList() ??
          [],
      isPublished: data['isPublished'] ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleEn': titleEn,
      'instructor': instructor,
      'categoryId': categoryId,
      'description': description,
      'iconName': iconName,
      'gradientStart': gradientStart,
      'gradientEnd': gradientEnd,
      'rating': rating,
      'studentsCount': studentsCount,
      'durationMinutes': durationMinutes,
      'lessons': lessons.map((l) => l.toMap()).toList(),
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Calculate total duration from all lessons.
  int get totalDuration =>
      lessons.fold(0, (total, l) => total + l.durationMinutes);

  CourseModel copyWith({
    String? title,
    String? titleEn,
    String? instructor,
    String? categoryId,
    String? description,
    String? iconName,
    String? gradientStart,
    String? gradientEnd,
    double? rating,
    int? studentsCount,
    int? durationMinutes,
    List<LessonModel>? lessons,
    bool? isPublished,
  }) {
    return CourseModel(
      id: id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      instructor: instructor ?? this.instructor,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      rating: rating ?? this.rating,
      studentsCount: studentsCount ?? this.studentsCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lessons: lessons ?? this.lessons,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
