// File: attendance_legend.dart
import 'package:flutter/material.dart';

class AttendanceLegend extends StatelessWidget {
  const AttendanceLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: const [
        _LegendItem(label: 'Present', color: Colors.green, symbol: 'P'),

        _LegendItem(label: 'Leave', color: Colors.orange, symbol: 'L'),

        _LegendItem(label: 'Alpha', color: Colors.red, symbol: 'A'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final String symbol;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,

          decoration: BoxDecoration(
            color: color.withOpacity(0.2),

            borderRadius: BorderRadius.circular(8),

            border: Border.all(color: color),
          ),

          child: Center(child: Text(symbol)),
        ),

        const SizedBox(width: 8),

        Text(label),
      ],
    );
  }
}


