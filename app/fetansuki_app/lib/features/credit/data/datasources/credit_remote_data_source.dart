import 'package:fetansuki_app/features/credit/data/datasources/credit_data_source.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_data.dart';

class CreditRemoteDataSource implements CreditDataSource {
  @override
  Future<CreditData> getCreditData() async {
    throw UnimplementedError('API implementation pending');
  }
}
