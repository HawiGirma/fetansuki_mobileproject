import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/credit_item.dart';

class CreditItemModel extends CreditItem {
  const CreditItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    super.status,
    super.imageUrl,
    super.dueDate,
  });

  factory CreditItemModel.fromJson(Map<String, dynamic> json) {
    return CreditItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'No Name',
      quantity: json['amount']?.toString() ?? '0',
      status: json['status'] as String?,
      imageUrl: json['image_url'] as String?,
      dueDate: json['due_date'] != null 
          ? (json['due_date'] is Timestamp 
              ? (json['due_date'] as Timestamp).toDate() 
              : DateTime.parse(json['due_date'] as String))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': quantity,
      'status': status,
      'image_url': imageUrl,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    };
  }

  factory CreditItemModel.fromEntity(CreditItem entity) {
    return CreditItemModel(
      id: entity.id,
      name: entity.name,
      quantity: entity.quantity,
      status: entity.status,
      imageUrl: entity.imageUrl,
      dueDate: entity.dueDate,
    );
  }
}
