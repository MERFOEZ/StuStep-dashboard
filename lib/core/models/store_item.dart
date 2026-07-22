import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for a store/reward item.
class StoreItem {
  final String id;
  final String title;
  final int requiredPoints;
  final String downloadLink;
  final String coverImageUrl;
  final bool isActive;
  final DateTime? createdAt;

  const StoreItem({
    required this.id,
    required this.title,
    this.requiredPoints = 0,
    this.downloadLink = '',
    this.coverImageUrl = '',
    this.isActive = true,
    this.createdAt,
  });

  factory StoreItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoreItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      requiredPoints: (data['requiredPoints'] as num?)?.toInt() ?? 0,
      downloadLink: data['downloadLink'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'requiredPoints': requiredPoints,
        'downloadLink': downloadLink,
        'coverImageUrl': coverImageUrl,
        'isActive': isActive,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };
}
