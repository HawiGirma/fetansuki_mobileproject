import 'package:flutter/foundation.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/features/stock/data/datasources/stock_data_source.dart';
import 'package:fetansuki_app/features/stock/data/models/stock_item_model.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_category.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StockRemoteDataSource implements StockDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  StockRemoteDataSource({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference<Map<String, dynamic>> get _stockCollection =>
      firestore.collection('stock_items');

  @override
  Future<StockData> getStockData() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // Fetch all stock items
      final itemsSnapshot = await _stockCollection.where('user_id', isEqualTo: user.uid).get();
      final allItems = itemsSnapshot.docs
          .map((doc) => StockItemModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Fetch all receipts to calculate frequency
      final receiptsSnapshot = await firestore
          .collection('receipts')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      final productCounts = <String, int>{};
      for (var doc in receiptsSnapshot.docs) {
        final productId = doc.data()['product_id'] as String?; // Assuming receipt has product_id, if not, we use productName
        // Wait, looking at Receipt model, it doesn't have product_id. It has productName and saleId.
        // Sale has productId.
        // For simplicity, let's count by productName or fetch sales. 
        // Actually, let's use product_name as a proxy if product_id is missing, 
        // OR better, look at Sale objects (but that's more reads).
        // Let's check Receipt.fromJson again... it has sale_id.
        final productName = doc.data()['product_name'] as String?;
        if (productName != null) {
          productCounts[productName] = (productCounts[productName] ?? 0) + 1;
        }
      }

      // Sort items by frequency
      final itemsSortedByFrequency = List<StockItemModel>.from(allItems);
      itemsSortedByFrequency.sort((a, b) {
        final countA = productCounts[a.name] ?? 0;
        final countB = productCounts[b.name] ?? 0;
        return countB.compareTo(countA);
      });

      final bestReviewed = itemsSortedByFrequency
          .where((item) => (productCounts[item.name] ?? 0) > 0)
          .take(5)
          .map((item) => Product(
                id: item.id,
                name: item.name,
                price: item.price ?? 0.0,
                imageUrl: item.imageUrl,
              ))
          .toList();
      final recentlyAdded = allItems.take(6).toList();

      final categories = [
        const StockCategory(id: '1', name: 'All'),
        const StockCategory(id: '2', name: 'Electronics'),
        const StockCategory(id: '3', name: 'Clothing'),
        const StockCategory(id: '4', name: 'Food'),
      ];

      return StockData(
        categories: categories,
        bestReviewed: bestReviewed,
        recentlyAdded: recentlyAdded,
      );
    } on FirebaseException catch (e, s) {
      debugPrint('STOCK FIREBASE ERROR: ${e.message}');
      debugPrint('STACK TRACE: $s');
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e, s) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('STOCK DATA SOURCE ERROR: $e');
      debugPrint('STACK TRACE: $s');
      throw ServerException('Failed to fetch stock data: ${e.toString()}');
    }
  }

  @override
  Future<StockItem> createStockItem(StockItem item) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }

      final itemModel = StockItemModel.fromEntity(item);
      final itemJson = itemModel.toJson();
      
      // Remove id if it's empty or auto-generate
      itemJson.remove('id');
      itemJson['user_id'] = user.uid;
      itemJson['created_at'] = FieldValue.serverTimestamp();

      final docRef = await _stockCollection.add(itemJson);
      final docSnapshot = await docRef.get();
      
      final data = docSnapshot.data()!;
      // Handle timestamp converting to DateTime
      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
      }

      return StockItemModel.fromJson({...data, 'id': docRef.id});
    } on FirebaseException catch (e, s) {
      debugPrint('CREATE STOCK FIREBASE ERROR: ${e.message}');
      debugPrint('STACK TRACE: $s');
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e, s) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('CREATE STOCK DATA SOURCE ERROR: $e');
      debugPrint('STACK TRACE: $s');
      throw ServerException('Failed to create stock item: ${e.toString()}');
    }
  }

  @override
  Future<StockItem> updateStockItem(StockItem item) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }

      final itemModel = StockItemModel.fromEntity(item);
      final itemJson = itemModel.toJson();
      itemJson.remove('id');
      itemJson['updated_at'] = FieldValue.serverTimestamp();
      
      await _stockCollection.doc(item.id).update(itemJson);
      
      final docSnapshot = await _stockCollection.doc(item.id).get();
      final data = docSnapshot.data()!;
      
      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
      }

      return StockItemModel.fromJson({...data, 'id': item.id});
    } on FirebaseException catch (e, s) {
      debugPrint('UPDATE STOCK FIREBASE ERROR: ${e.message}');
      debugPrint('STACK TRACE: $s');
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e, s) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('UPDATE STOCK DATA SOURCE ERROR: $e');
      debugPrint('STACK TRACE: $s');
      throw ServerException('Failed to update stock item: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStockItem(String id) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }

      await _stockCollection.doc(id).delete();
    } on FirebaseException catch (e, s) {
      debugPrint('DELETE STOCK FIREBASE ERROR: ${e.message}');
      debugPrint('STACK TRACE: $s');
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e, s) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('DELETE STOCK DATA SOURCE ERROR: $e');
      debugPrint('STACK TRACE: $s');
      throw ServerException('Failed to delete stock item: ${e.toString()}');
    }
  }
}

