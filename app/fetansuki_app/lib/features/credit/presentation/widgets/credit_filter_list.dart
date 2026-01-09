import 'package:flutter/material.dart';
import 'package:fetansuki_app/features/credit/domain/entities/credit_filter.dart';

class CreditFilterList extends StatefulWidget {
  final List<CreditFilter> filters;

  const CreditFilterList({super.key, required this.filters});

  @override
  State<CreditFilterList> createState() => _CreditFilterListState();
}

class _CreditFilterListState extends State<CreditFilterList> {
  String _selectedId = '1';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: widget.filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = widget.filters[index];
          final isSelected = filter.id == _selectedId;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedId = filter.id;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF90CAF9), 
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  filter.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
