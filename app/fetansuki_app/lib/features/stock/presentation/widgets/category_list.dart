import 'package:flutter/material.dart';
import 'package:fetansuki_app/features/stock/domain/entities/stock_category.dart';

class CategoryList extends StatefulWidget {
  final List<StockCategory> categories;

  const CategoryList({super.key, required this.categories});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  String _selectedId = '1'; // Default to first item (All)

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = category.id == _selectedId;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedId = category.id;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFFD6EAF8), // Dark blue vs Light blue
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  category.name,
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
