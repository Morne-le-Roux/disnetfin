import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction_model.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class AddRecurringTransactionScreen extends ConsumerStatefulWidget {
  final RecurringTransactionModel? existing;
  final String? defaultType;

  const AddRecurringTransactionScreen({
    super.key,
    this.existing,
    this.defaultType,
  });

  @override
  ConsumerState<AddRecurringTransactionScreen> createState() =>
      _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState
    extends ConsumerState<AddRecurringTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _type = 'expense';
  String? _selectedCategoryId;
  int _dayOfMonth = 1;
  late DateTime _startMonth;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startMonth = DateTime(now.year, now.month);

    final item = widget.existing;
    if (item != null) {
      _type = item.type;
      _selectedCategoryId = item.categoryId;
      _amountCtrl.text = item.amount.toStringAsFixed(2);
      _descCtrl.text = item.description;
      _dayOfMonth = item.dayOfMonth;
      _startMonth = item.startMonth;
    } else {
      _type = widget.defaultType ?? 'expense';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoriesProvider)
        .where((c) => c.type == _type)
        .toList();

    if (_selectedCategoryId != null &&
        !categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = null;
    }

    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recurring' : 'Add Recurring'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.repeat, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'This item will automatically appear in every month from the start month onwards.',
                      style: TextStyle(color: AppTheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Type toggle
            Container(
              decoration: BoxDecoration(
                color: AppTheme.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _TypeButton(
                    label: 'Expense',
                    icon: Icons.arrow_upward_rounded,
                    isSelected: _type == 'expense',
                    color: AppTheme.expenseColor,
                    onTap: () => setState(() {
                      _type = 'expense';
                      _selectedCategoryId = null;
                    }),
                  ),
                  _TypeButton(
                    label: 'Income',
                    icon: Icons.arrow_downward_rounded,
                    isSelected: _type == 'income',
                    color: AppTheme.incomeColor,
                    onTap: () => setState(() {
                      _type = 'income';
                      _selectedCategoryId = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly Amount',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter an amount';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => v == null ? 'Select a category' : null,
              hint: categories.isEmpty
                  ? const Text('No categories — add one first')
                  : const Text('Select category'),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Day of month
            _DayOfMonthField(
              value: _dayOfMonth,
              onChanged: (v) => setState(() => _dayOfMonth = v),
            ),
            const SizedBox(height: 16),

            // Start month
            InkWell(
              onTap: _pickStartMonth,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Starting From',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(_startMonth),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.repeat, size: 18),
              label: Text(isEditing ? 'Save Changes' : 'Add Recurring Item'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select start month',
    );
    if (picked != null) {
      setState(() => _startMonth = DateTime(picked.year, picked.month));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount = double.parse(_amountCtrl.text);

    if (widget.existing != null) {
      await ref
          .read(recurringTransactionsProvider.notifier)
          .update(
            widget.existing!.copyWith(
              categoryId: _selectedCategoryId,
              type: _type,
              amount: amount,
              description: _descCtrl.text.trim(),
              dayOfMonth: _dayOfMonth,
              startMonth: _startMonth,
            ),
          );
    } else {
      await ref
          .read(recurringTransactionsProvider.notifier)
          .add(
            categoryId: _selectedCategoryId!,
            type: _type,
            amount: amount,
            description: _descCtrl.text.trim(),
            dayOfMonth: _dayOfMonth,
            startMonth: _startMonth,
          );
    }

    if (mounted) Navigator.pop(context);
  }
}

class _DayOfMonthField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DayOfMonthField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Day of Month',
        prefixIcon: Icon(Icons.today_outlined),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 22),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            onPressed: value < 31 ? () => onChanged(value + 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          const Text(
            'of each month',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: color.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
