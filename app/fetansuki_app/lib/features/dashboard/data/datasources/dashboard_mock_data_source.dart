import 'package:flutter/material.dart';
import 'package:fetansuki_app/features/dashboard/data/datasources/dashboard_data_source.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/update_item.dart';

class DashboardMockDataSource implements DashboardDataSource {
  @override
  Future<DashboardData> getDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return const DashboardData(
      walletBalance: 26345.05,
      currency: 'Birr',
      newArrived: [
        Product(
          id: '1',
          name: 'Lotion Smooth',
          imageUrl: 'https://via.placeholder.com/150', // Replace with asset or valid URL
          price: 22.75,
        ),
        Product(
          id: '2',
          name: 'Lotion Shimmer',
          imageUrl: 'https://via.placeholder.com/150',
          price: 18.50,
        ),
      ],
      updates: [
        UpdateItem(
          id: '1',
          title: 'Enat Ekub',
          subtitle: 'Montly collected',
          currentAmount: 50650,
          totalAmount: 100000,
          iconColor: Colors.green, // Just a placeholder color logic
          iconTintColor: Colors.white,
          iconData: Icons.arrow_upward,
        ),
        UpdateItem(
          id: '2',
          title: 'Credit',
          subtitle: 'Montly collected',
          currentAmount: 50650,
          totalAmount: 100000,
          iconColor: Colors.white,
          iconTintColor: Colors.black,
          iconData: Icons.credit_card,
        ),
      ],
    );
  }
}
