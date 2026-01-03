import 'package:fpdart/fpdart.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/core/network/network_info.dart';
import 'package:fetansuki_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:fetansuki_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fetansuki_app/features/auth/domain/entities/user_entity.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.login(email, password);
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String name, String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.register(name, email, password);
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final localUser = await localDataSource.getLastUser();
      return Right(localUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}