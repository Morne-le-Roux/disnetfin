class TransactionModel {
  final String id;
  final String categoryId;
  final String type; // 'income' or 'expense'
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'type': type,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory TransactionModel.fromJson(Map<dynamic, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  TransactionModel copyWith({
    String? id,
    String? categoryId,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
