import 'package:fetansuki_app/features/credit/data/datasources/credit_data_source.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_data.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_filter.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_item.dart';

class CreditMockDataSource implements CreditDataSource {
  @override
  Future<CreditData> getCreditData() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const CreditData(
      filters: [
        CreditFilter(id: '1', label: 'All'),
        CreditFilter(id: '2', label: 'Last Week'),
        CreditFilter(id: '3', label: 'Last Month'),
        CreditFilter(id: '4', label: 'Recent'),
        CreditFilter(id: '5', label: 'Dicember'),
      ],
      recentlyAdded: [
        CreditItem(
          id: '1',
          name: 'Pasta',
          quantity: '2kg',
        ),
        CreditItem(
          id: '2',
          name: 'Pasta',
          quantity: '2kg',
          status: 'in Stock',
        ),
        CreditItem(
          id: '3',
          name: 'Pasta',
          quantity: '2kg',
          status: 'in Stock',
        ),
      ],
      paidCredit: [
        CreditItem(
          id: '4',
          name: 'Pasta',
          quantity: '2kg',
        ),
        CreditItem(
          id: '5',
          name: 'Pasta',
          quantity: '2kg',
          status: 'in Stock',
        ),
        CreditItem(
          id: '6',
          name: 'Pasta',
          quantity: '2kg',
          status: 'in Stock',
        ),
      ],
    );
  }
}
