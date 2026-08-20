import 'package:cloud_firestore/cloud_firestore.dart';

/// Matches the existing MessageModel from the student app.
class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String text;
  final DateTime timestamp;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;
  final bool isUploading;
  final String? repliedToText;
  final String? repliedToSender;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.text,
    required this.timestamp,
    this.fileName,
    this.fileType,
    this.fileUrl,
    this.isUploading = false,
    this.repliedToText,
    this.repliedToSender,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      text: data['text'] ?? '',
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileName: data['fileName'],
      fileType: data['fileType'],
      fileUrl: data['fileUrl'],
      isUploading: data['isUploading'] ?? false,
      repliedToText: data['repliedToText'],
      repliedToSender: data['repliedToSender'],
    );
  }
}
