import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/budget/data/models/budget_model.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive
    await Hive.initFlutter();

    // Register Hive Adapters
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());
    Hive.registerAdapter(BudgetModelAdapter());

    // Open Hive Boxes
    await Hive.openBox<ExpenseModel>('expenses');
    await Hive.openBox<BudgetModel>('budgets');
    await Hive.openBox('settings');

    // Set preferred orientations (only for mobile)
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }

    runApp(
      const ProviderScope(
        child: ExpenseTrackerApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print(stackTrace);
    // Run a fallback app to show the error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Failed to initialize app:\n$e\n\n$stackTrace',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
