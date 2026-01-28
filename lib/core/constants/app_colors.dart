import 'package:flutter/material.dart';

/// App color palette - Modern, vibrant colors for students
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Category Colors
  static const Color food = Color(0xFFF97316); // Orange
  static const Color transport = Color(0xFF3B82F6); // Blue
  static const Color hostel = Color(0xFF8B5CF6); // Purple
  static const Color books = Color(0xFF22C55E); // Green
  static const Color subscriptions = Color(0xFFEC4899); // Pink
  static const Color entertainment = Color(0xFFEF4444); // Red
  static const Color other = Color(0xFF6B7280); // Gray

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Get category color by name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return food;
      case 'transport':
        return transport;
      case 'hostel':
        return hostel;
      case 'books':
        return books;
      case 'subscriptions':
        return subscriptions;
      case 'entertainment':
        return entertainment;
      default:
        return other;
    }
  }
}
