import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_conversation_model.dart';
import '../models/ai_message_model.dart';
import '../core/constants/firestore_paths.dart';

/// Manages AI conversations reading for analytics.
class AIProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AIConversationModel> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<AIConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalConversations => _conversations.length;

  Map<String, int> get modelDistribution {
    final map = <String, int>{};
    for (final c in _conversations) {
      map[c.model] = (map[c.model] ?? 0) + 1;
    }
    return map;
  }

  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.aiConversations)
          .orderBy('lastMessageAt', descending: true)
          .limit(100)
          .get();

      _conversations = snapshot.docs
          .map((d) => AIConversationModel.fromFirestore(d))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل محادثات AI: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get messages for a specific conversation.
  Future<List<AIMessageModel>> getConversationMessages(
      String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.aiConversations)
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      return snapshot.docs
          .map((d) => AIMessageModel.fromFirestore(d))
          .toList();
    } catch (e) {
      _error = 'فشل تحميل الرسائل: $e';
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
