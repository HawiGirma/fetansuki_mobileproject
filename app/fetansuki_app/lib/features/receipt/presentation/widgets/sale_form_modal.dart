import 'package:fetansuki_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:fetansuki_app/features/stock/presentation/providers/stock_providers.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_item.dart';
import 'package:fetansuki_app/features/receipt/data/repositories/sale_repository.dart';
import 'package:go_router/go_router.dart';

class SaleFormModal extends ConsumerStatefulWidget {
  final StockItem item;

  const SaleFormModal({super.key, required this.item});

  @override
  ConsumerState<SaleFormModal> createState() => _SaleFormModalState();
}

class _SaleFormModalState extends ConsumerState<SaleFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _quantityController = TextEditingController();
  final _buyerNameController = TextEditingController();
  final _buyerPhoneController = TextEditingController();
  String _paymentType = 'Cash';
  DateTime? _dueDate;
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _quantityController.dispose();
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quantity = int.parse(_quantityController.text);
      final receipt = await ref.read(saleRepositoryProvider).processSale(
        productId: widget.item.id,
        quantity: quantity,
        buyerAddress: _addressController.text,
        paymentType: _paymentType,
        buyerName: _paymentType == 'Credit' ? _buyerNameController.text : null,
        buyerPhone: _paymentType == 'Credit' ? _buyerPhoneController.text : null,
        dueDate: _paymentType == 'Credit' ? _dueDate : null,
      );

      if (mounted) {
        ref.invalidate(dashboardDataProvider);
        ref.invalidate(stockDataProvider);
        Navigator.pop(context); // Close modal
        context.push('/receipt/${receipt.id}'); // Navigate to specific receipt detail
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = int.tryParse(widget.item.quantity ?? '0') ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sell ${widget.item.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Available Stock: $available', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Cash', 'Credit'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _paymentType = value);
                },
              ),
              const SizedBox(height: 16),
              if (_paymentType == 'Credit') ...[
                TextFormField(
                  controller: _buyerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Buyer Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (_paymentType == 'Credit' && (v == null || v.isEmpty)) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _buyerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Buyer Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (_paymentType != 'Credit') return null;
                    if (v == null || v.isEmpty) return 'Required';
                    if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(v)) return 'Invalid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date (Optional)'),
                  subtitle: Text(_dueDate == null ? 'Not set' : DateFormat('MMM dd, yyyy').format(_dueDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Buyer Address',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Invalid number';
                  if (n > available) return 'Exceeds stock';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3C7E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Confirm Sale'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
