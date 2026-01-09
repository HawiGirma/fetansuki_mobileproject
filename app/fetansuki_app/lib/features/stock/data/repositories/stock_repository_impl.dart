import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/stock/data/datasources/stock_data_source.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/repositories/stock_repository.dart';
import 'package:fpdart/fpdart.dart';

class StockRepositoryImpl implements StockRepository {
  final StockDataSource dataSource;

  StockRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, StockData>> getStockData() async {
    try {
      final data = await dataSource.getStockData();
      return Right(data);
    } on ServerException {
      return const Left(ServerFailure('Server Error'));
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
