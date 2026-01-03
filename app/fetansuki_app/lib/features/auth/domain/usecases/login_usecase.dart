import 'package:fpdart/fpdart.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/auth/domain/entities/user_entity.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}
