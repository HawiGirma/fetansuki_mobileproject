import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/stock/presentation/providers/stock_providers.dart';
import 'package:fetansuki_app/features/stock/presentation/widgets/best_reviewed_list.dart';
import 'package:fetansuki_app/features/stock/presentation/widgets/category_list.dart';
import 'package:fetansuki_app/features/stock/presentation/widgets/recently_added_grid.dart';
import 'package:fetansuki_app/features/stock/presentation/widgets/stock_action_buttons.dart';
import 'package:fetansuki_app/features/stock/presentation/widgets/stock_header.dart';

class StockPage extends ConsumerWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockDataAsync = ref.watch(stockDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // Very light blue bg
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(stockDataProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StockHeader(),
                const StockActionButtons(),
                const SizedBox(height: 24),
                
                stockDataAsync.when(
                  data: (data) => Column(
                    children: [
                      CategoryList(categories: data.categories),
                      const SizedBox(height: 24),
                      BestReviewedList(products: data.bestReviewed),
                      const SizedBox(height: 12), // Reduced spacing slightly
                      RecentlyAddedGrid(items: data.recentlyAdded),
                      const SizedBox(height: 40),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: $error'),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(stockDataProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}