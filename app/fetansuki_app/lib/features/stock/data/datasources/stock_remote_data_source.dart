import 'package:fetansuki_app/features/stock/data/datasources/stock_data_source.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';

class StockRemoteDataSource implements StockDataSource {
  @override
  Future<StockData> getStockData() async {
    throw UnimplementedError('API implementation pending');
  }
}
