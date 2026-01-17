class StockItem {
  final String id;
  final String name;
  final String imageUrl;
  final double? price;
  final String? quantity;
  final String? description;
  final DateTime? createdAt;
  final String? userId;

  const StockItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.price,
    this.quantity,
    this.description,
    this.createdAt,
    this.userId,
  });

  StockItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    String? quantity,
    String? description,
    DateTime? createdAt,
    String? userId,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      quantity: json['quantity'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userId: json['user_id'] as String?,
    );
  }

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
}
