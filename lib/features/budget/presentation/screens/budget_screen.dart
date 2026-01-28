import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/animated_button.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_progress_ring.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _budgetController = TextEditingController();
  bool _isEditing = false;
  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final budget = ref.watch(budgetProvider);
    final monthlySpending = ref.watch(monthlySpendingForBudgetProvider);
    final remaining = (budget?.amount ?? 0) - monthlySpending;
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              title: Text(
                AppStrings.budget,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Budget Overview
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [AppColors.surfaceDark, AppColors.backgroundDark]
                        : [AppColors.primary.withOpacity(0.05), AppColors.surfaceLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(now),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Progress Ring
                    BudgetProgressRing(
                      spent: monthlySpending,
                      budget: budget?.amount ?? 0,
                      size: 180,
                      strokeWidth: 14,
                    ),

                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          'Budget',
                          _currencyFormat.format(budget?.amount ?? 0),
                          AppColors.primary,
                          isDarkMode,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        _buildStatItem(
                          'Spent',
                          _currencyFormat.format(monthlySpending),
                          AppColors.error,
                          isDarkMode,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        _buildStatItem(
                          'Remaining',
                          _currencyFormat.format(remaining.clamp(0, double.infinity)),
                          remaining >= 0 ? AppColors.secondary : AppColors.error,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Set Budget Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.setBudget,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isEditing)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isEditing = true;
                                _budgetController.text = 
                                    (budget?.amount ?? 0).toStringAsFixed(0);
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isEditing) ...[
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Enter budget',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() => _isEditing = false);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(AppStrings.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedButton(
                              text: AppStrings.save,
                              onPressed: _saveBudget,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Quick Budget Options
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickBudgetChip(5000, isDarkMode),
                          _buildQuickBudgetChip(10000, isDarkMode),
                          _buildQuickBudgetChip(15000, isDarkMode),
                          _buildQuickBudgetChip(20000, isDarkMode),
                          _buildQuickBudgetChip(25000, isDarkMode),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Budget Tips Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Set a budget 10-20% lower than your actual limit to save money!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDarkMode) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickBudgetChip(int amount, bool isDarkMode) {
    final budget = ref.watch(budgetProvider);
    final isSelected = budget?.amount == amount.toDouble();

    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        await ref.read(budgetProvider.notifier).updateBudget(amount.toDouble());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary 
              : (isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : (isDarkMode ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          '₹${amount ~/ 1000}k',
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    HapticFeedback.mediumImpact();
    final amount = double.tryParse(_budgetController.text);
    if (amount != null && amount > 0) {
      await ref.read(budgetProvider.notifier).updateBudget(amount);
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Budget updated!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
