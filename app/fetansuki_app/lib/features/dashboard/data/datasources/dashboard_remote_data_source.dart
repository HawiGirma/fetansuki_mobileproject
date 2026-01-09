import 'package:fetansuki_app/features/dashboard/data/datasources/dashboard_data_source.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/dashboard_data.dart';

class DashboardRemoteDataSource implements DashboardDataSource {
  @override
  Future<DashboardData> getDashboardData() async {
    // Implement API call here
    throw UnimplementedError('API implementation pending');
  }
}
