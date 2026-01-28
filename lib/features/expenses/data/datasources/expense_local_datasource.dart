import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense_model.dart';

/// Local data source for expenses using Hive
class ExpenseLocalDataSource {
  static const String _boxName = 'expenses';

  Box<ExpenseModel> get _box => Hive.box<ExpenseModel>(_boxName);

  /// Get all expenses
  List<ExpenseModel> getAllExpenses() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expenses for a specific month
  List<ExpenseModel> getExpensesByMonth(int year, int month) {
    return _box.values.where((expense) {
      return expense.date.year == year && expense.date.month == month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expenses for a date range
  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _box.values.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expenses by category
  List<ExpenseModel> getExpensesByCategory(int categoryIndex) {
    return _box.values.where((expense) {
      return expense.categoryIndex == categoryIndex;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get a single expense by id
  ExpenseModel? getExpenseById(String id) {
    try {
      return _box.values.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new expense
  Future<void> addExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  /// Update an existing expense
  Future<void> updateExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  /// Get unsynced expenses
  List<ExpenseModel> getUnsyncedExpenses() {
    return _box.values.where((expense) => !expense.isSynced).toList();
  }

  /// Mark expense as synced
  Future<void> markAsSynced(String id) async {
    final expense = getExpenseById(id);
    if (expense != null) {
      final updated = ExpenseModel(
        id: expense.id,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        categoryIndex: expense.categoryIndex,
        note: expense.note,
        isSynced: true,
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
      );
      await _box.put(id, updated);
    }
  }

  /// Get total spending for a month
  double getTotalSpendingByMonth(int year, int month) {
    final expenses = getExpensesByMonth(year, month);
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get spending by category for a month
  Map<int, double> getSpendingByCategoryForMonth(int year, int month) {
    final expenses = getExpensesByMonth(year, month);
    final Map<int, double> categorySpending = {};
    
    for (final expense in expenses) {
      categorySpending[expense.categoryIndex] = 
          (categorySpending[expense.categoryIndex] ?? 0) + expense.amount;
    }
    
    return categorySpending;
  }
}
