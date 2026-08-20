import 'package:cloud_firestore/cloud_firestore.dart';

/// AI conversation header from the `ai_conversations` collection.
class AIConversationModel {
  final String id;
  final String userId;
  final String userName;
  final String model;
  final int messagesCount;
  final DateTime startedAt;
  final DateTime lastMessageAt;

  AIConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.model,
    this.messagesCount = 0,
    required this.startedAt,
    required this.lastMessageAt,
  });

  factory AIConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIConversationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      model: data['model'] ?? 'unknown',
      messagesCount: data['messagesCount'] ?? 0,
      startedAt:
          (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt:
          (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'model': model,
      'messagesCount': messagesCount,
      'startedAt': Timestamp.fromDate(startedAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    };
  }
}
