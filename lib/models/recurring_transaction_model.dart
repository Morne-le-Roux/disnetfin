class RecurringTransactionModel {
  final String id;
  final String categoryId;
  final String type; // 'income' or 'expense'
  final double amount;
  final String description;
  final int dayOfMonth; // 1–31, clamped to last day of each month
  final DateTime startMonth; // first month it applies (year+month only)
  final DateTime? endMonth; // null = ongoing
  final DateTime createdAt;

  const RecurringTransactionModel({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.dayOfMonth,
    required this.startMonth,
    this.endMonth,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'type': type,
        'amount': amount,
        'description': description,
        'dayOfMonth': dayOfMonth,
        'startMonth': startMonth.toIso8601String(),
        'endMonth': endMonth?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory RecurringTransactionModel.fromJson(Map<dynamic, dynamic> json) =>
      RecurringTransactionModel(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String,
        dayOfMonth: json['dayOfMonth'] as int,
        startMonth: DateTime.parse(json['startMonth'] as String),
        endMonth: json['endMonth'] != null
            ? DateTime.parse(json['endMonth'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  RecurringTransactionModel copyWith({
    String? id,
    String? categoryId,
    String? type,
    double? amount,
    String? description,
    int? dayOfMonth,
    DateTime? startMonth,
    Object? endMonth = _sentinel,
    DateTime? createdAt,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth == _sentinel
          ? this.endMonth
          : endMonth as DateTime?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether this recurring item applies to [month].
  bool appliesTo(DateTime month) {
    final monthStart = DateTime(month.year, month.month);
    final itemStart = DateTime(startMonth.year, startMonth.month);
    if (monthStart.isBefore(itemStart)) return false;
    if (endMonth != null) {
      final itemEnd = DateTime(endMonth!.year, endMonth!.month);
      if (monthStart.isAfter(itemEnd)) return false;
    }
    return true;
  }

  /// The date this item falls on within [month].
  DateTime dateFor(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final day = dayOfMonth.clamp(1, lastDay);
    return DateTime(month.year, month.month, day);
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}

// Sentinel for copyWith nullable field
const Object _sentinel = Object();
