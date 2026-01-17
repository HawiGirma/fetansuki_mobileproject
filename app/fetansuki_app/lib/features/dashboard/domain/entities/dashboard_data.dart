import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/update_item.dart';

class DashboardData {
  final double walletBalance; // Total sales amount
  final double totalActiveCreditsAmount;
  final int totalSalesCount;
  final int totalActiveCreditsCount;
  final int totalProductsCount;
  final String currency;
  final List<Product> newArrived;
  final List<Product> bestReviewed;
  final List<UpdateItem> updates;

  const DashboardData({
    required this.walletBalance,
    required this.totalActiveCreditsAmount,
    required this.totalSalesCount,
    required this.totalActiveCreditsCount,
    required this.totalProductsCount,
    required this.currency,
    required this.newArrived,
    required this.bestReviewed,
    required this.updates,
  });
}
