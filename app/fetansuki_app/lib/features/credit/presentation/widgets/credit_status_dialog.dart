import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_item.dart';
import 'package:fetansuki_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:fetansuki_app/features/credit/presentation/providers/credit_providers.dart';
import 'package:fetansuki_app/common/widgets/custom_button.dart';

class CreditStatusDialog extends ConsumerStatefulWidget {
  final CreditItem item;

  const CreditStatusDialog({super.key, required this.item});

  @override
  ConsumerState<CreditStatusDialog> createState() => _CreditStatusDialogState();
}

class _CreditStatusDialogState extends ConsumerState<CreditStatusDialog> {
  String _selectedStatus = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.item.status ?? 'pending';
  }

  Future<void> _handleUpdate() async {
    if (_selectedStatus == 'notify') {
      // Logic for sending notification (placeholder)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent to buyer!'), backgroundColor: Colors.blue),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(creditUpdateProvider.notifier).updateStatus(widget.item.id, _selectedStatus);
    
    if (mounted) {
      final state = ref.read(creditUpdateProvider);
      if (state.isSuccess) {
        ref.invalidate(creditDataProvider);
        ref.invalidate(dashboardDataProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!'), backgroundColor: Colors.green),
        );
      } else if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.errorMessage}'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Status: ${widget.item.name}', style: Theme.of(context).textTheme.titleLarge),
            if (widget.item.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Due Date: ${DateFormat.yMMMd().format(widget.item.dueDate!)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            const SizedBox(height: 24),
            RadioListTile<String>(
              title: const Text('Paid'),
              subtitle: const Text('Mark this credit as settled'),
              value: 'paid',
              groupValue: _selectedStatus,
              onChanged: (v) => setState(() => _selectedStatus = v!),
              activeColor: const Color(0xFF0F3C7E),
            ),
            RadioListTile<String>(
              title: const Text('Notify Buyer'),
              subtitle: const Text('Send a reminder notification'),
              value: 'notify',
              groupValue: _selectedStatus,
              onChanged: (v) => setState(() => _selectedStatus = v!),
              activeColor: const Color(0xFF0F3C7E),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _selectedStatus == 'notify' ? 'Send Notification' : 'Update Status',
              isLoading: _isLoading,
              onPressed: _handleUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
