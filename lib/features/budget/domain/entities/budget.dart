import 'package:equatable/equatable.dart';

/// Budget entity
class Budget extends Equatable {
  final String id;
  final double amount;
  final int year;
  final int month;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.amount,
    required this.year,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  Budget copyWith({
    String? id,
    double? amount,
    int? year,
    int? month,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      year: year ?? this.year,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, amount, year, month, createdAt, updatedAt];
}
