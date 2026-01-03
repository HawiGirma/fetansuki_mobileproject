import 'package:fpdart/fpdart.dart';
import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
