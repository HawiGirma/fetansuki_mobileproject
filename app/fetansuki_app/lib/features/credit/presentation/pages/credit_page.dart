import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/credit/presentation/providers/credit_providers.dart';
import 'package:fetansuki_app/features/credit/presentation/widgets/credit_filter_list.dart';
import 'package:fetansuki_app/features/credit/presentation/widgets/credit_header.dart';
import 'package:fetansuki_app/features/credit/presentation/widgets/credit_list.dart';

class CreditPage extends ConsumerWidget {
  const CreditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditDataAsync = ref.watch(creditDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // Very light blue bg
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(creditDataProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CreditHeader(),
                
                creditDataAsync.when(
                  data: (data) => Column(
                    children: [
                      CreditFilterList(filters: data.filters),
                      const SizedBox(height: 12),
                      CreditList(
                        title: 'Recently Added',
                        items: data.recentlyAdded,
                      ),
                      const SizedBox(height: 12),
                      CreditList(
                        title: 'Paid Credit',
                        items: data.paidCredit,
                      ),
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
                            onPressed: () => ref.invalidate(creditDataProvider),
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