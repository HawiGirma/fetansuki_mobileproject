import 'package:fetansuki_app/features/credit/domain/entities/credit_filter.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_item.dart';

class CreditData {
  final List<CreditFilter> filters;
  final List<CreditItem> recentlyAdded;
  final List<CreditItem> paidCredit;

  const CreditData({
    required this.filters,
    required this.recentlyAdded,
    required this.paidCredit,
  });
}
