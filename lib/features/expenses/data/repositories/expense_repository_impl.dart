import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

/// Implementation of ExpenseRepository
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;

  ExpenseRepositoryImpl({
    required ExpenseLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<Expense>> getAllExpenses() async {
    final models = _localDataSource.getAllExpenses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    final models = _localDataSource.getExpensesByMonth(year, month);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final models = _localDataSource.getExpensesByDateRange(start, end);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final models = _localDataSource.getExpensesByCategory(category.index);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    final model = _localDataSource.getExpenseById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _localDataSource.addExpense(model);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _localDataSource.updateExpense(model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _localDataSource.deleteExpense(id);
  }

  @override
  Future<void> syncExpenses() async {
    // TODO: Implement Firebase sync when Firebase is configured
    // For now, just mark all as synced locally
    final unsyncedModels = _localDataSource.getUnsyncedExpenses();
    for (final model in unsyncedModels) {
      await _localDataSource.markAsSynced(model.id);
    }
  }

  @override
  Future<double> getTotalSpendingByMonth(int year, int month) async {
    return _localDataSource.getTotalSpendingByMonth(year, month);
  }

  @override
  Future<Map<ExpenseCategory, double>> getSpendingByCategoryForMonth(int year, int month) async {
    final categorySpending = _localDataSource.getSpendingByCategoryForMonth(year, month);
    return categorySpending.map(
      (key, value) => MapEntry(ExpenseCategory.values[key], value),
    );
  }
}
