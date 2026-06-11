import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'recurring_transactions_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categories = ref.watch(categoriesProvider);
    final monthlyTotals = ref.watch(monthlyTotalsProvider);
    final recurring = ref.watch(recurringTransactionsProvider);

    // All effective transactions for the selected month (real + recurring)
    final effectiveTxs = ref.watch(effectiveTransactionsProvider);
    final recent = effectiveTxs.take(5).toList();

    final fmt = NumberFormat('#,##0.00');
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Month navigator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white70,
                                size: 28,
                              ),
                              onPressed: () {
                                ref
                                    .read(selectedMonthProvider.notifier)
                                    .state = DateTime(
                                  selectedMonth.year,
                                  selectedMonth.month - 1,
                                );
                              },
                            ),
                            GestureDetector(
                              onTap: isCurrentMonth
                                  ? null
                                  : () {
                                      ref
                                          .read(selectedMonthProvider.notifier)
                                          .state = DateTime(
                                        now.year,
                                        now.month,
                                      );
                                    },
                              child: Text(
                                DateFormat('MMMM yyyy').format(selectedMonth),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: isCurrentMonth
                                    ? Colors.white24
                                    : Colors.white70,
                                size: 28,
                              ),
                              onPressed: isCurrentMonth
                                  ? null
                                  : () {
                                      ref
                                          .read(selectedMonthProvider.notifier)
                                          .state = DateTime(
                                        selectedMonth.year,
                                        selectedMonth.month + 1,
                                      );
                                    },
                            ),
                          ],
                        ),
                        const Text(
                          'Monthly Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${fmt.format(balance)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balance >= 0
                              ? 'On track this month!'
                              : 'Over budget this month.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Income / Expense cards
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          label: 'Income',
                          amount: '\$${fmt.format(totalIncome)}',
                          icon: Icons.arrow_downward_rounded,
                          color: AppTheme.incomeColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          label: 'Expenses',
                          amount: '\$${fmt.format(totalExpense)}',
                          icon: Icons.arrow_upward_rounded,
                          color: AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Monthly bar chart
                  const Text(
                    '6-Month Overview',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MonthlyChart(monthlyTotals: monthlyTotals),

                  const SizedBox(height: 24),

                  // Spending breakdown
                  if (totalExpense > 0) ...[
                    const Text(
                      'Expense Breakdown',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ExpenseBreakdown(ref: ref),
                    const SizedBox(height: 24),
                  ],

                  // Recurring summary shortcut
                  if (recurring.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recurring Items',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RecurringTransactionsScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.chevron_right, size: 18),
                          label: const Text('Manage'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _RecurringSummaryCard(recurring: recurring),
                    const SizedBox(height: 24),
                  ],

                  // Recent transactions
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    _EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message:
                          'No transactions this month.\nAdd your first one!',
                    )
                  else
                    Column(
                      children: recent.map((tx) {
                        final cat = categories
                            .where((c) => c.id == tx.categoryId)
                            .firstOrNull;
                        final isRecurring =
                            tx.id.startsWith('recurring_');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TransactionTile(
                            transaction: tx,
                            category: cat,
                            isRecurring: isRecurring,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringSummaryCard extends StatelessWidget {
  final List recurring;

  const _RecurringSummaryCard({required this.recurring});

  @override
  Widget build(BuildContext context) {
    final income = recurring
        .where((r) => r.isIncome)
        .fold(0.0, (s, r) => s + r.amount);
    final expense = recurring
        .where((r) => r.isExpense)
        .fold(0.0, (s, r) => s + r.amount);
    final fmt = NumberFormat('#,##0.00');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.repeat,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${recurring.length} recurring item${recurring.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+\$${fmt.format(income)}  −\$${fmt.format(expense)}  /month',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyTotals;

  const _MonthlyChart({required this.monthlyTotals});

  @override
  Widget build(BuildContext context) {
    if (monthlyTotals.every((m) => m['income'] == 0 && m['expense'] == 0)) {
      return _EmptyState(
        icon: Icons.bar_chart_outlined,
        message: 'No data yet',
      );
    }

    final maxY = monthlyTotals
        .expand((m) => [m['income'] as double, m['expense'] as double])
        .fold(0.0, (prev, v) => v > prev ? v : prev);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= monthlyTotals.length) {
                    return const SizedBox.shrink();
                  }
                  final month = monthlyTotals[idx]['month'] as DateTime;
                  return Text(
                    DateFormat('MMM').format(month),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppTheme.divider, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: monthlyTotals.asMap().entries.map((entry) {
            final i = entry.key;
            final data = entry.value;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (data['income'] as double),
                  color: AppTheme.incomeColor,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: (data['expense'] as double),
                  color: AppTheme.expenseColor,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
              barsSpace: 4,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ExpenseBreakdown extends ConsumerWidget {
  const _ExpenseBreakdown({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final byCat = widgetRef.watch(monthlyExpenseByCategoryProvider);
    final categories = widgetRef.watch(categoriesProvider);

    if (byCat.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = byCat.values.fold(0.0, (s, v) => s + v);
    final sorted = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    final sections = top5.asMap().entries.map((entry) {
      final catId = entry.value.key;
      final amount = entry.value.value;
      final cat = categories.where((c) => c.id == catId).firstOrNull;
      return PieChartSectionData(
        value: amount,
        color: cat?.color ?? AppTheme.expenseColor,
        title: '',
        radius: 50,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: top5.map((entry) {
                final cat = categories
                    .where((c) => c.id == entry.key)
                    .firstOrNull;
                final pct = total > 0 ? entry.value / total * 100 : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: cat?.color ?? AppTheme.expenseColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cat?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
