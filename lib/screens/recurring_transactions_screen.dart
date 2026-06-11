import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction_model.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import 'add_recurring_transaction_screen.dart';

class RecurringTransactionsScreen extends ConsumerStatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  ConsumerState<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends ConsumerState<RecurringTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recurring = ref.watch(recurringTransactionsProvider);
    final categories = ref.watch(categoriesProvider);

    final income = recurring.where((r) => r.isIncome).toList();
    final expense = recurring.where((r) => r.isExpense).toList();

    final totalMonthlyIncome = income.fold(0.0, (s, r) => s + r.amount);
    final totalMonthlyExpense = expense.fold(0.0, (s, r) => s + r.amount);

    Widget list(List<RecurringTransactionModel> items, String type) {
      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.repeat,
                size: 56,
                color: AppTheme.textSecondary.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              Text(
                'No recurring $type items.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final cat = categories
              .where((c) => c.id == item.categoryId)
              .firstOrNull;
          final typeColor = item.isIncome
              ? AppTheme.incomeColor
              : AppTheme.expenseColor;
          final catColor = cat?.color ?? typeColor;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppTheme.expenseColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.expenseColor,
                ),
              ),
              confirmDismiss: (_) => _confirmDelete(item),
              onDismissed: (_) => ref
                  .read(recurringTransactionsProvider.notifier)
                  .delete(item.id),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddRecurringTransactionScreen(existing: item),
                  ),
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: catColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              cat?.icon ?? Icons.repeat,
                              color: catColor,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: catColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.cardLight,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.repeat,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.description.isEmpty
                                  ? (cat?.name ?? 'Recurring')
                                  : item.description,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (cat != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      cat.name,
                                      style: TextStyle(
                                        color: catColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  'Day ${item.dayOfMonth} of each month',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'From ${DateFormat('MMM yyyy').format(item.startMonth)}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.isIncome ? '+' : '-'}\$${NumberFormat('#,##0.00').format(item.amount)}',
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '/month',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddRecurringTransactionScreen(
                  defaultType: _tabController.index == 0 ? 'income' : 'expense',
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_downward_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Income  \$${NumberFormat('#,##0').format(totalMonthlyIncome)}/mo',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_upward_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Expenses  \$${NumberFormat('#,##0').format(totalMonthlyExpense)}/mo',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [list(income, 'income'), list(expense, 'expense')],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddRecurringTransactionScreen(
              defaultType: _tabController.index == 0 ? 'income' : 'expense',
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _confirmDelete(RecurringTransactionModel item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Recurring Item'),
        content: Text(
          'Stop recurring "${item.description.isEmpty ? 'this item' : item.description}" from appearing in future months?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.expenseColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
