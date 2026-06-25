import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/attendance_model.dart';

class AttendanceLegend extends StatelessWidget {
  final bool onTeal;

  const AttendanceLegend({super.key, this.onTeal = false});

  @override
  Widget build(BuildContext context) {
    const items = [
      (AttendanceStatus.present, 'Present'),
      (AttendanceStatus.late, 'Late'),
      (AttendanceStatus.leave, 'Leave'),
      (AttendanceStatus.absent, 'Absent'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: onTeal
            ? Colors.white.withValues(alpha: 0.14)
            : const Color(AppColors.card),
        border: Border.all(
          color: onTeal
              ? Colors.white.withValues(alpha: 0.28)
              : const Color(AppColors.border),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              _LegendItem(status: item.$1, label: item.$2, onTeal: onTeal),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final AttendanceStatus status;
  final String label;
  final bool onTeal;

  const _LegendItem({
    required this.status,
    required this.label,
    required this.onTeal,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: status.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: onTeal
                    ? Colors.white
                    : const Color(AppColors.textPrimary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
