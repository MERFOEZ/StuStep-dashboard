import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime? timestamp;
  final String type; // 'text', 'image', 'file'

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.timestamp,
    required this.type,
  });

  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    String? type,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parsedTimestamp;
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        parsedTimestamp = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is String) {
        parsedTimestamp = DateTime.tryParse(map['timestamp']);
      }
    }

    return MessageModel(
      messageId: documentId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: parsedTimestamp,
      type: map['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'type': type,
    };
  }
}
