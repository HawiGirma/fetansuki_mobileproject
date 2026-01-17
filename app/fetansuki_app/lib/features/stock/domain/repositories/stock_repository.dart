import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
import 'package:fpdart/fpdart.dart';

abstract class StockRepository {
  Future<Either<Failure, StockData>> getStockData();
  Future<Either<Failure, StockItem>> createStockItem(StockItem item);
  Future<Either<Failure, StockItem>> updateStockItem(StockItem item);
  Future<Either<Failure, void>> deleteStockItem(String id);
}
