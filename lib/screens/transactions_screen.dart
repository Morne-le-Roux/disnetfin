import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // effectiveTransactionsProvider already filters to selectedMonth
    final allTransactions = ref.watch(effectiveTransactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    List<TransactionModel> filtered(String type) {
      return allTransactions.where((t) {
        final matchType = type == 'all' || t.type == type;
        final matchSearch =
            _searchQuery.isEmpty ||
            t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (categories
                    .where((c) => c.id == t.categoryId)
                    .firstOrNull
                    ?.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
        return matchType && matchSearch;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 26),
              onPressed: () {
                ref.read(selectedMonthProvider.notifier).state = DateTime(
                  selectedMonth.year,
                  selectedMonth.month - 1,
                );
              },
            ),
            GestureDetector(
              onTap: isCurrentMonth
                  ? null
                  : () {
                      ref.read(selectedMonthProvider.notifier).state = DateTime(
                        now.year,
                        now.month,
                      );
                    },
              child: Text(
                DateFormat('MMM yyyy').format(selectedMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                size: 26,
                color: isCurrentMonth
                    ? AppTheme.textSecondary.withValues(alpha: 0.3)
                    : null,
              ),
              onPressed: isCurrentMonth
                  ? null
                  : () {
                      ref.read(selectedMonthProvider.notifier).state = DateTime(
                        selectedMonth.year,
                        selectedMonth.month + 1,
                      );
                    },
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primary,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Income'),
                  Tab(text: 'Expenses'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(
            transactions: filtered('all'),
            categories: ref.watch(categoriesProvider),
            onDelete: (id) =>
                ref.read(transactionsProvider.notifier).delete(id),
            onEdit: (tx) => _openEdit(tx),
          ),
          _TransactionList(
            transactions: filtered('income'),
            categories: ref.watch(categoriesProvider),
            onDelete: (id) =>
                ref.read(transactionsProvider.notifier).delete(id),
            onEdit: (tx) => _openEdit(tx),
          ),
          _TransactionList(
            transactions: filtered('expense'),
            categories: ref.watch(categoriesProvider),
            onDelete: (id) =>
                ref.read(transactionsProvider.notifier).delete(id),
            onEdit: (tx) => _openEdit(tx),
          ),
        ],
      ),
    );
  }

  void _openEdit(TransactionModel tx) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen(existing: tx)),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List categories;
  final void Function(String id) onDelete;
  final void Function(TransactionModel tx) onEdit;

  const _TransactionList({
    required this.transactions,
    required this.categories,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions found',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Group by date
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      final key = DateFormat('MMMM d, yyyy').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: grouped.length,
      itemBuilder: (context, i) {
        final date = grouped.keys.elementAt(i);
        final dayTxs = grouped[date]!;
        final dayTotal = dayTxs.fold(
          0.0,
          (s, t) => t.isIncome ? s + t.amount : s - t.amount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${dayTotal >= 0 ? '+' : ''}\$${NumberFormat('#,##0.00').format(dayTotal.abs())}',
                    style: TextStyle(
                      color: dayTotal >= 0
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ...dayTxs.map((tx) {
              final cat = categories
                  .where((c) => c.id == tx.categoryId)
                  .firstOrNull;
              final isRecurring = tx.id.startsWith('recurring_');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionTile(
                  transaction: tx,
                  category: cat,
                  isRecurring: isRecurring,
                  onDelete: isRecurring ? null : () => onDelete(tx.id),
                  onTap: () => onEdit(tx),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
