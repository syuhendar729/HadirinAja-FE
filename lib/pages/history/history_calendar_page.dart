// File: history_calendar_page.dart
import 'package:flutter/material.dart';

import '../../models/attendance_model.dart';

import '../../widgets/history/attendance_calendar.dart';
import '../../widgets/history/attendance_legend.dart';

class HistoryCalendarPage extends StatelessWidget {
  final int year;
  final int month;

  final List<AttendanceModel> attendances;

  const HistoryCalendarPage({
    super.key,
    required this.year,
    required this.month,
    required this.attendances,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_monthName(month)), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),

        child: Column(
          children: [
            const AttendanceLegend(),

            const SizedBox(height: 70),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                Text('Sun'),
                Text('Mon'),
                Text('Tue'),
                Text('Wed'),
                Text('Thu'),
                Text('Fri'),
                Text('Sat'),
              ],
            ),

            const SizedBox(height: 20),

            AttendanceCalendar(
              year: year,
              month: month,
              attendances: attendances,
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month];
  }
}

