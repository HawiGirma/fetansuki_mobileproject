import 'package:flutter/foundation.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/features/stock/data/datasources/stock_data_source.dart';
import 'package:fetansuki_app/features/stock/data/models/stock_item_model.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_category.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
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

      // Fetch stock items from Firestore for the specific user
      final querySnapshot = await _stockCollection
          .where('user_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      final items = querySnapshot.docs
          .map((doc) => StockItemModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // For now, we'll organize items into categories and sections
      final recentlyAdded = items.take(6).toList();
      final bestReviewed = items.skip(6).take(5).toList();

      // Create some default categories
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

