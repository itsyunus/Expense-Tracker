import 'package:hive/hive.dart';

import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int categoryIndex;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final bool isSynced;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryIndex,
    this.note,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to domain entity
  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: ExpenseCategory.values[categoryIndex],
      note: note,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      categoryIndex: expense.category.index,
      note: expense.note,
      isSynced: expense.isSynced,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryIndex': categoryIndex,
      'note': note,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      categoryIndex: json['categoryIndex'] as int,
      note: json['note'] as String?,
      isSynced: json['isSynced'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
