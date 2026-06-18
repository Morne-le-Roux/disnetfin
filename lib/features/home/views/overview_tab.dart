import 'package:disnetfin/core/utils/currency.dart';
import 'package:disnetfin/features/budget/presentation/providers/budget_providers.dart';
import 'package:disnetfin/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetAmountProvider);
    final monthTransactions = ref.watch(monthTransactionsProvider);

    return monthTransactions.when(
      data: (items) {
        final spent = items
            .where((item) => item.isExpense)
            .fold<double>(0, (sum, item) => sum + item.absoluteAmount);
        final income = items
            .where((item) => !item.isExpense)
            .fold<double>(0, (sum, item) => sum + item.absoluteAmount);
        final remaining = budget - spent;
        final currencies = items.map((item) => item.currency).toSet();
        final hasMixedCurrencies = currencies.length > 1;
        final summaryCurrency = currencies.isEmpty ? 'ZAR' : currencies.first;

        final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Monthly Snapshot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Spent',
                    value: formatCurrency(spent, currencyCode: summaryCurrency),
                    tone: const Color(0xFFAA3F2E),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Income',
                    value: formatCurrency(
                      income,
                      currencyCode: summaryCurrency,
                    ),
                    tone: const Color(0xFF2F6A5A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Budget',
                    value: formatCurrency(
                      budget,
                      currencyCode: summaryCurrency,
                    ),
                    tone: const Color(0xFF2D4F75),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Remaining',
                    value: formatCurrency(
                      remaining,
                      currencyCode: summaryCurrency,
                    ),
                    tone: remaining < 0
                        ? const Color(0xFFAA3F2E)
                        : const Color(0xFF2F6A5A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFD7D9CF),
                        color: progress > 1
                            ? const Color(0xFFAA3F2E)
                            : const Color(0xFF2F6A5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% budget used',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (hasMixedCurrencies) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Warning: month contains multiple currencies. Totals are indicative.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Transactions in month'),
                trailing: Text(items.length.toString()),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load overview: $error'),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: tone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
