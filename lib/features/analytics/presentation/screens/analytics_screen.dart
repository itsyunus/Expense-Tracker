import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0: This Month, 1: This Week, 2: Last Month
  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final expenseState = ref.watch(expenseProvider);
    
    // Filter expenses based on selected period
    final filteredExpenses = _filterExpenses(expenseState.expenses);
    final totalSpending = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final categoryData = _getCategoryData(filteredExpenses);
    final dailyData = _getDailyData(filteredExpenses);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              title: Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Period Selector
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildPeriodChip('This Month', 0),
                    const SizedBox(width: 8),
                    _buildPeriodChip('This Week', 1),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Last Month', 2),
                  ],
                ),
              ),
            ),

            // Total Spending Card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
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
                      'Total Spending',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormat.format(totalSpending),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${filteredExpenses.length} transactions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pie Chart Card
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
                    Text(
                      'Category Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (categoryData.isEmpty)
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No expenses yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      PieChartWidget(
                        categoryData: categoryData,
                        totalSpending: totalSpending,
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Bar Chart Card
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
                    Text(
                      'Daily Spending',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (dailyData.isEmpty)
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'No expenses yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      BarChartWidget(dailyData: dailyData),
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

  Widget _buildPeriodChip(String label, int index) {
    final isSelected = _selectedPeriod == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 0: // This Month
        return expenses.where((e) => 
          e.date.year == now.year && e.date.month == now.month
        ).toList();
      case 1: // This Week
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return expenses.where((e) => 
          e.date.isAfter(startOfWeek.subtract(const Duration(days: 1)))
        ).toList();
      case 2: // Last Month
        final lastMonth = DateTime(now.year, now.month - 1);
        return expenses.where((e) => 
          e.date.year == lastMonth.year && e.date.month == lastMonth.month
        ).toList();
      default:
        return expenses;
    }
  }

  Map<ExpenseCategory, double> _getCategoryData(List<Expense> expenses) {
    final Map<ExpenseCategory, double> data = {};
    for (final expense in expenses) {
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

  Map<DateTime, double> _getDailyData(List<Expense> expenses) {
    final Map<DateTime, double> data = {};
    for (final expense in expenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      data[date] = (data[date] ?? 0) + expense.amount;
    }
    return Map.fromEntries(
      data.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }
}
