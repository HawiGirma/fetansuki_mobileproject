import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/stock/data/datasources/stock_data_source.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_data.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StockItem>> createStockItem(StockItem item) async {
    try {
      final createdItem = await dataSource.createStockItem(item);
      return Right(createdItem);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StockItem>> updateStockItem(StockItem item) async {
    try {
      final updatedItem = await dataSource.updateStockItem(item);
      return Right(updatedItem);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStockItem(String id) async {
    try {
      await dataSource.deleteStockItem(id);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete item: ${e.toString()}'));
    }
  }
}
