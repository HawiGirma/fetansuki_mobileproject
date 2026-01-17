import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/credit/data/datasources/credit_data_source.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_data.dart';
import 'package:fetansuki_app/features/credit/domain/repositories/credit_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreditRepositoryImpl implements CreditRepository {
  final CreditDataSource dataSource;

  CreditRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, CreditData>> getCreditData() async {
    try {
      final data = await dataSource.getCreditData();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCreditStatus(String id, String status) async {
    try {
      await dataSource.updateCreditStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
