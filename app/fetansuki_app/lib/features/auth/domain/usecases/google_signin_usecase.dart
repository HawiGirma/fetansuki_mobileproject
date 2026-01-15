import 'package:fpdart/fpdart.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/auth/domain/entities/user_entity.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
