import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sale extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final int quantity;
  final String buyerAddress;
  final DateTime timestamp;

  const Sale({
    required this.id,
    required this.productId,
    required this.userId,
    required this.quantity,
    required this.buyerAddress,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, productId, userId, quantity, buyerAddress, timestamp];

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'user_id': userId,
    'quantity': quantity,
    'buyer_address': buyerAddress,
    'timestamp': timestamp.toIso8601String(),
  };
}

class Receipt extends Equatable {
  final String id;
  final String saleId;
  final String userId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String buyerAddress;
  final double subtotal;
  final double vatAmount;
  final double total;
  final DateTime timestamp;
  final String paymentType; // 'Cash' or 'Credit'
  final String? buyerName;
  final String? buyerPhone;

  const Receipt({
    required this.id,
    required this.saleId,
    required this.userId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.buyerAddress,
    required this.subtotal,
    required this.vatAmount,
    required this.total,
    required this.timestamp,
    required this.paymentType,
    this.buyerName,
    this.buyerPhone,
  });

  @override
  List<Object?> get props => [
    id, saleId, userId, productName, unitPrice, quantity, 
    buyerAddress, subtotal, vatAmount, total, timestamp,
    paymentType, buyerName, buyerPhone
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'sale_id': saleId,
    'user_id': userId,
    'product_name': productName,
    'unit_price': unitPrice,
    'quantity': quantity,
    'buyer_address': buyerAddress,
    'subtotal': subtotal,
    'vat_amount': vatAmount,
    'total': total,
    'timestamp': timestamp.toIso8601String(),
    'payment_type': paymentType,
    'buyer_name': buyerName,
    'buyer_phone': buyerPhone,
  };

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      saleId: json['sale_id'] as String,
      userId: json['user_id'] as String,
      productName: json['product_name'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      buyerAddress: json['buyer_address'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      vatAmount: (json['vat_amount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.parse(json['timestamp'] as String))
          : DateTime.now(),
      paymentType: json['payment_type'] as String? ?? 'Cash',
      buyerName: json['buyer_name'] as String?,
      buyerPhone: json['buyer_phone'] as String?,
    );
  }
}
