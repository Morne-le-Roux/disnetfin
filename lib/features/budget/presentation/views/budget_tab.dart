import 'package:disnetfin/core/utils/currency.dart';
import 'package:disnetfin/features/budget/presentation/providers/budget_providers.dart';
import 'package:disnetfin/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetTab extends ConsumerStatefulWidget {
  const BudgetTab({super.key});

  @override
  ConsumerState<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends ConsumerState<BudgetTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetAmountProvider);
    final month = ref.watch(selectedMonthProvider);
    final monthTransactions = ref.watch(monthTransactionsProvider);

    final spent = monthTransactions.maybeWhen(
      data: (items) => items
          .where((item) => item.isExpense)
          .fold<double>(0, (sum, item) => sum + item.absoluteAmount),
      orElse: () => 0.0,
    );
    final currencies = monthTransactions.maybeWhen(
      data: (items) => items.map((item) => item.currency).toSet(),
      orElse: () => <String>{},
    );
    final hasMixedCurrencies = currencies.length > 1;
    final summaryCurrency = currencies.isEmpty ? 'ZAR' : currencies.first;

    final remaining = budget - spent;
    final usage = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Budget Planner', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          '${month.year}-${month.month.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text('Budget: ', style: Theme.of(context).textTheme.bodyLarge),
                _AnimatedCurrencyText(
                  amount: budget,
                  currencyCode: summaryCurrency,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text('Spent: ', style: Theme.of(context).textTheme.bodyLarge),
                _AnimatedCurrencyText(
                  amount: spent,
                  currencyCode: summaryCurrency,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Remaining: ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: _AnimatedCurrencyText(
                        amount: remaining,
                        currencyCode: summaryCurrency,
                        style: TextStyle(
                          color: remaining < 0
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: usage),
                    duration: const Duration(milliseconds: 850),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedUsage, _) {
                      return LinearProgressIndicator(
                        value: animatedUsage,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFD7D9CF),
                        color: usage > 1
                            ? const Color(0xFFAA3F2E)
                            : const Color(0xFF2F6A5A),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: usage * 100),
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeOutCubic,
                  builder: (context, percent, _) {
                    return Text('${percent.toStringAsFixed(1)}% budget used');
                  },
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
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Monthly Budget',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Set budget amount',
                    hintText: 'e.g. 1200',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final value = double.tryParse(_controller.text.trim());
                    if (value == null || value < 0) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid non-negative amount.'),
                        ),
                      );
                      return;
                    }

                    await ref.read(budgetControllerProvider).setBudget(value);
                    _controller.clear();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget updated.')),
                    );
                  },
                  child: const Text('Save Budget'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedCurrencyText extends StatelessWidget {
  const _AnimatedCurrencyText({
    required this.amount,
    required this.currencyCode,
    this.style,
  });

  final double amount;
  final String currencyCode;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedAmount, _) {
        return Text(
          formatCurrency(animatedAmount, currencyCode: currencyCode),
          style: style,
        );
      },
    );
  }
}
