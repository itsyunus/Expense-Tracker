import 'package:equatable/equatable.dart';

/// Expense category enum
enum ExpenseCategory {
  food,
  transport,
  hostel,
  books,
  subscriptions,
  entertainment,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.hostel:
        return 'Hostel';
      case ExpenseCategory.books:
        return 'Books';
      case ExpenseCategory.subscriptions:
        return 'Subscriptions';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.food:
        return '🍕';
      case ExpenseCategory.transport:
        return '🚌';
      case ExpenseCategory.hostel:
        return '🏠';
      case ExpenseCategory.books:
        return '📚';
      case ExpenseCategory.subscriptions:
        return '📱';
      case ExpenseCategory.entertainment:
        return '🎮';
      case ExpenseCategory.other:
        return '📦';
    }
  }
}

/// Expense entity
class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? note;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? note,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, date, category, note, isSynced, createdAt, updatedAt];
}
