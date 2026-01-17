import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockItemModel extends StockItem {
  const StockItemModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.price,
    super.quantity,
    super.description,
    super.createdAt,
    super.userId,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      quantity: json['quantity'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null 
          ? (json['created_at'] is Timestamp 
              ? (json['created_at'] as Timestamp).toDate() 
              : DateTime.parse(json['created_at'] as String))
          : null,
      userId: json['user_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'quantity': quantity,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'user_id': userId,
    };
  }

  factory StockItemModel.fromEntity(StockItem item) {
    return StockItemModel(
      id: item.id,
      name: item.name,
      imageUrl: item.imageUrl,
      price: item.price,
      quantity: item.quantity,
      description: item.description,
      createdAt: item.createdAt,
      userId: item.userId,
    );
  }

  StockItem toEntity() {
    return StockItem(
      id: id,
      name: name,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity,
      description: description,
      createdAt: createdAt,
      userId: userId,
    );
  }
}
