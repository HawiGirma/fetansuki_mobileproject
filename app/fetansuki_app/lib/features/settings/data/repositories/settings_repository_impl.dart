import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/settings/data/datasources/settings_data_source.dart';
import 'package:fetansuki_app/features/settings/domain/entities/settings_data.dart';
import 'package:fetansuki_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:fpdart/fpdart.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource dataSource;

  SettingsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, SettingsData>> getSettingsData() async {
    try {
      final data = await dataSource.getSettingsData();
      return Right(data);
    } on ServerException {
      return const Left(ServerFailure('Server Error'));
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
