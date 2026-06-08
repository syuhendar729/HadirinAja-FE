import 'package:flutter/material.dart';

import '../../models/attendance_model.dart';

import '../../utils/attendance_helper.dart';

import '../../widgets/history/month_card.dart';

import 'history_calendar_page.dart';

class HistoryMonthPage extends StatelessWidget {
  final int year;

  final List<AttendanceModel> attendances;

  const HistoryMonthPage({
    super.key,
    required this.year,
    required this.attendances,
  });

  @override
  Widget build(BuildContext context) {
    final groupedMonths = AttendanceHelper.groupByMonth(attendances);

    final months = groupedMonths.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(year.toString()), centerTitle: true),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),

        itemCount: months.length,

        itemBuilder: (context, index) {
          final month = months[index];

          final monthAttendances = groupedMonths[month]!;

          final totalPresent = AttendanceHelper.countPresent(monthAttendances);

          final totalDays = AttendanceHelper.totalWeekdaysInMonth(
            year: year,
            month: month,
          );

          return MonthCard(
            monthName: AttendanceHelper.getMonthName(month),
            totalPresent: totalPresent,
            totalDays: totalDays,

            onTap: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => HistoryCalendarPage(
                    year: year,
                    month: month,
                    attendances: monthAttendances,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
