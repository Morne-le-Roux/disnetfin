import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final CategoryModel? existing;
  final String? defaultType;

  const AddCategoryScreen({super.key, this.existing, this.defaultType});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _type = 'expense';
  String _selectedIcon = 'other_expense';
  int _selectedColor = CategoryModel.defaultColors[0];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    if (c != null) {
      _nameCtrl.text = c.name;
      _type = c.type;
      _selectedIcon = c.iconName;
      _selectedColor = c.colorValue;
    } else {
      _type = widget.defaultType ?? 'expense';
      _selectedIcon = _type == 'income' ? 'other_income' : 'other_expense';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = _type == 'income'
        ? CategoryModel.incomeIcons
        : CategoryModel.expenseIcons;

    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Category' : 'Add Category')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type toggle
            Container(
              decoration: BoxDecoration(
                color: AppTheme.divider.withOpacity(0.5),
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
                      _selectedIcon = 'other_expense';
                    }),
                  ),
                  _TypeButton(
                    label: 'Income',
                    icon: Icons.arrow_downward_rounded,
                    isSelected: _type == 'income',
                    color: AppTheme.incomeColor,
                    onTap: () => setState(() {
                      _type = 'income';
                      _selectedIcon = 'other_income';
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 24),

            // Icon picker
            const Text(
              'Icon',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: icons.map((entry) {
                final isSelected = _selectedIcon == entry.key;
                final color = Color(_selectedColor);
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : AppTheme.divider.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? color : AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Color picker
            const Text(
              'Color',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: CategoryModel.defaultColors.map((colorVal) {
                final isSelected = _selectedColor == colorVal;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorVal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppTheme.textPrimary, width: 2.5)
                          : Border.all(color: Colors.transparent, width: 2.5),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(colorVal).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(_selectedColor).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      CategoryModel(
                        id: '',
                        name: '',
                        type: _type,
                        iconName: _selectedIcon,
                        colorValue: _selectedColor,
                        createdAt: DateTime.now(),
                      ).icon,
                      color: Color(_selectedColor),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameCtrl.text.isEmpty
                              ? 'Category Name'
                              : _nameCtrl.text,
                          style: TextStyle(
                            color: _nameCtrl.text.isEmpty
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _type == 'income' ? 'Income' : 'Expense',
                          style: TextStyle(
                            color: _type == 'income'
                                ? AppTheme.incomeColor
                                : AppTheme.expenseColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Preview',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(isEditing ? 'Save Changes' : 'Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    if (widget.existing != null) {
      await ref
          .read(categoriesProvider.notifier)
          .update(
            widget.existing!.copyWith(
              name: _nameCtrl.text.trim(),
              type: _type,
              iconName: _selectedIcon,
              colorValue: _selectedColor,
            ),
          );
    } else {
      await ref
          .read(categoriesProvider.notifier)
          .add(
            name: _nameCtrl.text.trim(),
            type: _type,
            iconName: _selectedIcon,
            colorValue: _selectedColor,
          );
    }

    if (mounted) Navigator.pop(context);
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
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: color.withOpacity(0.4))
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
