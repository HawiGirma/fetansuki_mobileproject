import 'package:fetansuki_app/features/dashboard/domain/entities/dashboard_data.dart';

abstract class DashboardDataSource {
  Future<DashboardData> getDashboardData();
}
