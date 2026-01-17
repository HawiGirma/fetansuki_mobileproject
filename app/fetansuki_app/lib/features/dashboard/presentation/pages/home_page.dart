import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:fetansuki_app/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:fetansuki_app/features/dashboard/presentation/widgets/home_header.dart';
import 'package:fetansuki_app/features/dashboard/presentation/widgets/new_arrived_list.dart';
import 'package:fetansuki_app/features/stock/presentation/widgets/best_reviewed_list.dart';
import 'package:fetansuki_app/features/dashboard/presentation/widgets/updates_list.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // Very light blue bg
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardDataProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const HomeHeader(),
                dashboardDataAsync.when(
                  data: (data) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: BalanceCard(
                          totalSalesAmount: data.walletBalance,
                          totalActiveCreditsAmount: data.totalActiveCreditsAmount,
                          totalSalesCount: data.totalSalesCount,
                          totalActiveCreditsCount: data.totalActiveCreditsCount,
                          totalProductsCount: data.totalProductsCount,
                          currency: data.currency,
                        ),
                      ),
                      const SizedBox(height: 24),
                      NewArrivedList(products: data.newArrived),
                      const SizedBox(height: 24),
                      UpdatesList(updates: data.updates),
                      const SizedBox(height: 40),
                      BestReviewedList(products: data.bestReviewed),
                      const SizedBox(height: 24),
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
                            onPressed: () => ref.invalidate(dashboardDataProvider),
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