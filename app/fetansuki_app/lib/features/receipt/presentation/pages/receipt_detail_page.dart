import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/receipt/domain/entities/receipt_models.dart';
import 'package:fetansuki_app/features/receipt/data/repositories/sale_repository.dart';
import 'package:fetansuki_app/features/receipt/data/services/pdf_service.dart';
import 'package:intl/intl.dart';

class ReceiptDetailPage extends ConsumerWidget {
  final String receiptId;

  const ReceiptDetailPage({super.key, required this.receiptId});

  static final currencyFormat = NumberFormat.currency(symbol: 'ETB ');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(receiptsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Receipt Detail'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F3C7E),
      ),
      body: receiptsAsync.when(
        data: (receipts) {
          final receipt = receipts.firstWhere(
            (r) => r.id == receiptId,
            orElse: () => throw Exception('Receipt not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(receipt),
                const Divider(height: 48),
                _buildBuyerInfo(receipt),
                const SizedBox(height: 24),
                _buildDetails(receipt),
                const SizedBox(height: 32),
                _buildTotals(receipt),
                const SizedBox(height: 48),
                _buildDownloadButton(receipt),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(Receipt receipt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              receipt.paymentType.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: receipt.paymentType == 'Cash' ? Colors.green : Colors.blue,
                letterSpacing: 1.1,
              ),
            ),
            const Text(
              'RECEIPT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3C7E),
              ),
            ),
            Text(
              'ID: ${receipt.id}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(receipt.timestamp),
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              DateFormat('HH:mm').format(receipt.timestamp),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBuyerInfo(Receipt receipt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BILL TO',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (receipt.buyerName != null)
          Text(
            receipt.buyerName!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        if (receipt.buyerPhone != null)
          Text(
            receipt.buyerPhone!,
            style: TextStyle(color: Colors.grey[700]),
          ),
        Text(
          receipt.buyerAddress,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDetails(Receipt receipt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ITEM DETAILS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.productName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Qty: ${receipt.quantity} × ${currencyFormat.format(receipt.unitPrice)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              currencyFormat.format(receipt.subtotal),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotals(Receipt receipt) {
    return Column(
      children: [
        _buildTotalRow('Subtotal', currencyFormat.format(receipt.subtotal)),
        const SizedBox(height: 8),
        _buildTotalRow('VAT (15%)', currencyFormat.format(receipt.vatAmount)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        _buildTotalRow(
          'Grand Total',
          currencyFormat.format(receipt.total),
          isBold: true,
          fontSize: 22,
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false, double fontSize = 16}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF0F3C7E) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton(Receipt receipt) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => PdfService.generateAndShareReceipt(receipt),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Download PDF Receipt'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F3C7E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
