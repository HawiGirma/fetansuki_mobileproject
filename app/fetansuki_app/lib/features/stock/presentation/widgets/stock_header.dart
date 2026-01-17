import 'package:flutter/material.dart';
import 'package:fetansuki_app/features/stock/presentation/widgets/create_stock_item_dialog.dart';

class StockHeader extends StatelessWidget {
  const StockHeader({super.key});

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateStockItemDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            color: Colors.black87,
          ),
          const Text(
            'Stock and Inventory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            color: const Color(0xFF0D47A1),
            tooltip: 'Add New Item',
          ),
        ],
      ),
    );
  }
}

