import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../budget/presentation/widgets/budget_progress_ring.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ref.read(expenseProvider.notifier).loadExpenses();
    _updateBudgetSpending();
  }

  void _updateBudgetSpending() {
    final expenses = ref.read(expenseProvider).expenses;
    final now = DateTime.now();
    final monthlySpending = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
    ref.read(monthlySpendingForBudgetProvider.notifier).state = monthlySpending;
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final budget = ref.watch(budgetProvider);
    final monthlySpending = ref.watch(monthlySpendingForBudgetProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Update spending when expenses change
    ref.listen(expenseProvider, (previous, next) {
      _updateBudgetSpending();
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                title: Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: Show notifications
                    },
                  ),
                ],
              ),

              // Budget Progress Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [AppColors.surfaceDark, AppColors.backgroundDark]
                          : [AppColors.primary.withOpacity(0.1), AppColors.surfaceLight],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(DateTime.now()),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDarkMode 
                                      ? AppColors.textSecondaryDark 
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currencyFormat.format(monthlySpending),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'spent this month',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          BudgetProgressRing(
                            spent: monthlySpending,
                            budget: budget?.amount ?? 0,
                            size: 80,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Expenses Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Expenses',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: View all expenses
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              // Expenses List
              if (expenseState.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (expenseState.expenses.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    title: AppStrings.noExpenses,
                    description: AppStrings.noExpensesDesc,
                    actionText: AppStrings.addExpense,
                    onAction: () => context.push(RoutePaths.addExpense),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = expenseState.expenses[index];
                        return ExpenseCard(
                          expense: expense,
                          onTap: () => _editExpense(expense),
                          onDelete: () => _deleteExpense(expense),
                        );
                      },
                      childCount: expenseState.expenses.length.clamp(0, 20),
                    ),
                  ),
                ),

              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editExpense(Expense expense) {
    HapticFeedback.lightImpact();
    context.push('/edit-expense/${expense.id}');
  }

  Future<void> _deleteExpense(Expense expense) async {
    HapticFeedback.mediumImpact();
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteExpense),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await ref.read(expenseProvider.notifier).deleteExpense(expense.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppStrings.expenseDeleted),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
