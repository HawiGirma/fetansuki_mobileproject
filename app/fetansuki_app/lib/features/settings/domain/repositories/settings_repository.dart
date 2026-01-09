import 'package:fetansuki_app/core/error/failures.dart';
import 'package:fetansuki_app/features/settings/domain/entities/settings_data.dart';
import 'package:fpdart/fpdart.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsData>> getSettingsData();
}
