import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fpdart/fpdart.dart';

abstract class StockRepository {
  Future<Either<Failure, StockData>> getStockData();
}
