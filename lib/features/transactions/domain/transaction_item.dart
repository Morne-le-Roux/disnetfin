class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.description,
    required this.accountName,
    required this.category,
    required this.isExpense,
    this.available,
  });

  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final String description;
  final String accountName;
  final String category;
  final bool isExpense;
  final double? available;

  double get absoluteAmount => amount.abs();

  factory TransactionItem.fromPocketBaseData({
    required String id,
    required Map<String, dynamic> data,
    required DateTime created,
  }) {
    final rawAmount = data['amount'];

    final double amount = switch (rawAmount) {
      num n => n.toDouble(),
      String s => double.tryParse(s) ?? 0,
      _ => 0.0,
    };

    final currency = _stringValue(data['currency']).toUpperCase();
    final merchantName = _stringValue(data['merchant_name']);
    final accountName = _stringValue(data['account_name']);
    final rawType = _stringValue(data['type']);
    final rawDate = data['created'];
    final rawAvailable = data['available'];

    final available = switch (rawAvailable) {
      num n => n.toDouble(),
      String s => double.tryParse(s),
      _ => null,
    };

    final normalizedType = rawType.toLowerCase();

    final isExpense = _inferIsExpense(
      amount: amount,
      normalizedType: normalizedType,
    );

    return TransactionItem(
      id: id,
      amount: amount,
      currency: currency.isEmpty ? 'ZAR' : currency,
      date: _dateValue(rawDate) ?? created,
      description: merchantName.trim().isEmpty ? 'Transaction' : merchantName,
      accountName: accountName,
      category: rawType.trim().isEmpty ? 'Uncategorized' : rawType,
      isExpense: isExpense,
      available: available,
    );
  }

  static bool _inferIsExpense({
    required double amount,
    required String normalizedType,
  }) {
    if (normalizedType.contains('expense') ||
        normalizedType.contains('debit') ||
        normalizedType.contains('withdraw') ||
        normalizedType.contains('purchase') ||
        normalizedType.contains('payment')) {
      return true;
    }
    if (normalizedType.contains('income') ||
        normalizedType.contains('credit') ||
        normalizedType.contains('deposit') ||
        normalizedType.contains('salary') ||
        normalizedType.contains('refund')) {
      return false;
    }
    // Fallback: negative amounts are treated as expenses.
    return amount < 0;
  }

  static String _stringValue(dynamic value) {
    return value?.toString() ?? '';
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
