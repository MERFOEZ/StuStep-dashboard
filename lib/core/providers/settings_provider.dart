import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/core/models/admin_settings_model.dart';
import 'package:dashboard/core/constants/firestore_paths.dart';

/// Manages admin settings in a singleton Firestore document.
class SettingsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminSettingsModel _settings = AdminSettingsModel();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  AdminSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc =
          await _firestore.doc(FirestorePaths.globalSettings).get();
      if (doc.exists) {
        _settings = AdminSettingsModel.fromFirestore(doc);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل الإعدادات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(AdminSettingsModel settings) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore
          .doc(FirestorePaths.globalSettings)
          .set(settings.toFirestore());
      _settings = settings;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل حفظ الإعدادات: $e';
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
