class CreditItem {
  final String id;
  final String name;
  final String quantity;
  final String? status; // e.g., "in Stock"
  final String? imageUrl; // For now we'll use a placeholder or icon
  final DateTime? dueDate;

  const CreditItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.status,
    this.imageUrl,
    this.dueDate,
  });
}
