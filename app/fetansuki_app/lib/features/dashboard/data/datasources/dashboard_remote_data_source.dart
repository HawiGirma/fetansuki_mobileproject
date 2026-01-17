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

      // 1. Fetch wallet balance from sales
      final salesSnapshot = await firestore
          .collection('sales')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      double walletBalance = 0;
      for (var doc in salesSnapshot.docs) {
        walletBalance += (doc.data()['total_amount'] as num?)?.toDouble() ?? 0.0;
      }

      // 2. Fetch new arrived products from stock_items
      final stockSnapshot = await firestore
          .collection('stock_items')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .limit(5)
          .get();

      final newArrived = stockSnapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] as String? ?? 'No Name',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['image_url'] as String? ?? '',
        );
      }).toList();

      // 3. Create some dummy updates for now or fetch from an audit log
      final updates = [
         UpdateItem(
          id: '1',
          title: 'Total Sales',
          subtitle: 'Today',
          currentAmount: walletBalance,
          totalAmount: 50000.0,
          iconColor: Colors.blue.withAlpha(25),
          iconTintColor: Colors.blue,
          iconData: Icons.trending_up,
        ),
        UpdateItem(
          id: '2',
          title: 'Active Credits',
          subtitle: 'Pending',
          currentAmount: 12000.0,
          totalAmount: 20000.0,
          iconColor: Colors.orange.withAlpha(25),
          iconTintColor: Colors.orange,
          iconData: Icons.credit_card,
        ),
      ];

      return DashboardData(
        walletBalance: walletBalance,
        currency: 'ETB',
        newArrived: newArrived,
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
