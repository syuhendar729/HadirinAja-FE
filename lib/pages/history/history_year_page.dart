import 'package:flutter/material.dart';

import '../../models/attendance_model.dart';

import '../../services/attendance_service.dart';

import '../../utils/attendance_helper.dart';

import '../../widgets/history/year_card.dart';

import 'history_month_page.dart';

class HistoryYearPage extends StatefulWidget {
  const HistoryYearPage({super.key});

  @override
  State<HistoryYearPage> createState() => _HistoryYearPageState();
}

class _HistoryYearPageState extends State<HistoryYearPage> {
  bool isLoading = true;

  Map<int, List<AttendanceModel>> groupedAttendances = {};

  @override
  void initState() {
    super.initState();

    loadAttendances();
  }

  Future<void> loadAttendances() async {
    try {
      final attendances = await AttendanceService.getAttendances();

      final grouped = AttendanceHelper.groupByYear(attendances);

      setState(() {
        groupedAttendances = grouped;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final years = groupedAttendances.keys.toList();

    // descending year
    years.sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('History'), centerTitle: true),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: years.length,

              itemBuilder: (context, index) {
                final year = years[index];

                final attendances = groupedAttendances[year]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),

                  child: YearCard(
                    year: year,

                    totalAttendance: attendances.length,

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => HistoryMonthPage(
                            year: year,

                            attendances: attendances,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
