import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:fetansuki_app/features/receipt/domain/entities/receipt_models.dart';

class PdfService {
  static final currencyFormat = NumberFormat.currency(symbol: 'ETB ');

  static Future<void> generateAndShareReceipt(Receipt receipt) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Receipt ID: ${receipt.id}'),
                        pw.Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(receipt.timestamp)}'),
                        pw.Text('Payment Type: ${receipt.paymentType}', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('BILL TO:'),
                        if (receipt.buyerName != null) pw.Text(receipt.buyerName!),
                        if (receipt.buyerPhone != null) pw.Text(receipt.buyerPhone!),
                        pw.Text(receipt.buyerAddress),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Item')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Qty')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Unit Price')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Amount')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(receipt.productName)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(receipt.quantity.toString())),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(currencyFormat.format(receipt.unitPrice))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(currencyFormat.format(receipt.subtotal))),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: ${currencyFormat.format(receipt.subtotal)}'),
                        pw.Text('VAT (15%): ${currencyFormat.format(receipt.vatAmount)}'),
                        pw.Divider(),
                        pw.Text('Total: ${currencyFormat.format(receipt.total)}', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(child: pw.Text('Thank you for your business!')),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt_${receipt.id}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Receipt from Fetansuki');
  }
}
