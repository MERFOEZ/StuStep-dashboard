import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime? createdAt;
  final List<String> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? academicYear;

  GroupModel({
    required this.groupId,
    required this.name,
    this.description,
    required this.createdBy,
    this.createdAt,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,
    this.academicYear,
  });

  GroupModel copyWith({
    String? groupId,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    List<String>? members,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? academicYear,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      academicYear: academicYear ?? this.academicYear,
    );
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    DateTime? parsedLastMessageTime;
    if (map['lastMessageTime'] != null) {
      if (map['lastMessageTime'] is Timestamp) {
        parsedLastMessageTime = (map['lastMessageTime'] as Timestamp).toDate();
      } else if (map['lastMessageTime'] is String) {
        parsedLastMessageTime = DateTime.tryParse(map['lastMessageTime']);
      }
    }

    List<String> parsedMembers = [];
    if (map['members'] != null) {
      parsedMembers = List<String>.from(map['members']);
    }

    return GroupModel(
      groupId: documentId,
      name: map['name'] ?? '',
      description: map['description'],
      createdBy: map['createdBy'] ?? '',
      createdAt: parsedCreatedAt,
      members: parsedMembers,
      lastMessage: map['lastMessage'],
      lastMessageTime: parsedLastMessageTime,
      academicYear: map['academicYear'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'members': members,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'academicYear': academicYear,
    };
  }
}
