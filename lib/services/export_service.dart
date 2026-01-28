import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../features/expenses/data/models/expense_model.dart';
import '../features/expenses/domain/entities/expense.dart';

/// Service for exporting data to CSV and PDF
class ExportService {
  final _dateFormat = DateFormat('yyyy-MM-dd');

  /// Get all expenses from Hive
  List<ExpenseModel> _getExpenses() {
    final box = Hive.box<ExpenseModel>('expenses');
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Export expenses to CSV (returns CSV string content)
  Future<String?> exportToCSV() async {
    final expenses = _getExpenses();
    if (expenses.isEmpty) return null;

    // Create CSV data
    final List<List<dynamic>> rows = [
      ['Title', 'Amount', 'Category', 'Date', 'Note'],
      ...expenses.map((e) => [
        e.title,
        e.amount.toStringAsFixed(2),
        ExpenseCategory.values[e.categoryIndex].displayName,
        _dateFormat.format(e.date),
        e.note ?? '',
      ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    
    // For web, return the CSV content directly
    // For mobile builds, you would save to file instead
    return csv;
  }

  /// Export expenses to PDF (placeholder - requires native platform)
  Future<String?> exportToPDF() async {
    final expenses = _getExpenses();
    if (expenses.isEmpty) return null;

    // PDF export requires native platform support
    // For web, this returns null
    if (kIsWeb) {
      return null;
    }

    // For native platforms, implement PDF generation here
    return null;
  }

  /// Share a file (placeholder)
  Future<void> shareFile(String filePath) async {
    // Share functionality requires native platform
    if (kIsWeb) {
      return;
    }
    
    // For native platforms, implement sharing here
  }
}
