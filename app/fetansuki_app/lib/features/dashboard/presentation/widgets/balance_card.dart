import 'package:flutter/material.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final String currency;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EAF8), // Light blue background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isVisible ? '\$${widget.balance.toStringAsFixed(2)}' : '****',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                    child: Icon(
                      _isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    widget.currency,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.replay, 'Send'),
              _buildActionButton(Icons.savings_outlined, 'Save'),
              _buildActionButton(Icons.history, 'Borrow'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      width: 80, // Slightly wider to fit text
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1), // Dark blue
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
