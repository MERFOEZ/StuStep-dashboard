import 'package:cloud_firestore/cloud_firestore.dart';

class StoreItemModel {
  final String itemId;
  final String name;
  final String? description;
  final int price; // points cost
  final String? imageUrl;
  final int quantity;
  final String? category;
  final bool isAvailable;
  final DateTime? createdAt;

  StoreItemModel({
    required this.itemId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.quantity,
    this.category,
    required this.isAvailable,
    this.createdAt,
  });

  StoreItemModel copyWith({
    String? itemId,
    String? name,
    String? description,
    int? price,
    String? imageUrl,
    int? quantity,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return StoreItemModel(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StoreItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parsedDate;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.tryParse(map['createdAt']);
      }
    }

    return StoreItemModel(
      itemId: documentId,
      name: map['name'] ?? '',
      description: map['description'],
      price: map['price'] ?? 0,
      imageUrl: map['imageUrl'],
      quantity: map['quantity'] ?? 0,
      category: map['category'],
      isAvailable: map['isAvailable'] ?? true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// Returns the expected Firestore field keys for validation
  static Set<String> get expectedKeys => {
    'name',
    'description',
    'price',
    'imageUrl',
    'quantity',
    'category',
    'isAvailable',
    'createdAt',
  };
}
