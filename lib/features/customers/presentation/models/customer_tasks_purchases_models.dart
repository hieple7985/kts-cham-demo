class CustomerTaskItem {
  const CustomerTaskItem({
    required this.id,
    required this.taskType,
    required this.title,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.description,
  });

  final String id;
  final String taskType; // call|send_message|meeting|follow_up|send_document
  final String title;
  final String status; // pending|in_progress|completed|cancelled
  final String priority; // low|medium|high
  final String dueDate; // YYYY-MM-DD
  final String? description;
}

class CustomerPurchaseItem {
  const CustomerPurchaseItem({
    required this.id,
    required this.productName,
    required this.finalPrice,
    required this.paymentStatus,
    required this.purchaseDate,
    this.notes,
  });

  final String id;
  final String productName;
  final double finalPrice;
  final String paymentStatus; // pending|partial|completed|cancelled
  final String purchaseDate; // YYYY-MM-DD
  final String? notes;
}

