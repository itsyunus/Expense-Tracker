import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../expenses/domain/entities/expense.dart';

/// Animated pie chart widget for category breakdown
class PieChartWidget extends StatefulWidget {
  final Map<ExpenseCategory, double> categoryData;
  final double totalSpending;

  const PieChartWidget({
    super.key,
    required this.categoryData,
    required this.totalSpending,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;
  final _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _buildSections(),
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          ),
        ),
        const SizedBox(height: 20),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final entries = widget.categoryData.entries.toList();
    return List.generate(entries.length, (index) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final entry = entries[index];
      final percentage = (entry.value / widget.totalSpending * 100).toStringAsFixed(1);
      final color = AppColors.getCategoryColor(entry.key.name);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: isTouched ? '$percentage%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched 
            ? null 
            : Text(
                entry.key.icon,
                style: const TextStyle(fontSize: 16),
              ),
        badgePositionPercentageOffset: 0.5,
      );
    });
  }

  Widget _buildLegend() {
    final entries = widget.categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        final color = AppColors.getCategoryColor(entry.key.name);
        final percentage = (entry.value / widget.totalSpending * 100).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.key.icon} ${entry.key.displayName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                _currencyFormat.format(entry.value),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
