import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _categoriesBox = 'categories';
  static const String _transactionsBox = 'transactions';
  static const String _recurringBox = 'recurring_transactions';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_categoriesBox);
    await Hive.openBox(_transactionsBox);
    await Hive.openBox(_recurringBox);
  }

  // Categories
  Box get _catBox => Hive.box(_categoriesBox);
  Box get _txBox => Hive.box(_transactionsBox);
  Box get _recurBox => Hive.box(_recurringBox);

  List<CategoryModel> getCategories() {
    return _catBox.values.map((v) => CategoryModel.fromJson(v as Map)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> saveCategory(CategoryModel category) async {
    await _catBox.put(category.id, category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _catBox.delete(id);
    // Delete all transactions in this category
    final toDelete = _txBox.keys
        .where((k) => (_txBox.get(k) as Map)['categoryId'] == id)
        .toList();
    for (final key in toDelete) {
      await _txBox.delete(key);
    }
    // Delete all recurring transactions in this category
    final recurToDelete = _recurBox.keys
        .where((k) => (_recurBox.get(k) as Map)['categoryId'] == id)
        .toList();
    for (final key in recurToDelete) {
      await _recurBox.delete(key);
    }
  }

  // Transactions
  List<TransactionModel> getTransactions() {
    return _txBox.values
        .map((v) => TransactionModel.fromJson(v as Map))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    await _txBox.put(transaction.id, transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await _txBox.delete(id);
  }

  // Recurring transactions
  List<RecurringTransactionModel> getRecurringTransactions() {
    return _recurBox.values
        .map((v) => RecurringTransactionModel.fromJson(v as Map))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> saveRecurringTransaction(RecurringTransactionModel item) async {
    await _recurBox.put(item.id, item.toJson());
  }

  Future<void> deleteRecurringTransaction(String id) async {
    await _recurBox.delete(id);
  }
}
