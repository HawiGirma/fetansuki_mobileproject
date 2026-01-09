import 'package:fetansuki_app/features/settings/data/datasources/settings_data_source.dart';
import 'package:fetansuki_app/features/settings/domain/entities/settings_data.dart';

class SettingsRemoteDataSource implements SettingsDataSource {
  @override
  Future<SettingsData> getSettingsData() async {
    throw UnimplementedError('API implementation pending');
  }
}
