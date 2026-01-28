import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_colors.dart';

/// Empty state widget with Lottie animation
class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final String? lottieAsset;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation or default icon
            _buildAnimationWidget(),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: () => onAction?.call(),
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationWidget() {
    if (lottieAsset != null) {
      return Lottie.asset(
        lottieAsset!,
        width: 200,
        height: 200,
        repeat: true,
      );
    } else {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.receipt_long_outlined,
          size: 60,
          color: AppColors.primary.withOpacity(0.6),
        ),
      );
    }
  }
}
