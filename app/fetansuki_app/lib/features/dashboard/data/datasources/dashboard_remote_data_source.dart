import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/features/dashboard/data/datasources/dashboard_data_source.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/update_item.dart';

class DashboardRemoteDataSource implements DashboardDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  DashboardRemoteDataSource({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }

      // 1. Fetch receipts to calculate total sales/wallet balance
      final receiptsSnapshot = await firestore
          .collection('receipts')
          .where('user_id', isEqualTo: user.uid)
          .get();

      double walletBalance = 0;
      for (var doc in receiptsSnapshot.docs) {
        walletBalance += (doc.data()['total'] as num?)?.toDouble() ?? 0.0;
      }

      // 2. Fetch sales to count frequencies for Best Reviewed
      final salesSnapshot = await firestore
          .collection('sales')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      int totalSalesCount = salesSnapshot.size;
      final Map<String, int> productSalesCount = {};
      
      for (var doc in salesSnapshot.docs) {
        final data = doc.data();
        // walletBalance calculation moved to receipts
        
        final productId = data['product_id'] as String?;
        if (productId != null) {
          productSalesCount[productId] = (productSalesCount[productId] ?? 0) + 1;
        }
      }

      // 2. Fetch all stock items to populate lists
      final stockSnapshot = await firestore
          .collection('stock_items')
          .where('user_id', isEqualTo: user.uid)
          .get();

      int totalProductsCount = stockSnapshot.size;
      final allStockItems = stockSnapshot.docs.map((doc) {
        final data = doc.data();
        final imageUrl = data['image_url'] as String? ?? '';
        
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'No Name',
          'price': (data['price'] as num?)?.toDouble() ?? 0.0,
          'imageUrl': imageUrl,
          'created_at': data['created_at'] as Timestamp?,
          'salesCount': productSalesCount[doc.id] ?? 0,
        };
      }).toList();

      // Sort for New Arrived (Recent first)
      final sortedByDate = List.from(allStockItems);
      sortedByDate.sort((a, b) {
        final dateA = a['created_at'] as Timestamp?;
        final dateB = b['created_at'] as Timestamp?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return -1;
        if (dateB == null) return 1;
        return dateB.compareTo(dateA);
      });

      final newArrived = sortedByDate.take(5).map((data) => Product(
        id: data['id'] as String,
        name: data['name'] as String,
        price: data['price'] as double,
        imageUrl: data['imageUrl'] as String,
      )).toList();

      // Sort for Best Reviewed (Most sales first)
      final sortedBySales = List.from(allStockItems);
      sortedBySales.sort((a, b) => (b['salesCount'] as int).compareTo(a['salesCount'] as int));

      final bestReviewed = sortedBySales.take(5).map((data) => Product(
        id: data['id'] as String,
        name: data['name'] as String,
        price: data['price'] as double,
        imageUrl: data['imageUrl'] as String,
      )).toList();

      // 3. Fetch active credits
      final creditsSnapshot = await firestore
          .collection('credits')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      double activeCreditsAmount = 0;
      int activeCreditsCount = 0;
      for (var doc in creditsSnapshot.docs) {
        final data = doc.data();
        if (data['status'] != 'paid') {
          activeCreditsCount++;
          final amountStr = data['amount']?.toString() ?? '0';
          activeCreditsAmount += double.tryParse(amountStr) ?? 0.0;
        }
      }

      final updates = [
         UpdateItem(
          id: 'sales',
          title: 'Total Sales',
          subtitle: 'Lifetime',
          currentAmount: walletBalance,
          totalAmount: 1000000.0,
          iconColor: Colors.blue.withAlpha(25),
          iconTintColor: Colors.blue,
          iconData: Icons.trending_up,
        ),
        UpdateItem(
          id: 'credits',
          title: 'Active Credits',
          subtitle: 'Pending Collection',
          currentAmount: activeCreditsAmount,
          totalAmount: 50000.0,
          iconColor: Colors.orange.withAlpha(25),
          iconTintColor: Colors.orange,
          iconData: Icons.credit_card,
        ),
      ];

      return DashboardData(
        walletBalance: walletBalance,
        totalActiveCreditsAmount: activeCreditsAmount,
        totalSalesCount: totalSalesCount,
        totalActiveCreditsCount: activeCreditsCount,
        totalProductsCount: totalProductsCount,
        currency: 'ETB',
        newArrived: newArrived,
        bestReviewed: bestReviewed,
        updates: updates,
      );
    } on FirebaseException catch (e, s) {
      debugPrint('FIREBASE ERROR: ${e.message}');
      debugPrint('STACK TRACE: $s');
      throw ServerException(e.message ?? 'Firestore error');
    } catch (e, s) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('DASHBOARD DATA SOURCE ERROR: $e');
      debugPrint('STACK TRACE: $s');
      throw ServerException('Failed to fetch dashboard data: ${e.toString()}');
    }
  }
}
