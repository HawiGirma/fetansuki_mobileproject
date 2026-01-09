import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:fpdart/fpdart.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
}
