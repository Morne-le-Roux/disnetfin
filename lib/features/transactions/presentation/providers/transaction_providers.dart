import 'package:disnetfin/core/network/pocketbase_client.dart';
import 'package:disnetfin/features/transactions/data/transaction_repository.dart';
import 'package:disnetfin/features/transactions/domain/transaction_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(pocketBaseProvider));
});

final allTransactionsProvider = FutureProvider<List<TransactionItem>>((
  ref,
) async {
  return ref.watch(transactionRepositoryProvider).fetchTransactions();
});

final monthTransactionsProvider = Provider<AsyncValue<List<TransactionItem>>>((
  ref,
) {
  final month = ref.watch(selectedMonthProvider);
  final transactions = ref.watch(allTransactionsProvider);

  return transactions.whenData(
    (items) => items
        .where(
          (item) =>
              item.date.year == month.year && item.date.month == month.month,
        )
        .toList(growable: false),
  );
});
