import 'package:fetansuki_app/features/settings/domain/entities/settings_data.dart';

abstract class SettingsDataSource {
  Future<SettingsData> getSettingsData();
}
