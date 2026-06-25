import '../models/attendance_model.dart';

class AttendanceHelper {
  // =========================
  // GROUP BY YEAR
  // =========================

  static Map<int, List<AttendanceModel>> groupByYear(
    List<AttendanceModel> attendances,
  ) {
    final Map<int, List<AttendanceModel>> grouped = {};

    for (final attendance in attendances) {
      final year = attendance.createdAt!.year;

      if (!grouped.containsKey(year)) {
        grouped[year] = [];
      }

      grouped[year]!.add(attendance);
    }

    return grouped;
  }

  // =========================
  // GROUP BY MONTH
  // =========================

  static Map<int, List<AttendanceModel>> groupByMonth(
    List<AttendanceModel> attendances,
  ) {
    final Map<int, List<AttendanceModel>> grouped = {};

    for (final attendance in attendances) {
      final month = attendance.createdAt!.month;

      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }

      grouped[month]!.add(attendance);
    }

    return grouped;
  }

  // =========================
  // COUNT PRESENT
  // =========================

  static int countPresent(List<AttendanceModel> attendances) {
    return attendances.where((attendance) {
      return attendance.status == AttendanceStatus.present;
    }).length;
  }

  // =========================
  // COUNT LATE
  // =========================

  static int countLate(List<AttendanceModel> attendances) {
    return attendances.where((attendance) {
      return attendance.status == AttendanceStatus.late;
    }).length;
  }

  // =========================
  // COUNT LEAVE
  // =========================

  static int countLeave(List<AttendanceModel> attendances) {
    return attendances.where((attendance) {
      return attendance.status == AttendanceStatus.leave;
    }).length;
  }

  // =========================
  // COUNT ABSENT
  // =========================

  static int countAbsent(List<AttendanceModel> attendances) {
    return attendances.where((attendance) {
      return attendance.status == AttendanceStatus.absent;
    }).length;
  }

  // =========================
  // WEEKDAY ONLY
  // =========================

  static List<AttendanceModel> weekdayOnly(List<AttendanceModel> attendances) {
    return attendances.where((attendance) {
      final weekday = attendance.createdAt!.weekday;

      // Monday = 1
      // Friday = 5

      return weekday >= 1 && weekday <= 5;
    }).toList();
  }

  // =========================
  // MONTH NAME
  // =========================

  static String getMonthName(int month) {
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

  // =========================
  // GET MONTH ATTENDANCES
  // =========================

  static List<AttendanceModel> filterByMonth({
    required List<AttendanceModel> attendances,

    required int month,
  }) {
    return attendances.where((attendance) {
      return attendance.createdAt!.month == month;
    }).toList();
  }

  // =========================
  // TOTAL WEEKDAYS
  // =========================

  static int totalWeekdaysInMonth({required int year, required int month}) {
    int total = 0;

    final lastDay = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= lastDay; day++) {
      final date = DateTime(year, month, day);

      final weekday = date.weekday;

      if (weekday >= 1 && weekday <= 5) {
        total++;
      }
    }

    return total;
  }
}
