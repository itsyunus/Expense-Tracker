import 'package:hive/hive.dart';

import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final int year;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.amount,
    required this.year,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to domain entity
  Budget toEntity() {
    return Budget(
      id: id,
      amount: amount,
      year: year,
      month: month,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      amount: budget.amount,
      year: budget.year,
      month: budget.month,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  /// Get unique key for year-month
  static String getKey(int year, int month) => '$year-$month';
}
