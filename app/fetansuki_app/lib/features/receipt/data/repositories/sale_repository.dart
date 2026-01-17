import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/receipt/domain/entities/receipt_models.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';

class SaleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SaleRepository(this._firestore, this._auth);

  Future<Receipt> processSale({
    required String productId,
    required int quantity,
    required String buyerAddress,
    String paymentType = 'Cash',
    String? buyerName,
    String? buyerPhone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException('User not authenticated');

    return await _firestore.runTransaction((transaction) async {
      final productRef = _firestore.collection('stock_items').doc(productId);
      final productSnap = await transaction.get(productRef);

      if (!productSnap.exists) {
        throw ServerException('Product not found');
      }

      final data = productSnap.data()!;
      final currentQuantity = int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;
      final unitPrice = (data['price'] as num?)?.toDouble() ?? 0.0;
      final productName = data['name'] as String;

      if (currentQuantity < quantity) {
        throw ServerException('Insufficient stock. Available: $currentQuantity');
      }

      // Calculations (Backend-trusted)
      const vatRate = 0.15;
      final subtotal = unitPrice * quantity;
      final vatAmount = subtotal * vatRate;
      final total = subtotal + vatAmount;

      // Update Stock
      transaction.update(productRef, {
        'quantity': (currentQuantity - quantity).toString(),
      });

      // Create Sale Record
      final saleRef = _firestore.collection('sales').doc();
      final saleTimestamp = DateTime.now();
      
      final sale = Sale(
        id: saleRef.id,
        productId: productId,
        userId: user.uid,
        quantity: quantity,
        buyerAddress: buyerAddress,
        timestamp: saleTimestamp,
      );
      transaction.set(saleRef, sale.toJson());

      // Create Receipt Record
      final receiptRef = _firestore.collection('receipts').doc();
      final receipt = Receipt(
        id: receiptRef.id,
        saleId: saleRef.id,
        userId: user.uid,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity,
        buyerAddress: buyerAddress,
        subtotal: subtotal,
        vatAmount: vatAmount,
        total: total,
        timestamp: saleTimestamp,
        paymentType: paymentType,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
      );
      transaction.set(receiptRef, receipt.toJson());

      // Create Credit Record if applicable
      if (paymentType == 'Credit') {
        final creditRef = _firestore.collection('credits').doc();
        transaction.set(creditRef, {
          'user_id': user.uid,
          'name': buyerName ?? 'Unknown Buyer', // Using buyerName as the credit entry name
          'quantity': quantity.toString(), // Store quantity as string to match CreditItem
          'sale_id': saleRef.id,
          'receipt_id': receiptRef.id,
          'amount': total,
          'buyer_phone': buyerPhone,
          'status': 'pending',
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return receipt;
    });
  }

  Stream<List<Receipt>> watchAllReceipts() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('receipts')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Receipt.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }
}

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final receiptsProvider = StreamProvider<List<Receipt>>((ref) {
  return ref.watch(saleRepositoryProvider).watchAllReceipts();
});
