import 'package:hive_flutter/hive_flutter.dart';

class BudgetRepository {
  const BudgetRepository(this._box);

  final Box<dynamic> _box;

  String _monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  double getBudgetForMonth(DateTime month) {
    final value = _box.get(_monthKey(month));
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> setBudgetForMonth({
    required DateTime month,
    required double amount,
  }) async {
    await _box.put(_monthKey(month), amount);
  }
}
