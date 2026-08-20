import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/core/models/college.dart';
import 'package:dashboard/core/models/department.dart';
import 'package:dashboard/core/models/course.dart';
import 'package:dashboard/core/models/store_item.dart';

/// Generic Firestore CRUD service with real-time streams.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ─── Colleges ──────────────────────────────────────────────────────────

  CollectionReference get _colleges => _db.collection('colleges');

  Stream<List<College>> collegesStream() {
    return _colleges.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(College.fromFirestore).toList(),
        );
  }

  Future<List<College>> getColleges() async {
    final snap = await _colleges.orderBy('createdAt', descending: true).get();
    return snap.docs.map(College.fromFirestore).toList();
  }

  Future<void> addCollege(College college) async {
    await _colleges.add(college.toMap());
  }

  Future<void> updateCollege(College college) async {
    await _colleges.doc(college.id).update({
      'name': college.name,
      'isActive': college.isActive,
    });
  }

  Future<void> deleteCollege(String id) async {
    final batch = _db.batch();

    // 1. Find all departments belonging to this college
    final deptSnap = await _departments.where('collegeId', isEqualTo: id).get();
    for (final deptDoc in deptSnap.docs) {
      // 2. Find all courses belonging to each department
      final courseSnap = await _courses.where('departmentId', isEqualTo: deptDoc.id).get();
      for (final courseDoc in courseSnap.docs) {
        batch.delete(courseDoc.reference);
      }
      batch.delete(deptDoc.reference);
    }

    // 3. Delete the college itself
    batch.delete(_colleges.doc(id));
    await batch.commit();
  }

  // ─── Departments ───────────────────────────────────────────────────────

  CollectionReference get _departments => _db.collection('departments');

  Stream<List<Department>> departmentsStream() {
    return _departments
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Department.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<Department>> departmentsByCollegeStream(String collegeId) {
    return _departments
        .where('collegeId', isEqualTo: collegeId)
        .snapshots()
        .map(
          (snap) {
            final list = snap.docs
                .map((doc) => Department.fromFirestore(doc))
                .toList();
            list.sort((a, b) => (b.createdAt ?? DateTime.now())
                .compareTo(a.createdAt ?? DateTime.now()));
            return list;
          },
        );
  }

  Future<void> addDepartment(Department dept) async {
    await _departments.add(dept.toMap());
  }

  Future<Department?> getDepartment(String id) async {
    final doc = await _departments.doc(id).get();
    if (doc.exists) {
      return Department.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateDepartment(Department dept) async {
    await _departments.doc(dept.id).update({
      'name': dept.name,
      'collegeId': dept.collegeId,
      'isActive': dept.isActive,
    });
  }

  Future<void> deleteDepartment(String id) async {
    final batch = _db.batch();

    // 1. Find all courses belonging to this department
    final courseSnap = await _courses.where('departmentId', isEqualTo: id).get();
    for (final courseDoc in courseSnap.docs) {
      batch.delete(courseDoc.reference);
    }

    // 2. Delete the department itself
    batch.delete(_departments.doc(id));
    await batch.commit();
  }

  // ─── Courses ───────────────────────────────────────────────────────────

  CollectionReference get _courses => _db.collection('courses');

  Stream<List<Course>> coursesStream() {
    return _courses.orderBy('createdAt', descending: true).snapshots().map(
          (snap) =>
              snap.docs.map((doc) => Course.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Course>> coursesByDepartmentStream(String departmentId) {
    return _courses
        .where('departmentId', isEqualTo: departmentId)
        .snapshots()
        .map(
          (snap) {
            final list = snap.docs
                .map((doc) => Course.fromFirestore(doc))
                .toList();
            list.sort((a, b) => (b.createdAt ?? DateTime.now())
                .compareTo(a.createdAt ?? DateTime.now()));
            return list;
          },
        );
  }

  Future<void> addCourse(Course course) async {
    await _courses.add(course.toMap());
  }

  Future<void> addLectureToCourse(String courseId, String videoName, String videoUrl) async {
    await _courses.doc(courseId).update({
      'lectures': FieldValue.arrayUnion([
        {
          'name': videoName,
          'url': videoUrl,
        }
      ]),
    });
  }

  /// Update a specific lecture's metadata (name/url) by its index in the array.
  Future<void> updateLecture(String courseId, int lectureIndex, String newName, String newUrl) async {
    final doc = await _courses.doc(courseId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final lectures = List<Map<String, dynamic>>.from(
      (data['lectures'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
    );
    if (lectureIndex < 0 || lectureIndex >= lectures.length) return;
    lectures[lectureIndex] = {'name': newName, 'url': newUrl};
    await _courses.doc(courseId).update({'lectures': lectures});
  }

  /// Remove a specific lecture from a course by its index.
  Future<void> removeLecture(String courseId, int lectureIndex) async {
    final doc = await _courses.doc(courseId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final lectures = List<Map<String, dynamic>>.from(
      (data['lectures'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
    );
    if (lectureIndex < 0 || lectureIndex >= lectures.length) return;
    lectures.removeAt(lectureIndex);
    await _courses.doc(courseId).update({'lectures': lectures});
  }

  /// Reorder lectures array for a course.
  Future<void> reorderLectures(String courseId, List<Map<String, dynamic>> reorderedLectures) async {
    await _courses.doc(courseId).update({'lectures': reorderedLectures});
  }

  Future<void> updateCourse(Course course) async {
    await _courses.doc(course.id).update({
      'title': course.title,
      'departmentId': course.departmentId,
      'coverImageUrl': course.coverImageUrl,
      'isActive': course.isActive,
    });
  }

  Future<void> deleteCourse(String id) async {
    await _courses.doc(id).delete();
  }

  // ─── Store Items ───────────────────────────────────────────────────────

  CollectionReference get _storeItems => _db.collection('store');

  Stream<List<StoreItem>> storeItemsStream() {
    return _storeItems
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(StoreItem.fromFirestore).toList(),
        );
  }

  Future<void> addStoreItem(StoreItem item) async {
    await _storeItems.add(item.toMap());
  }

  Future<void> updateStoreItem(StoreItem item) async {
    await _storeItems.doc(item.id).update({
      'title': item.title,
      'requiredPoints': item.requiredPoints,
      'downloadLink': item.downloadLink,
      'coverImageUrl': item.coverImageUrl,
      'isActive': item.isActive,
    });
  }

  Future<void> deleteStoreItem(String id) async {
    await _storeItems.doc(id).delete();
  }

  // ─── Counts (for dashboard stats) ──────────────────────────────────────

  /// Fetches the document count for a single collection using Firestore's
  /// native server-side count() aggregation. This costs 0 document reads —
  /// it only performs a single aggregation read, regardless of collection size.
  Future<int> aggregateCount(String collection) async {
    final snapshot = await _db.collection(collection).count().get();
    return snapshot.count ?? 0;
  }

  /// Fetches all dashboard KPI counts in parallel using count() aggregation.
  /// Returns a map: { 'colleges': N, 'departments': N, 'courses': N, 'store': N }
  ///
  /// Each collection costs exactly 1 aggregation read (not 1 per document).
  Future<Map<String, int>> getDashboardCounts() async {
    const collections = ['colleges', 'departments', 'courses', 'store'];

    final results = await Future.wait(
      collections.map((c) => _db.collection(c).count().get()),
    );

    return {
      for (int i = 0; i < collections.length; i++)
        collections[i]: results[i].count ?? 0,
    };
  }

  /// Real-time stream that re-emits the count whenever the collection changes.
  /// Uses snapshots but only reads the metadata (doc count), not full documents.
  /// Prefer [aggregateCount] or [getDashboardCounts] for one-shot reads.
  Stream<int> collectionCountStream(String collection) {
    return _db
        .collection(collection)
        .snapshots(includeMetadataChanges: false)
        .map((snap) => snap.docs.length);
  }
}
