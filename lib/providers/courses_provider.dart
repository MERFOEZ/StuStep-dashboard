import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../core/constants/firestore_paths.dart';

/// Manages courses CRUD with Firestore.
class CoursesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;
  String _filterCategory = '';
  String _filterStatus = ''; // '' | 'published' | 'draft'

  List<CourseModel> get courses {
    var result = _courses;
    if (_filterCategory.isNotEmpty) {
      result = result.where((c) => c.categoryId == _filterCategory).toList();
    }
    if (_filterStatus == 'published') {
      result = result.where((c) => c.isPublished).toList();
    } else if (_filterStatus == 'draft') {
      result = result.where((c) => !c.isPublished).toList();
    }
    return result;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _courses.length;
  int get publishedCount => _courses.where((c) => c.isPublished).length;
  int get draftCount => _courses.where((c) => !c.isPublished).length;

  /// Fetch all courses.
  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.courses)
          .orderBy('createdAt', descending: true)
          .get();

      _courses =
          snapshot.docs.map((d) => CourseModel.fromFirestore(d)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل الكورسات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set category filter.
  void filterByCategory(String categoryId) {
    _filterCategory = categoryId;
    notifyListeners();
  }

  /// Set status filter.
  void filterByStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Create a new course.
  Future<String?> createCourse(CourseModel course) async {
    try {
      final docRef = await _firestore
          .collection(FirestorePaths.courses)
          .add(course.toFirestore());

      final newCourse = CourseModel(
        id: docRef.id,
        title: course.title,
        titleEn: course.titleEn,
        instructor: course.instructor,
        categoryId: course.categoryId,
        description: course.description,
        iconName: course.iconName,
        gradientStart: course.gradientStart,
        gradientEnd: course.gradientEnd,
        rating: course.rating,
        studentsCount: course.studentsCount,
        durationMinutes: course.durationMinutes,
        lessons: course.lessons,
        isPublished: course.isPublished,
      );

      _courses.insert(0, newCourse);
      notifyListeners();
      return docRef.id;
    } catch (e) {
      _error = 'فشل إنشاء الكورس: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing course.
  Future<void> updateCourse(CourseModel course) async {
    try {
      await _firestore
          .collection(FirestorePaths.courses)
          .doc(course.id)
          .update(course.toFirestore());

      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = course;
        notifyListeners();
      }
    } catch (e) {
      _error = 'فشل تحديث الكورس: $e';
      notifyListeners();
    }
  }

  /// Delete a course.
  Future<void> deleteCourse(String id) async {
    try {
      await _firestore.collection(FirestorePaths.courses).doc(id).delete();
      _courses.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'فشل حذف الكورس: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
