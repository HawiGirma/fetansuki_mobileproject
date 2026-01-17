import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_category.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';

class StockData {
  final List<StockCategory> categories;
  final List<Product> bestReviewed;
  final List<StockItem> recentlyAdded;

  const StockData({
    required this.categories,
    required this.bestReviewed,
    required this.recentlyAdded,
  });
}
