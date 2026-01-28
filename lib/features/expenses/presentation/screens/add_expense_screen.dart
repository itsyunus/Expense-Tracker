import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_chip.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? expenseId;

  const AddExpenseScreen({super.key, this.expenseId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  bool _isLoading = false;
  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExpense();
    }
  }

  Future<void> _loadExpense() async {
    final expense = await ref.read(expenseProvider.notifier).getExpenseById(widget.expenseId!);
    if (expense != null) {
      setState(() {
        _titleController.text = expense.title;
        _amountController.text = expense.amount.toString();
        _noteController.text = expense.note ?? '';
        _selectedDate = expense.date;
        _selectedCategory = expense.category;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editExpense : AppStrings.addExpense),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input (large, prominent)
              _buildAmountInput(isDarkMode),

              const SizedBox(height: 24),

              // Title Input
              _buildTextField(
                controller: _titleController,
                label: AppStrings.expenseTitle,
                icon: Icons.description_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category Selection
              Text(
                AppStrings.expenseCategory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildCategoryGrid(),

              const SizedBox(height: 24),

              // Date Picker
              _buildDatePicker(isDarkMode),

              const SizedBox(height: 16),

              // Note Input
              _buildTextField(
                controller: _noteController,
                label: AppStrings.expenseNote,
                icon: Icons.note_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: AnimatedButton(
                  text: AppStrings.save,
                  isLoading: _isLoading,
                  icon: Icons.check,
                  onPressed: _saveExpense,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.expenseAmount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.white54,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpenseCategory.values.map((category) {
        return CategoryChip(
          category: category,
          isSelected: _selectedCategory == category,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedCategory = category;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(bool isDarkMode) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.expenseDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      
      if (_isEditing) {
        await ref.read(expenseProvider.notifier).updateExpense(
          id: widget.expenseId!,
          title: _titleController.text,
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
      } else {
        await ref.read(expenseProvider.notifier).addExpense(
          title: _titleController.text,
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
      }

      if (mounted) {
        HapticFeedback.heavyImpact();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? AppStrings.expenseUpdated : AppStrings.expenseAdded),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
