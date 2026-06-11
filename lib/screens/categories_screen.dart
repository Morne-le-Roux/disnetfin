import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_tile.dart';
import 'add_category_screen.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
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
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    // Only count transactions in the selected month
    double categoryTotal(String catId) => transactions
        .where((t) =>
            t.categoryId == catId &&
            t.date.year == selectedMonth.year &&
            t.date.month == selectedMonth.month)
        .fold(0.0, (s, t) => s + t.amount);

    int categoryTxCount(String catId) => transactions
        .where((t) =>
            t.categoryId == catId &&
            t.date.year == selectedMonth.year &&
            t.date.month == selectedMonth.month)
        .length;

    Widget categoryList(String type) {
      final cats = categories.where((c) => c.type == type).toList();
      if (cats.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'income'
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 56,
                color: AppTheme.textSecondary.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No $type categories yet.\nTap + to add one.',
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
        itemCount: cats.length,
        itemBuilder: (context, i) {
          final cat = cats[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CategoryTile(
              category: cat,
              totalAmount: categoryTotal(cat.id),
              transactionCount: categoryTxCount(cat.id),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDetailScreen(category: cat),
                ),
              ),
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCategoryScreen(existing: cat),
                ),
              ),
              onDelete: () => _confirmDelete(context, cat),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.arrow_downward_rounded, size: 18),
              text: 'Income',
            ),
            Tab(
              icon: Icon(Icons.arrow_upward_rounded, size: 18),
              text: 'Expenses',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddCategoryScreen(
                  defaultType: _tabController.index == 0 ? 'income' : 'expense',
                ),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [categoryList('income'), categoryList('expense')],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel cat) {
    final transactions = ref.read(transactionsProvider);
    final txCount = transactions.where((t) => t.categoryId == cat.id).length;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          txCount > 0
              ? 'Deleting "${cat.name}" will also delete $txCount transaction${txCount == 1 ? '' : 's'}. This cannot be undone.'
              : 'Delete "${cat.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(categoriesProvider.notifier).delete(cat.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.expenseColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
