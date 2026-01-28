import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Animated budget progress ring widget
class BudgetProgressRing extends StatefulWidget {
  final double spent;
  final double budget;
  final double size;
  final double strokeWidth;

  const BudgetProgressRing({
    super.key,
    required this.spent,
    required this.budget,
    this.size = 120,
    this.strokeWidth = 10,
  });

  @override
  State<BudgetProgressRing> createState() => _BudgetProgressRingState();
}

class _BudgetProgressRingState extends State<BudgetProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _updateAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(BudgetProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spent != widget.spent || oldWidget.budget != widget.budget) {
      _previousProgress = _progressAnimation.value;
      _updateAnimation();
      _controller.forward(from: 0);
    }
  }

  void _updateAnimation() {
    final targetProgress = widget.budget > 0 
        ? (widget.spent / widget.budget).clamp(0.0, 1.5) 
        : 0.0;
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: targetProgress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return AppColors.error;
    } else if (progress >= 0.8) {
      return AppColors.warning;
    } else {
      return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final color = _getProgressColor(progress);
        final percentage = (progress * 100).clamp(0, 999).toInt();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  color: isDarkMode 
                      ? AppColors.borderDark 
                      : AppColors.borderLight,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: progress.clamp(0.0, 1.0),
                  color: color,
                  strokeWidth: widget.strokeWidth,
                  hasGlow: true,
                ),
              ),
              // Percentage text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: widget.size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'used',
                    style: TextStyle(
                      fontSize: widget.size * 0.1,
                      color: isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasGlow;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (hasGlow) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
