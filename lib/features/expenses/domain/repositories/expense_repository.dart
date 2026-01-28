import '../entities/expense.dart';

/// Abstract repository interface for expenses
abstract class ExpenseRepository {
  /// Get all expenses
  Future<List<Expense>> getAllExpenses();

  /// Get expenses for a specific month
  Future<List<Expense>> getExpensesByMonth(int year, int month);

  /// Get expenses for a date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category);

  /// Get a single expense by id
  Future<Expense?> getExpenseById(String id);

  /// Add a new expense
  Future<void> addExpense(Expense expense);

  /// Update an existing expense
  Future<void> updateExpense(Expense expense);

  /// Delete an expense
  Future<void> deleteExpense(String id);

  /// Sync expenses with remote
  Future<void> syncExpenses();

  /// Get total spending for a month
  Future<double> getTotalSpendingByMonth(int year, int month);

  /// Get spending by category for a month
  Future<Map<ExpenseCategory, double>> getSpendingByCategoryForMonth(int year, int month);
}
