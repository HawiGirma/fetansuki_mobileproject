import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/credit/domain/repositories/credit_repository.dart';

class CreditUpdateState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const CreditUpdateState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  CreditUpdateState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CreditUpdateState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class CreditUpdateNotifier extends StateNotifier<CreditUpdateState> {
  final CreditRepository repository;

  CreditUpdateNotifier(this.repository) : super(const CreditUpdateState());

  Future<void> updateStatus(String id, String status) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    final result = await repository.updateCreditStatus(id, status);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }
}
