import 'package:disnetfin/features/auth/presentation/providers/auth_providers.dart';
import 'package:disnetfin/features/budget/presentation/views/budget_tab.dart';
import 'package:disnetfin/features/home/views/overview_tab.dart';
import 'package:disnetfin/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:disnetfin/features/transactions/presentation/views/transactions_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  int _tabIndex = 0;

  static const _tabs = [OverviewTab(), TransactionsTab(), BudgetTab()];
  static const _tabTitles = ['Overview', 'Transactions', 'Budget'];

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final title = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF9F5EB), Color(0xFFE8F0E8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'DisNetFin',
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh transactions',
                          onPressed: () =>
                              ref.invalidate(allTransactionsProvider),
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                        IconButton(
                          tooltip: 'Sign out',
                          onPressed: () async {
                            await ref.read(authControllerProvider).logout();
                            ref.invalidate(allTransactionsProvider);
                          },
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MonthControl(
                          label: 'Prev',
                          icon: Icons.chevron_left_rounded,
                          onPressed: () {
                            final current = ref.read(selectedMonthProvider);
                            ref.read(selectedMonthProvider.notifier).state =
                                DateTime(current.year, current.month - 1);
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.84),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$title • ${_tabTitles[_tabIndex]}',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                        _MonthControl(
                          label: 'Next',
                          icon: Icons.chevron_right_rounded,
                          onPressed: () {
                            final current = ref.read(selectedMonthProvider);
                            ref.read(selectedMonthProvider.notifier).state =
                                DateTime(current.year, current.month + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey<int>(_tabIndex),
                    child: _tabs[_tabIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (value) {
          setState(() {
            _tabIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}

class _MonthControl extends StatelessWidget {
  const _MonthControl({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.84),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
