import 'package:cloud_firestore/cloud_firestore.dart';

/// A single message within an AI conversation.
class AIMessageModel {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final String model;
  final bool hasAttachment;
  final DateTime timestamp;

  AIMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.model,
    this.hasAttachment = false,
    required this.timestamp,
  });

  factory AIMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIMessageModel(
      id: doc.id,
      role: data['role'] ?? 'user',
      content: data['content'] ?? '',
      model: data['model'] ?? '',
      hasAttachment: data['hasAttachment'] ?? false,
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'content': content,
      'model': model,
      'hasAttachment': hasAttachment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
