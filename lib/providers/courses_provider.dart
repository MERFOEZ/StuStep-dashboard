import 'dart:async';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/chapter_model.dart';
import '../models/lesson_model.dart';
import '../services/chunked_upload_service.dart';

class CoursesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChunkedUploadService _uploadService = ChunkedUploadService();

  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  List<ChapterModel> _chapters = []; // for selected course
  final Map<String, List<LessonModel>> _lessons = {}; // chapterId -> lessons
  LessonModel? _selectedLesson;

  bool _isLoading = false;
  String? _errorMessage;
  bool _useMock = false;

  // Active Upload States (fileId -> state)
  final Map<String, double> _uploadProgress = {};
  final Map<String, double> _uploadSpeed = {};
  final Map<String, String> _uploadStatus = {};
  final Map<String, String?> _uploadError = {};
  final Map<String, String?> _uploadResultUrl = {};

  // Getters
  List<CourseModel> get courses => _courses;
  CourseModel? get selectedCourse => _selectedCourse;
  List<ChapterModel> get chapters => _chapters;
  LessonModel? get selectedLesson => _selectedLesson;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get useMock => _useMock;

  // Upload getters
  double getProgress(String fileId) => _uploadProgress[fileId] ?? 0.0;
  double getSpeed(String fileId) => _uploadSpeed[fileId] ?? 0.0;
  String getStatus(String fileId) => _uploadStatus[fileId] ?? 'idle';
  String? getError(String fileId) => _uploadError[fileId];
  String? getResultUrl(String fileId) => _uploadResultUrl[fileId];

  // Prepopulated Mock Data
  final List<CourseModel> _mockCourses = [
    CourseModel(
      id: 'c1',
      title: 'Advanced Calculus 101',
      description: 'Master limits, derivatives, integrals, multivariable calculus, and spatial vectors.',
      category: 'Mathematics',
      instructorId: 'u1',
      instructorName: 'Dr. Sarah Jenkins',
      coverImageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&q=80&w=300',
      totalDuration: 180,
      totalLessons: 6,
      relatedChatGroupId: 'g1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CourseModel(
      id: 'c2',
      title: 'Introduction to Computer Science',
      description: 'Introduction to algorithms, data structures, computation theory, and software development concepts.',
      category: 'Computer Science',
      instructorId: 'u2',
      instructorName: 'Eng. Ahmad Qasim',
      coverImageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&q=80&w=300',
      totalDuration: 240,
      totalLessons: 8,
      relatedChatGroupId: 'g2',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<ChapterModel> _mockChapters = [
    ChapterModel(id: 'ch1', title: 'Chapter 1: Limits & Continuity', order: 0),
    ChapterModel(id: 'ch2', title: 'Chapter 2: Infinite Series', order: 1),
    ChapterModel(id: 'ch3', title: 'Chapter 3: Computability & Turing Machines', order: 0),
    ChapterModel(id: 'ch4', title: 'Chapter 4: OOP Concepts', order: 1),
  ];

  final Map<String, List<LessonModel>> _mockLessons = {
    'ch1': [
      LessonModel(
        id: 'l1',
        title: 'Introduction to Limits',
        description: 'Understand the concept of a limit graphically and numerically.',
        type: 'video',
        order: 0,
        videoUrl: 'https://private-cloud.stustep.edu/videos/mock_limits_intro.mp4',
        durationSeconds: 1200,
        relatedChatGroupId: 'g1',
      ),
      LessonModel(
        id: 'l2',
        title: 'Limit Theorems PDF Notes',
        description: 'Reference sheet of theorems and formulas.',
        type: 'pdf',
        order: 1,
        pdfUrl: 'https://private-cloud.stustep.edu/files/mock_limits_theorems.pdf',
        durationSeconds: 0,
        relatedChatGroupId: 'g1',
      ),
    ],
    'ch2': [
      LessonModel(
        id: 'l3',
        title: 'Taylor and Maclaurin Series',
        description: 'Learn how to expand functions using power series.',
        type: 'video',
        order: 0,
        videoUrl: 'https://private-cloud.stustep.edu/videos/mock_taylor_series.mp4',
        durationSeconds: 2400,
        relatedChatGroupId: 'g1',
      ),
    ],
    'ch3': [
      LessonModel(
        id: 'l4',
        title: 'Introduction to Automata Theory',
        description: 'Finite state machines, regular expressions, and turing machine proofs.',
        type: 'video',
        order: 0,
        videoUrl: 'https://private-cloud.stustep.edu/videos/mock_automata.mp4',
        durationSeconds: 3000,
        relatedChatGroupId: 'g2',
      ),
    ],
    'ch4': [
      LessonModel(
        id: 'l5',
        title: 'Polymorphism and Interfaces',
        description: 'Comprehensive guide to abstraction, dynamic binding, and inheritance.',
        type: 'video',
        order: 0,
        videoUrl: 'https://private-cloud.stustep.edu/videos/mock_polymorphism.mp4',
        durationSeconds: 1800,
        relatedChatGroupId: 'g2',
      ),
    ],
  };

  CoursesProvider() {
    loadCourses();
  }

  void toggleMockMode(bool enabled) {
    _useMock = enabled;
    _selectedCourse = null;
    _selectedLesson = null;
    _chapters = [];
    _lessons.clear();
    loadCourses();
  }

  // Set active selections
  void selectCourse(CourseModel? course) {
    _selectedCourse = course;
    _selectedLesson = null;
    _chapters = [];
    if (course != null) {
      loadChapters(course.id);
    } else {
      notifyListeners();
    }
  }

  void selectLesson(LessonModel? lesson) {
    _selectedLesson = lesson;
    notifyListeners();
  }

  // ==========================================
  // COURSE CRUD
  // ==========================================

  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        _courses = List.from(_mockCourses);
      } else {
        final QuerySnapshot query = await _firestore.collection('courses').orderBy('createdAt', descending: true).get();
        _courses = query.docs.map((doc) => CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCourse(CourseModel course) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMock) {
        final newCourse = course.copyWith(
          id: 'mock_c_${DateTime.now().millisecondsSinceEpoch}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _mockCourses.insert(0, newCourse);
        _courses = List.from(_mockCourses);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final docRef = await _firestore.collection('courses').add(course.toMap()..['createdAt'] = FieldValue.serverTimestamp());
        final newCourse = course.copyWith(id: docRef.id);
        _courses.insert(0, newCourse);
        await _firestore.collection('activity_logs').add({
          'action': 'course_created',
          'actorName': 'Admin Portal',
          'targetName': course.title,
          'details': course.category,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(CourseModel course) async {
    try {
      if (_useMock) {
        final index = _mockCourses.indexWhere((c) => c.id == course.id);
        if (index != -1) {
          _mockCourses[index] = course.copyWith(updatedAt: DateTime.now());
          _courses = List.from(_mockCourses);
          if (_selectedCourse?.id == course.id) {
            _selectedCourse = _mockCourses[index];
          }
          notifyListeners();
          return true;
        }
        return false;
      } else {
        await _firestore.collection('courses').doc(course.id).update(course.toMap());
        final index = _courses.indexWhere((c) => c.id == course.id);
        if (index != -1) {
          _courses[index] = course;
          if (_selectedCourse?.id == course.id) {
            _selectedCourse = course;
          }
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      if (_useMock) {
        _mockCourses.removeWhere((c) => c.id == courseId);
        _courses = List.from(_mockCourses);
        if (_selectedCourse?.id == courseId) {
          _selectedCourse = null;
          _selectedLesson = null;
        }
        notifyListeners();
        return true;
      } else {
        final deleted = _courses.firstWhere((c) => c.id == courseId, orElse: () => CourseModel(id: '', title: 'Unknown', description: '', category: '', instructorId: '', instructorName: '', coverImageUrl: '', totalDuration: 0, totalLessons: 0));
        await _firestore.collection('courses').doc(courseId).delete();
        _courses.removeWhere((c) => c.id == courseId);
        if (_selectedCourse?.id == courseId) {
          _selectedCourse = null;
          _selectedLesson = null;
        }
        await _firestore.collection('activity_logs').add({
          'action': 'course_deleted',
          'actorName': 'Admin Portal',
          'targetName': deleted.title,
          'details': '',
          'timestamp': FieldValue.serverTimestamp(),
        });
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // CHAPTER CRUD
  // ==========================================

  Future<void> loadChapters(String courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 300));
        // course c1 maps ch1, ch2. course c2 maps ch3, ch4. others are empty at start.
        if (courseId == 'c1') {
          _chapters = _mockChapters.where((ch) => ch.id == 'ch1' || ch.id == 'ch2').toList();
        } else if (courseId == 'c2') {
          _chapters = _mockChapters.where((ch) => ch.id == 'ch3' || ch.id == 'ch4').toList();
        } else {
          _chapters = _mockChapters.where((ch) => ch.id.startsWith('mock_ch_') && ch.id.contains(courseId)).toList();
        }
        _chapters.sort((a, b) => a.order.compareTo(b.order));

        // Preload mock lessons as well
        for (var ch in _chapters) {
          _lessons[ch.id] = List.from(_mockLessons[ch.id] ?? []);
          _lessons[ch.id]!.sort((a, b) => a.order.compareTo(b.order));
        }
      } else {
        final query = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .orderBy('order')
            .get();
        
        _chapters = query.docs.map((doc) => ChapterModel.fromMap(doc.data(), doc.id)).toList();

        for (var ch in _chapters) {
          final lQuery = await _firestore
              .collection('courses')
              .doc(courseId)
              .collection('chapters')
              .doc(ch.id)
              .collection('lessons')
              .orderBy('order')
              .get();
          _lessons[ch.id] = lQuery.docs
              .map((doc) => LessonModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createChapter(String courseId, String title) async {
    try {
      final nextOrder = _chapters.length;
      if (_useMock) {
        final newChapter = ChapterModel(
          id: 'mock_ch_${courseId}_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          order: nextOrder,
          createdAt: DateTime.now(),
        );
        _mockChapters.add(newChapter);
        _chapters.add(newChapter);
        _lessons[newChapter.id] = [];
        notifyListeners();
        return true;
      } else {
        final data = {
          'title': title,
          'order': nextOrder,
          'createdAt': Timestamp.now(),
        };
        final docRef = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .add(data);
        final newChapter = ChapterModel(
          id: docRef.id,
          title: title,
          order: nextOrder,
          createdAt: DateTime.now(),
        );
        _chapters.add(newChapter);
        _lessons[newChapter.id] = [];
        await _firestore.collection('activity_logs').add({
          'action': 'chapter_created',
          'actorName': 'Admin Portal',
          'targetName': _selectedCourse?.title ?? 'Course',
          'details': title,
          'timestamp': FieldValue.serverTimestamp(),
        });
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateChapter(String courseId, ChapterModel chapter) async {
    try {
      if (_useMock) {
        final idx = _mockChapters.indexWhere((c) => c.id == chapter.id);
        if (idx != -1) {
          _mockChapters[idx] = chapter;
        }
        final idx2 = _chapters.indexWhere((c) => c.id == chapter.id);
        if (idx2 != -1) {
          _chapters[idx2] = chapter;
        }
        notifyListeners();
        return true;
      } else {
        await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .doc(chapter.id)
            .update(chapter.toMap());
        
        final idx = _chapters.indexWhere((c) => c.id == chapter.id);
        if (idx != -1) {
          _chapters[idx] = chapter;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteChapter(String courseId, String chapterId) async {
    try {
      if (_useMock) {
        _mockChapters.removeWhere((c) => c.id == chapterId);
        _chapters.removeWhere((c) => c.id == chapterId);
        _lessons.remove(chapterId);
        if (_selectedLesson != null && !_lessons.values.any((list) => list.contains(_selectedLesson))) {
          _selectedLesson = null;
        }
        notifyListeners();
        return true;
      } else {
        await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .doc(chapterId)
            .delete();
        
        _chapters.removeWhere((c) => c.id == chapterId);
        _lessons.remove(chapterId);
        if (_selectedLesson != null && !_lessons.values.any((list) => list.contains(_selectedLesson))) {
          _selectedLesson = null;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reorderChapters(String courseId, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _chapters.removeAt(oldIndex);
    _chapters.insert(newIndex, item);

    // Re-index all orders
    for (int i = 0; i < _chapters.length; i++) {
      _chapters[i] = _chapters[i].copyWith(order: i);
      
      // Update DB async without blocking the UI
      if (_useMock) {
        final mIdx = _mockChapters.indexWhere((ch) => ch.id == _chapters[i].id);
        if (mIdx != -1) {
          _mockChapters[mIdx] = _mockChapters[mIdx].copyWith(order: i);
        }
      } else {
        _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .doc(_chapters[i].id)
            .update({'order': i});
      }
    }
    notifyListeners();
  }

  // ==========================================
  // LESSON CRUD
  // ==========================================

  List<LessonModel> getLessonsForChapter(String chapterId) {
    return _lessons[chapterId] ?? [];
  }

  Future<bool> createLesson({
    required String courseId,
    required String chapterId,
    required String title,
    required String type,
  }) async {
    try {
      final list = _lessons[chapterId] ?? [];
      final nextOrder = list.length;

      if (_useMock) {
        final newLesson = LessonModel(
          id: 'mock_les_${chapterId}_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: '',
          type: type,
          order: nextOrder,
          durationSeconds: type == 'video' ? 600 : 0,
          createdAt: DateTime.now(),
        );

        if (_mockLessons[chapterId] == null) {
          _mockLessons[chapterId] = [];
        }
        _mockLessons[chapterId]!.add(newLesson);
        list.add(newLesson);
        _lessons[chapterId] = list;
        notifyListeners();
        return true;
      } else {
        final lesson = LessonModel(
          id: '',
          title: title,
          description: '',
          type: type,
          order: nextOrder,
          durationSeconds: type == 'video' ? 600 : 0,
          createdAt: DateTime.now(),
        );

        final docRef = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .doc(chapterId)
            .collection('lessons')
            .add(lesson.toMap());
        
        final newLesson = lesson.copyWith(id: docRef.id);
        list.add(newLesson);
        _lessons[chapterId] = list;
        await _firestore.collection('activity_logs').add({
          'action': 'lesson_created',
          'actorName': 'Admin Portal',
          'targetName': title,
          'details': type.toUpperCase(),
          'timestamp': FieldValue.serverTimestamp(),
        });
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLesson(String courseId, String chapterId, LessonModel lesson) async {
    try {
      if (_useMock) {
        final list = _mockLessons[chapterId] ?? [];
        final idx = list.indexWhere((l) => l.id == lesson.id);
        if (idx != -1) {
          list[idx] = lesson.copyWith(updatedAt: DateTime.now());
        }
        _mockLessons[chapterId] = list;

        final localList = _lessons[chapterId] ?? [];
        final idx2 = localList.indexWhere((l) => l.id == lesson.id);
        if (idx2 != -1) {
          localList[idx2] = lesson;
        }
        _lessons[chapterId] = localList;

        if (_selectedLesson?.id == lesson.id) {
          _selectedLesson = lesson;
        }
        notifyListeners();
        return true;
      } else {
        await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .doc(chapterId)
            .collection('lessons')
            .doc(lesson.id)
            .update(lesson.toMap());

        final localList = _lessons[chapterId] ?? [];
        final idx = localList.indexWhere((l) => l.id == lesson.id);
        if (idx != -1) {
          localList[idx] = lesson;
        }
        _lessons[chapterId] = localList;

        if (_selectedLesson?.id == lesson.id) {
          _selectedLesson = lesson;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLesson(String courseId, String chapterId, String lessonId) async {
    try {
      if (_useMock) {
        if (_mockLessons[chapterId] != null) {
          _mockLessons[chapterId]!.removeWhere((l) => l.id == lessonId);
        }
        if (_lessons[chapterId] != null) {
          _lessons[chapterId]!.removeWhere((l) => l.id == lessonId);
        }
        if (_selectedLesson?.id == lessonId) {
          _selectedLesson = null;
        }
        notifyListeners();
        return true;
      } else {
        await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .doc(chapterId)
            .collection('lessons')
            .doc(lessonId)
            .delete();
        
        if (_lessons[chapterId] != null) {
          _lessons[chapterId]!.removeWhere((l) => l.id == lessonId);
        }
        if (_selectedLesson?.id == lessonId) {
          _selectedLesson = null;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reorderLessons(String courseId, String chapterId, int oldIndex, int newIndex) {
    final list = _lessons[chapterId];
    if (list == null) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Re-index orders
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);

      if (_useMock) {
        final mList = _mockLessons[chapterId];
        if (mList != null) {
          final idx = mList.indexWhere((l) => l.id == list[i].id);
          if (idx != -1) {
            mList[idx] = mList[idx].copyWith(order: i);
          }
        }
      } else {
        _firestore
            .collection('courses')
            .doc(courseId)
            .collection('chapters')
            .doc(chapterId)
            .collection('lessons')
            .doc(list[i].id)
            .update({'order': i});
      }
    }
    notifyListeners();
  }

  // ==========================================
  // FILE UPLOAD AND PROGRESS MANAGEMENT
  // ==========================================

  Future<void> uploadLessonFile({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required XFile file,
    required String fileType, // 'video' or 'pdf'
  }) async {
    final fileId = '${lessonId}_$fileType';
    
    _uploadProgress[fileId] = 0.0;
    _uploadSpeed[fileId] = 0.0;
    _uploadStatus[fileId] = 'uploading';
    _uploadError[fileId] = null;
    _uploadResultUrl[fileId] = null;
    notifyListeners();

    final uploadUrl = _useMock
        ? 'https://mock-upload.stustep.edu/upload'
        : 'https://private-cloud.stustep.edu/upload';

    try {
      final finalUrl = await _uploadService.upload(
        fileId: fileId,
        file: file,
        uploadUrl: uploadUrl,
        isMock: _useMock,
        onProgress: (info) {
          _uploadProgress[fileId] = info.progress;
          _uploadSpeed[fileId] = info.speedMBs;
          notifyListeners();
        },
        onStatusChanged: (status, err) {
          _uploadStatus[fileId] = status;
          _uploadError[fileId] = err;
          notifyListeners();
        },
      );

      if (finalUrl != null) {
        _uploadResultUrl[fileId] = finalUrl;
        
        // Save the resulting URL to the database/state
        final currentLesson = _lessons[chapterId]?.firstWhere((l) => l.id == lessonId);
        if (currentLesson != null) {
          LessonModel updated;
          if (fileType == 'video') {
            updated = currentLesson.copyWith(videoUrl: finalUrl);
          } else {
            updated = currentLesson.copyWith(pdfUrl: finalUrl);
          }
          await updateLesson(courseId, chapterId, updated);
        }
      }
    } catch (e) {
      _uploadStatus[fileId] = 'error';
      _uploadError[fileId] = e.toString();
      notifyListeners();
    }
  }

  void pauseUpload(String fileId) {
    _uploadService.pause(fileId);
    _uploadStatus[fileId] = 'paused';
    notifyListeners();
  }

  void resumeUpload(String fileId) {
    _uploadService.resume(fileId);
    _uploadStatus[fileId] = 'uploading';
    notifyListeners();
  }

  void cancelUpload(String fileId) {
    _uploadService.cancel(fileId);
    _uploadProgress.remove(fileId);
    _uploadSpeed.remove(fileId);
    _uploadStatus.remove(fileId);
    _uploadError.remove(fileId);
    _uploadResultUrl.remove(fileId);
    notifyListeners();
  }
}
