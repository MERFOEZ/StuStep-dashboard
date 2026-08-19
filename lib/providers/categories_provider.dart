import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../core/constants/firestore_paths.dart';

/// Manages categories CRUD with Firestore.
class CategoriesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get activeCategories =>
      _categories.where((c) => c.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all categories, ordered by sortOrder.
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.categories)
          .orderBy('sortOrder')
          .get();

      _categories =
          snapshot.docs.map((d) => CategoryModel.fromFirestore(d)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل الفئات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new category.
  Future<CategoryModel?> createCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore
          .collection(FirestorePaths.categories)
          .add(category.toFirestore());

      final newCategory = CategoryModel(
        id: docRef.id,
        name: category.name,
        nameEn: category.nameEn,
        icon: category.icon,
        colorHex: category.colorHex,
        sortOrder: _categories.length,
        isActive: category.isActive,
        createdAt: category.createdAt,
      );

      _categories.add(newCategory);
      notifyListeners();
      return newCategory;
    } catch (e) {
      _error = 'فشل إنشاء الفئة: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing category.
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection(FirestorePaths.categories)
          .doc(category.id)
          .update(category.toFirestore());

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = 'فشل تحديث الفئة: $e';
      notifyListeners();
    }
  }

  /// Delete a category.
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore
          .collection(FirestorePaths.categories)
          .doc(id)
          .delete();

      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'فشل حذف الفئة: $e';
      notifyListeners();
    }
  }

  /// Toggle active status.
  Future<void> toggleActive(String id) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final updated =
        _categories[index].copyWith(isActive: !_categories[index].isActive);
    await updateCategory(updated);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
