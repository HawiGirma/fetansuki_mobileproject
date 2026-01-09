class StockItem {
  final String id;
  final String name;
  final String imageUrl;
  final double? price;
  final String? quantity;
  final String? description;

  const StockItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.price,
    this.quantity,
    this.description,
  });
}
