import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/update_item.dart';

class DashboardData {
  final double walletBalance;
  final String currency;
  final List<Product> newArrived;
  final List<UpdateItem> updates;

  const DashboardData({
    required this.walletBalance,
    required this.currency,
    required this.newArrived,
    required this.updates,
  });
}
