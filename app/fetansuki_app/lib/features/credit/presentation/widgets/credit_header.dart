import 'package:flutter/material.dart';

class CreditHeader extends StatelessWidget {
  const CreditHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {}, // Should go back usually, but handled by main nav for now
              icon: const Icon(Icons.arrow_back_ios_new),
              color: Colors.black87,
              iconSize: 20,
            ),
          ),
          const Text(
            'Credit Tracker',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1), // Dark blue
            ),
          ),
        ],
      ),
    );
  }
}
