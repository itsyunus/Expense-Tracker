import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/budget.dart';
import '../../data/models/budget_model.dart';

/// Provider for budget state
class BudgetNotifier extends StateNotifier<Budget?> {
  final Uuid _uuid = const Uuid();

  BudgetNotifier() : super(null) {
    _loadCurrentMonthBudget();
  }

  Box<BudgetModel> get _box => Hive.box<BudgetModel>('budgets');

  /// Load budget for current month
  void _loadCurrentMonthBudget() {
    final now = DateTime.now();
    final key = BudgetModel.getKey(now.year, now.month);
    final model = _box.get(key);
    state = model?.toEntity();
  }

  /// Set budget for current month
  Future<void> setBudget(double amount) async {
    final now = DateTime.now();
    final key = BudgetModel.getKey(now.year, now.month);
    
    final budget = Budget(
      id: _uuid.v4(),
      amount: amount,
      year: now.year,
      month: now.month,
      createdAt: now,
      updatedAt: now,
    );
    
    final model = BudgetModel.fromEntity(budget);
    await _box.put(key, model);
    state = budget;
  }

  /// Get budget for a specific month
  Budget? getBudgetForMonth(int year, int month) {
    final key = BudgetModel.getKey(year, month);
    final model = _box.get(key);
    return model?.toEntity();
  }

  /// Update budget amount
  Future<void> updateBudget(double amount) async {
    if (state != null) {
      final updated = state!.copyWith(
        amount: amount,
        updatedAt: DateTime.now(),
      );
      final key = BudgetModel.getKey(state!.year, state!.month);
      await _box.put(key, BudgetModel.fromEntity(updated));
      state = updated;
    } else {
      await setBudget(amount);
    }
  }
}

/// Provider for BudgetNotifier
final budgetProvider = StateNotifierProvider<BudgetNotifier, Budget?>((ref) {
  return BudgetNotifier();
});

/// Provider for budget progress (0.0 to 1.0+)
final budgetProgressProvider = Provider<double>((ref) {
  final budget = ref.watch(budgetProvider);
  final spending = ref.watch(monthlySpendingForBudgetProvider);
  
  if (budget == null || budget.amount <= 0) {
    return 0.0;
  }
  
  return spending / budget.amount;
});

/// Provider for monthly spending (for budget calculation)
final monthlySpendingForBudgetProvider = StateProvider<double>((ref) => 0.0);
