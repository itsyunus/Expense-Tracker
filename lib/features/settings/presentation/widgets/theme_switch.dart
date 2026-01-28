import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

/// Animated theme switch widget
class AnimatedThemeSwitch extends ConsumerStatefulWidget {
  const AnimatedThemeSwitch({super.key});

  @override
  ConsumerState<AnimatedThemeSwitch> createState() => _AnimatedThemeSwitchState();
}

class _AnimatedThemeSwitchState extends ConsumerState<AnimatedThemeSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbAnimation;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _thumbAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _iconRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = ref.read(themeModeProvider) == ThemeMode.dark;
    if (isDark) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    HapticFeedback.mediumImpact();
    ref.read(themeModeProvider.notifier).toggleTheme();
    
    if (_controller.value == 0) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: _toggleTheme,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.primaryLight : AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Stars (visible in dark mode)
                if (isDark) ...[
                  Positioned(
                    left: 8,
                    top: 6,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_thumbAnimation.value * 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 12,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_thumbAnimation.value * 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 20,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_thumbAnimation.value * 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
                // Clouds (visible in light mode)
                if (!isDark)
                  Positioned(
                    right: 8,
                    top: 10,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Container(
                          width: 6,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Thumb with icon
                Positioned(
                  left: _thumbAnimation.value * 28 + 2,
                  top: 2,
                  child: Transform.rotate(
                    angle: _iconRotation.value * 3.14159,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isDark ? Icons.nightlight_round : Icons.wb_sunny,
                        size: 16,
                        color: isDark 
                            ? const Color(0xFF1E293B) 
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
