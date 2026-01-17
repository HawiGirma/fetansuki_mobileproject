import 'package:fetansuki_app/features/stock/data/datasources/stock_data_source.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_category.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';

class StockMockDataSource implements StockDataSource {
  @override
  Future<StockData> getStockData() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay

    return const StockData(
      categories: [
        StockCategory(id: '1', name: 'All'),
        StockCategory(id: '2', name: 'Fruits'),
        StockCategory(id: '3', name: 'Vegies'),
        StockCategory(id: '4', name: 'Beverages'),
        StockCategory(id: '5', name: 'Diaries'),
      ],
      bestReviewed: [
        Product(
          id: '1',
          name: 'Lotion Radiance',
          imageUrl: 'https://via.placeholder.com/150',
          price: 25.00,
        ),
        Product(
          id: '2',
          name: 'Lotion Shimmer',
          imageUrl: 'https://via.placeholder.com/150',
          price: 18.50,
        ),
      ],
      recentlyAdded: [
        StockItem(
          id: '3',
          name: 'Pasta',
          imageUrl: 'https://via.placeholder.com/150', // Replace with icon placeholder if needed
          quantity: '2kg in Stock',
        ),
        StockItem(
          id: '4',
          name: 'Pasta',
          imageUrl: 'https://via.placeholder.com/150',
          quantity: '2kg in Stock',
        ),
        StockItem(
          id: '5',
          name: 'Pasta',
          imageUrl: 'https://via.placeholder.com/150',
          quantity: '2kg in Stock',
        ),
        StockItem(
          id: '6',
          name: 'Pasta',
          imageUrl: 'https://via.placeholder.com/150',
          quantity: '2kg in Stock',
        ),
        StockItem(
          id: '7',
          name: 'Pasta',
          imageUrl: 'https://via.placeholder.com/150',
          quantity: '2kg in Stock',
        ),
        StockItem(
          id: '8',
          name: 'Pasta',
          imageUrl: 'https://via.placeholder.com/150',
          quantity: '2kg in Stock',
        ),
      ],
    );
  }

  @override
  Future<StockItem> createStockItem(StockItem item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return item.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<StockItem> updateStockItem(StockItem item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return item;
  }

  @override
  Future<void> deleteStockItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
