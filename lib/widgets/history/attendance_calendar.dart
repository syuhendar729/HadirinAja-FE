// File: attendance_calendar.dart
import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';

class AttendanceCalendar extends StatelessWidget {
  final int year;
  final int month;

  final List<AttendanceModel> attendances;

  const AttendanceCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.attendances,
  });

  @override
  Widget build(BuildContext context) {
    final cells = _generateCalendarCells();

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: cells.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),

      itemBuilder: (context, index) {
        final date = cells[index];

        if (date == null) {
          return const SizedBox();
        }

        final attendance = _findAttendance(date);

        final isWeekend =
            date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                color: _cellColor(attendance, isWeekend),

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: Colors.grey),
              ),

              child: Center(
                child: Text(
                  attendance?.status.label ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${date.day}',

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }

  List<DateTime?> _generateCalendarCells() {
    final cells = <DateTime?>[];

    final firstDay = DateTime(year, month, 1);

    final totalDays = DateTime(year, month + 1, 0).day;

    final offset = firstDay.weekday % 7;

    for (int i = 0; i < offset; i++) {
      cells.add(null);
    }

    for (int day = 1; day <= totalDays; day++) {
      cells.add(DateTime(year, month, day));
    }

    return cells;
  }

  AttendanceModel? _findAttendance(DateTime date) {
    try {
      return attendances.firstWhere(
        (attendance) =>
            attendance.createdAt?.year == date.year &&
            attendance.createdAt?.month == date.month &&
            attendance.createdAt?.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  Color _cellColor(AttendanceModel? attendance, bool isWeekend) {
    if (attendance != null) {
      return attendance.status.color;
    }

    if (isWeekend) {
      return Colors.grey.shade400;
    }

    return Colors.white;
  }

}
