import 'package:fetansuki_app/features/credit/domain/entities/credit_data.dart';

abstract class CreditDataSource {
  Future<CreditData> getCreditData();
}
