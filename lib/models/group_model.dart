import 'package:cloud_firestore/cloud_firestore.dart';

/// Matches the existing GroupModel from the student app.
class GroupModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> members;
  final String lastMessage;
  final DateTime? lastMessageTime;

  GroupModel({
    required this.id,
    required this.name,
    this.description = '',
    this.category = '',
    this.members = const [],
    this.lastMessage = '',
    this.lastMessageTime,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'members': members,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
    };
  }

  int get memberCount => members.length;
}
