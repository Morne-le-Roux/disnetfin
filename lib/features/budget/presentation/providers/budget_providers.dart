import 'package:disnetfin/features/budget/data/budget_repository.dart';
import 'package:disnetfin/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final budgetBoxProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box<dynamic>('budget_settings');
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(budgetBoxProvider));
});

final budgetAmountProvider = Provider<double>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(budgetRepositoryProvider).getBudgetForMonth(month);
});

final budgetControllerProvider = Provider<BudgetController>((ref) {
  return BudgetController(ref);
});

class BudgetController {
  const BudgetController(this._ref);

  final Ref _ref;

  Future<void> setBudget(double value) async {
    final month = _ref.read(selectedMonthProvider);
    await _ref
        .read(budgetRepositoryProvider)
        .setBudgetForMonth(month: month, amount: value);
    _ref.invalidate(budgetAmountProvider);
  }
}
