import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
import 'package:fetansuki_app/features/stock/domain/repositories/stock_repository.dart';

class StockCreationState {
  final bool isLoading;
  final String? errorMessage;
  final StockItem? createdItem;

  const StockCreationState({
    this.isLoading = false,
    this.errorMessage,
    this.createdItem,
  });

  StockCreationState copyWith({
    bool? isLoading,
    String? errorMessage,
    StockItem? createdItem,
  }) {
    return StockCreationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      createdItem: createdItem,
    );
  }
}

class StockCreationNotifier extends StateNotifier<StockCreationState> {
  final StockRepository repository;

  StockCreationNotifier(this.repository) : super(const StockCreationState());

  Future<bool> createStockItem(StockItem item) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await repository.createStockItem(item);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdItem) {
        state = state.copyWith(
          isLoading: false,
          createdItem: createdItem,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> deleteStockItem(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await repository.deleteStockItem(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, errorMessage: null);
        return true;
      },
    );
  }

  void reset() {
    state = const StockCreationState();
  }
}
