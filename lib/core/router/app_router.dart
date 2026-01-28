import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/expenses/presentation/screens/expense_list_screen.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/main_shell.dart';

/// Route paths
class RoutePaths {
  static const String home = '/';
  static const String analytics = '/analytics';
  static const String budget = '/budget';
  static const String settings = '/settings';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense/:id';
}

/// App router configuration with animations
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExpenseListScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.analytics,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AnalyticsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.budget,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BudgetScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: RoutePaths.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.addExpense,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddExpenseScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RoutePaths.editExpense,
        pageBuilder: (context, state) {
          final expenseId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddExpenseScreen(expenseId: expenseId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
});
