import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/receipt/data/repositories/sale_repository.dart';
import 'package:fetansuki_app/features/receipt/domain/entities/receipt_models.dart';
import 'package:fetansuki_app/features/receipt/data/services/pdf_service.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

class ReceiptPage extends ConsumerWidget {
  const ReceiptPage({super.key});

  static final currencyFormat = NumberFormat.currency(symbol: 'ETB ');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(receiptsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Receipts'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F3C7E),
      ),
      body: receiptsAsync.when(
        data: (receipts) {
          if (receipts.isEmpty) {
            return const Center(child: Text('No receipts found'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return _ReceiptGridItem(receipt: receipt);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ReceiptGridItem extends StatelessWidget {
  final Receipt receipt;

  const _ReceiptGridItem({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/receipt/${receipt.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: receipt.paymentType == 'Cash' ? Colors.green[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                receipt.paymentType,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: receipt.paymentType == 'Cash' ? Colors.green[800] : Colors.blue[800],
                ),
              ),
            ),
            const Spacer(),
            Text(
              receipt.productName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${receipt.id.substring(0, 8)}',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(receipt.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            const Divider(height: 16),
            Text(
              ReceiptPage.currencyFormat.format(receipt.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F3C7E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
