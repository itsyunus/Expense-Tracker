import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

/// Animated bar chart widget for daily spending
class BarChartWidget extends StatefulWidget {
  final Map<DateTime, double> dailyData;

  const BarChartWidget({
    super.key,
    required this.dailyData,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final entries = widget.dailyData.entries.toList();
    final maxY = entries.isEmpty 
        ? 1000.0 
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

    // Limit to last 7 days for readability
    final displayEntries = entries.length > 7 
        ? entries.sublist(entries.length - 7) 
        : entries;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => isDarkMode 
                  ? AppColors.surfaceDark 
                  : AppColors.surfaceLight,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = displayEntries[group.x.toInt()];
                final dateFormat = DateFormat('MMM d');
                return BarTooltipItem(
                  '${dateFormat.format(entry.key)}\n₹${entry.value.toStringAsFixed(0)}',
                  TextStyle(
                    color: isDarkMode 
                        ? AppColors.textPrimaryDark 
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    barTouchResponse == null ||
                    barTouchResponse.spot == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
              });
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= displayEntries.length) {
                    return const SizedBox();
                  }
                  final entry = displayEntries[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('E').format(entry.key),
                      style: TextStyle(
                        color: isDarkMode 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  return Text(
                    '₹${(value / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(
                      color: isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondaryLight,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _buildBarGroups(displayEntries, maxY),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode 
                    ? AppColors.borderDark.withOpacity(0.5) 
                    : AppColors.borderLight,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          maxY: maxY,
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<MapEntry<DateTime, double>> entries,
    double maxY,
  ) {
    return List.generate(entries.length, (index) {
      final isTouched = index == touchedIndex;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entries[index].value,
            color: isTouched ? AppColors.primary : AppColors.primary.withOpacity(0.7),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ],
      );
    });
  }
}
