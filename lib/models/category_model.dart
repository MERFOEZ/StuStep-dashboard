import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a dynamic course category from the `categories` collection.
class CategoryModel {
  final String id;
  final String name;
  final String nameEn;
  final String icon; // Material icon name, e.g. "computer"
  final String colorHex; // e.g. "#00C853"
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameEn,
    this.icon = 'category',
    this.colorHex = '#6C5CE7',
    this.sortOrder = 0,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameEn: data['nameEn'] ?? '',
      icon: data['icon'] ?? 'category',
      colorHex: data['colorHex'] ?? '#6C5CE7',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameEn': nameEn,
      'icon': icon,
      'colorHex': colorHex,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CategoryModel copyWith({
    String? name,
    String? nameEn,
    String? icon,
    String? colorHex,
    int? sortOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
