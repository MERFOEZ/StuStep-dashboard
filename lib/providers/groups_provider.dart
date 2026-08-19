import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';
import '../core/constants/firestore_paths.dart';

/// Manages groups and messages for admin moderation.
class GroupsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String? _error;

  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalMembers =>
      _groups.fold<int>(0, (total, g) => total + g.memberCount);

  Future<void> fetchGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.groups)
          .orderBy('lastMessageTime', descending: true)
          .get();

      _groups =
          snapshot.docs.map((d) => GroupModel.fromFirestore(d)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل المجموعات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new group.
  Future<void> createGroup({
    required String name,
    required String description,
    required String category,
  }) async {
    try {
      await _firestore.collection(FirestorePaths.groups).add({
        'name': name,
        'description': description,
        'category': category,
        'members': <String>[],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      await fetchGroups();
    } catch (e) {
      _error = 'فشل إنشاء المجموعة: $e';
      notifyListeners();
    }
  }

  /// Delete a group and all its messages.
  Future<void> deleteGroup(String groupId) async {
    try {
      // Delete messages subcollection first
      final messages = await _firestore
          .collection(FirestorePaths.groups)
          .doc(groupId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(
          _firestore.collection(FirestorePaths.groups).doc(groupId));
      await batch.commit();

      _groups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (e) {
      _error = 'فشل حذف المجموعة: $e';
      notifyListeners();
    }
  }

  /// Get messages stream for a group.
  Stream<List<MessageModel>> getMessages(String groupId) {
    return _firestore
        .collection(FirestorePaths.groups)
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromFirestore(d)).toList());
  }

  /// Delete a specific message.
  Future<void> deleteMessage(String groupId, String messageId) async {
    try {
      await _firestore
          .collection(FirestorePaths.groups)
          .doc(groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      _error = 'فشل حذف الرسالة: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
