import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';

/// Provider for ExpenseLocalDataSource
final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSource();
});

/// Provider for ExpenseRepository
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final localDataSource = ref.watch(expenseLocalDataSourceProvider);
  return ExpenseRepositoryImpl(localDataSource: localDataSource);
});

/// State for expenses
class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing expenses
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repository;
  final Uuid _uuid = const Uuid();

  ExpenseNotifier(this._repository) : super(const ExpenseState()) {
    loadExpenses();
  }

  /// Load all expenses
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await _repository.getAllExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load expenses for current month
  Future<void> loadExpensesForCurrentMonth() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final expenses = await _repository.getExpensesByMonth(now.year, now.month);
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new expense
  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? note,
  }) async {
    try {
      final now = DateTime.now();
      final expense = Expense(
        id: _uuid.v4(),
        title: title,
        amount: amount,
        date: date,
        category: category,
        note: note,
        isSynced: false,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.addExpense(expense);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update an existing expense
  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? note,
  }) async {
    try {
      final existingExpense = await _repository.getExpenseById(id);
      if (existingExpense != null) {
        final updatedExpense = existingExpense.copyWith(
          title: title,
          amount: amount,
          date: date,
          category: category,
          note: note,
          isSynced: false,
          updatedAt: DateTime.now(),
        );
        await _repository.updateExpense(updatedExpense);
        await loadExpenses();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get expense by id
  Future<Expense?> getExpenseById(String id) async {
    return await _repository.getExpenseById(id);
  }
}

/// Provider for ExpenseNotifier
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpenseNotifier(repository);
});

/// Provider for total spending this month
final monthlySpendingProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  return await repository.getTotalSpendingByMonth(now.year, now.month);
});

/// Provider for spending by category this month
final categorySpendingProvider = FutureProvider<Map<ExpenseCategory, double>>((ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  return await repository.getSpendingByCategoryForMonth(now.year, now.month);
});
