import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// ── Categories ──────────────────────────────────────────────────────────────

class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  final StorageService _storage;

  CategoriesNotifier(this._storage) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.getCategories();
  }

  Future<void> add({
    required String name,
    required String type,
    required String iconName,
    required int colorValue,
  }) async {
    final category = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      type: type,
      iconName: iconName,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    await _storage.saveCategory(category);
    _load();
  }

  Future<void> update(CategoryModel updated) async {
    await _storage.saveCategory(updated);
    _load();
  }

  Future<void> delete(String id) async {
    await _storage.deleteCategory(id);
    _load();
  }

  List<CategoryModel> getByType(String type) =>
      state.where((c) => c.type == type).toList();
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>((ref) {
      return CategoriesNotifier(ref.watch(storageServiceProvider));
    });

// ── Transactions ─────────────────────────────────────────────────────────────

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final StorageService _storage;

  TransactionsNotifier(this._storage) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.getTransactions();
  }

  Future<void> add({
    required String categoryId,
    required String type,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    final tx = TransactionModel(
      id: const Uuid().v4(),
      categoryId: categoryId,
      type: type,
      amount: amount,
      description: description,
      date: date,
      createdAt: DateTime.now(),
    );
    await _storage.saveTransaction(tx);
    _load();
  }

  Future<void> update(TransactionModel updated) async {
    await _storage.saveTransaction(updated);
    _load();
  }

  Future<void> delete(String id) async {
    await _storage.deleteTransaction(id);
    _load();
  }

  List<TransactionModel> getByCategory(String categoryId) =>
      state.where((t) => t.categoryId == categoryId).toList();
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>((ref) {
      return TransactionsNotifier(ref.watch(storageServiceProvider));
    });

// ── Recurring transactions ────────────────────────────────────────────────────

class RecurringTransactionsNotifier
    extends StateNotifier<List<RecurringTransactionModel>> {
  final StorageService _storage;

  RecurringTransactionsNotifier(this._storage) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.getRecurringTransactions();
  }

  Future<void> add({
    required String categoryId,
    required String type,
    required double amount,
    required String description,
    required int dayOfMonth,
    required DateTime startMonth,
    DateTime? endMonth,
  }) async {
    final item = RecurringTransactionModel(
      id: const Uuid().v4(),
      categoryId: categoryId,
      type: type,
      amount: amount,
      description: description,
      dayOfMonth: dayOfMonth,
      startMonth: startMonth,
      endMonth: endMonth,
      createdAt: DateTime.now(),
    );
    await _storage.saveRecurringTransaction(item);
    _load();
  }

  Future<void> update(RecurringTransactionModel updated) async {
    await _storage.saveRecurringTransaction(updated);
    _load();
  }

  Future<void> delete(String id) async {
    await _storage.deleteRecurringTransaction(id);
    _load();
  }
}

final recurringTransactionsProvider = StateNotifierProvider<
    RecurringTransactionsNotifier, List<RecurringTransactionModel>>((ref) {
  return RecurringTransactionsNotifier(ref.watch(storageServiceProvider));
});

/// Projects recurring items into virtual TransactionModels for [month].
/// IDs follow the pattern `recurring_<id>_<year>_<month>` for identification.
List<TransactionModel> projectRecurring(
  List<RecurringTransactionModel> recurring,
  DateTime month,
) {
  return recurring
      .where((r) => r.appliesTo(month))
      .map((r) => TransactionModel(
            id: 'recurring_${r.id}_${month.year}_${month.month}',
            categoryId: r.categoryId,
            type: r.type,
            amount: r.amount,
            description: r.description,
            date: r.dateFor(month),
            createdAt: r.createdAt,
          ))
      .toList();
}

/// All effective transactions for the selected month (real + recurring).
final effectiveTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final real = ref.watch(transactionsProvider).where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );
  final projected = projectRecurring(
    ref.watch(recurringTransactionsProvider),
    month,
  );
  return [...real, ...projected]..sort((a, b) => b.date.compareTo(a.date));
});

// ── Selected month ────────────────────────────────────────────────────────────

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// ── Derived summaries ─────────────────────────────────────────────────────────

bool _inMonth(DateTime date, DateTime month) =>
    date.year == month.year && date.month == month.month;

final totalIncomeProvider = Provider<double>((ref) {
  return ref
      .watch(effectiveTransactionsProvider)
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(effectiveTransactionsProvider)
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

/// Spending by category for the selected month (real + recurring).
final monthlyExpenseByCategoryProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref
      .watch(effectiveTransactionsProvider)
      .where((t) => t.isExpense)
      .toList();

  final Map<String, double> result = {};
  for (final t in transactions) {
    result[t.categoryId] = (result[t.categoryId] ?? 0) + t.amount;
  }
  return result;
});

/// Monthly totals for the last 6 months (real + recurring).
final monthlyTotalsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final realTransactions = ref.watch(transactionsProvider);
  final recurring = ref.watch(recurringTransactionsProvider);
  final now = DateTime.now();
  final result = <Map<String, dynamic>>[];

  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final projected = projectRecurring(recurring, month);
    final all = [
      ...realTransactions.where((t) => _inMonth(t.date, month)),
      ...projected,
    ];
    final income = all
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = all
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);
    result.add({'month': month, 'income': income, 'expense': expense});
  }
  return result;
});
