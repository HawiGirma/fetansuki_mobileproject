import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';

abstract class StockDataSource {
  Future<StockData> getStockData();
}
