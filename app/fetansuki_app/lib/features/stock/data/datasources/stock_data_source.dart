import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';

abstract class StockDataSource {
  Future<StockData> getStockData();
  Future<StockItem> createStockItem(StockItem item);
  Future<StockItem> updateStockItem(StockItem item);
  Future<void> deleteStockItem(String id);
}
