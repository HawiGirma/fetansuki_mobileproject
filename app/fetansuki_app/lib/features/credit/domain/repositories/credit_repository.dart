import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_data.dart';
import 'package:fpdart/fpdart.dart';

abstract class CreditRepository {
  Future<Either<Failure, CreditData>> getCreditData();
}
