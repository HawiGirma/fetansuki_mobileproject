import 'package:fpdart/fpdart.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/auth/domain/entities/user_entity.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String name, String email, String password) {
    return repository.register(name, email, password);
  }
}
