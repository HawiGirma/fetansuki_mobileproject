import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/dashboard/domain/entities/product.dart';
import 'package:fetansuki_app/features/receipt/data/repositories/sale_repository.dart';
import 'package:fetansuki_app/common/widgets/custom_button.dart';
import 'package:fetansuki_app/common/widgets/custom_text_field.dart';

class SaleRecordDialog extends ConsumerStatefulWidget {
  final Product product;

  const SaleRecordDialog({super.key, required this.product});

  @override
  ConsumerState<SaleRecordDialog> createState() => _SaleRecordDialogState();
}

class _SaleRecordDialogState extends ConsumerState<SaleRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _buyerNameController = TextEditingController();
  final _buyerPhoneController = TextEditingController();
  final _buyerAddressController = TextEditingController(text: 'Local Store');
  String _paymentType = 'Cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    _buyerAddressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(saleRepositoryProvider);
      await repository.processSale(
        productId: widget.product.id,
        quantity: int.parse(_quantityController.text),
        buyerAddress: _buyerAddressController.text,
        paymentType: _paymentType,
        buyerName: _buyerNameController.text.isEmpty ? null : _buyerNameController.text,
        buyerPhone: _buyerPhoneController.text.isEmpty ? null : _buyerPhoneController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Sale: ${widget.product.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _quantityController,
                  hintText: 'Quantity',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Payment Type', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Cash'),
                        value: 'Cash',
                        groupValue: _paymentType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _paymentType = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Credit'),
                        value: 'Credit',
                        groupValue: _paymentType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _paymentType = v!),
                      ),
                    ),
                  ],
                ),
                if (_paymentType == 'Credit') ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _buyerNameController,
                    hintText: 'Buyer Name (Required for Credit)',
                    validator: (v) => _paymentType == 'Credit' && (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _buyerPhoneController,
                    hintText: 'Buyer Phone',
                    keyboardType: TextInputType.phone,
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _buyerAddressController,
                  hintText: 'Buyer Address / Note',
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Process Sale',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
