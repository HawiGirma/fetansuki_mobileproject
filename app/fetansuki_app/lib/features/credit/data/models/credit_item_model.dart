import '../../domain/entities/credit_item.dart';

class CreditItemModel extends CreditItem {
  const CreditItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    super.status,
    super.imageUrl,
  });

  factory CreditItemModel.fromJson(Map<String, dynamic> json) {
    return CreditItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'No Name',
      quantity: json['amount']?.toString() ?? '0',
      status: json['status'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': quantity,
      'status': status,
      'image_url': imageUrl,
    };
  }

  factory CreditItemModel.fromEntity(CreditItem entity) {
    return CreditItemModel(
      id: entity.id,
      name: entity.name,
      quantity: entity.quantity,
      status: entity.status,
      imageUrl: entity.imageUrl,
    );
  }
}
