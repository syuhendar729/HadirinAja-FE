import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/app_config.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';
import '../../widgets/history/attendance_legend.dart';

const _teal = Color(AppColors.primary);
const _ink = Color(AppColors.textPrimary);
const _muted = Color(AppColors.textSecondary);
const _line = Color(AppColors.border);
const _primary = Color(AppColors.primary);
const _days = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
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
const _statuses = [
  (AttendanceStatus.present, 'Present', 'P'),
  (AttendanceStatus.late, 'Late', 'L'),
  (AttendanceStatus.leave, 'Leave', 'LV'),
  (AttendanceStatus.absent, 'Absent', 'A'),
];

class HistoryYearPage extends StatefulWidget {
  const HistoryYearPage({super.key});

  @override
  State<HistoryYearPage> createState() => _HistoryYearPageState();
}

class _HistoryYearPageState extends State<HistoryYearPage> {
  late final Future<List<AttendanceModel>> _future = _load();
  List<AttendanceModel> _items = [];
  Map<DateTime, List<AttendanceModel>> _byDate = {};
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<List<AttendanceModel>> _load() async {
    final items = await AttendanceService.getAttendances();
    final grouped = <DateTime, List<AttendanceModel>>{};
    for (final item in items.where((e) => e.createdAt != null)) {
      grouped.putIfAbsent(_day(item.createdAt!), () => []).add(item);
    }

    if (mounted) {
      final latest = items
          .where((e) => e.createdAt != null)
          .fold<DateTime?>(
            null,
            (date, item) => date == null || item.createdAt!.isAfter(date)
                ? item.createdAt
                : date,
          );
      setState(() {
        _items = items;
        _byDate = grouped;
        _focused = _day(latest ?? DateTime.now());
        _selected = _focused;
      });
    }
    return items;
  }

  List<int> get _years {
    final years =
        _items
            .where((e) => e.createdAt != null)
            .map((e) => e.createdAt!.year)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));
    return years.contains(DateTime.now().year)
        ? years
        : [DateTime.now().year, ...years];
  }

  List<AttendanceModel> _events(DateTime date) => _byDate[_day(date)] ?? [];

  List<AttendanceModel> get _monthItems => _items
      .where(
        (e) =>
            e.createdAt?.year == _focused.year &&
            e.createdAt?.month == _focused.month,
      )
      .toList();

  double get _presentRate {
    final workdays = _workdaysInMonth(_focused);
    if (workdays == 0) return 0;
    final present = _monthItems
        .where((e) => e.status == AttendanceStatus.present)
        .length;
    return (present / workdays).clamp(0, 1);
  }

  int _workdaysInMonth(DateTime date) {
    final now = DateTime.now();
    final lastDay = date.year == now.year && date.month == now.month
        ? now.day
        : DateTime(date.year, date.month + 1, 0).day;

    return List.generate(
      lastDay,
      (i) => DateTime(date.year, date.month, i + 1),
    ).where((day) => day.weekday <= DateTime.friday).length;
  }

  void _changeDate({int? month, int? year}) {
    final y = year ?? _focused.year;
    final m = month ?? _focused.month;
    final d = (_selected ?? _focused).day.clamp(1, DateTime(y, m + 1, 0).day);
    setState(() => _selected = _focused = DateTime(y, m, d));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teal,
      body: FutureBuilder<List<AttendanceModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snap.hasError) return _message(snap.error.toString());

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.50,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
                      child: Column(
                        children: [
                          Text(
                            'History',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          _filterBar(),
                          const SizedBox(height: 10),
                          _summary(),
                          const SizedBox(height: 10),
                          _attendanceRate(),
                          const SizedBox(height: 10),
                          const AttendanceLegend(onTeal: true),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height * 0.50,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 34, 16, 130),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(56),
                    ),
                  ),
                  child: Column(
                    children: [
                      _calendar(),
                      const SizedBox(height: 12),
                      _dayList(_selected ?? _focused),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterBar() => _section(
    onTeal: true,
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Expanded(
          child: _picker<int>(
            value: _focused.month,
            items: List.generate(12, (i) => i + 1),
            label: (m) => _months[m],
            onChanged: (m) => _changeDate(month: m),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 116,
          child: _picker<int>(
            value: _focused.year,
            items: _years,
            label: (y) => '$y',
            onChanged: (y) => _changeDate(year: y),
          ),
        ),
      ],
    ),
  );

  Widget _picker<T>({
    required T value,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item,
            child: Text(label(item), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  Widget _summary() {
    final text = Theme.of(context).textTheme;
    return _section(
      onTeal: true,
      child: Row(
        children: [
          for (final item in _statuses)
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${_monthItems.where((e) => e.status == item.$1).length}',
                    style: text.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$2,
                    style: text.labelMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _attendanceRate() {
    final text = Theme.of(context).textTheme;
    final percent = (_presentRate * 100).round();

    return _section(
      onTeal: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attendance Rate',
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: text.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _presentRate,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendar() => _section(
    border: false,
    padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
    child: TableCalendar<AttendanceModel>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2035, 12, 31),
      focusedDay: _focused,
      selectedDayPredicate: (day) => isSameDay(_selected, day),
      eventLoader: _events,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerVisible: false,
      rowHeight: 50,
      daysOfWeekHeight: 30,
      onDaySelected: (selected, focused) => setState(() {
        _selected = _day(selected);
        _focused = focused;
      }),
      onPageChanged: (focused) => setState(() {
        _focused = focused;
        _selected = _day(focused);
      }),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: _muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: _muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: const EdgeInsets.all(3),
        defaultDecoration: _dateDecoration(),
        weekendDecoration: _dateDecoration(),
        todayDecoration: _dateDecoration(color: const Color(0xFFEFF6FF)),
        selectedDecoration: _dateDecoration(
          color: const Color(0xFFEFF6FF),
          border: Border.all(color: _primary),
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, items) => items.isEmpty
            ? null
            : Positioned(
                bottom: 7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: items.first.status.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
      ),
    ),
  );

  Widget _dayList(DateTime date) {
    final text = Theme.of(context).textTheme;
    final items = _events(date);

    return _section(
      border: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_days[date.weekday - 1]}, ${date.day} ${_months[date.month]} ${date.year}',
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'No attendance record for this date.',
              style: text.bodyMedium?.copyWith(color: _muted),
            )
          else
            for (final item in items) _attendanceTile(item),
        ],
      ),
    );
  }

  Widget _attendanceTile(AttendanceModel item) {
    final text = Theme.of(context).textTheme;
    final time = item.createdAt == null
        ? '-'
        : '${item.createdAt!.hour.toString().padLeft(2, '0')}:${item.createdAt!.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: item.status.color,
            child: Text(
              _statusInitial(item.status),
              style: text.labelMedium?.copyWith(
                color: item.status.foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusName(item.status),
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  item.notes?.isNotEmpty == true
                      ? item.notes!
                      : item.location ?? 'No notes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: _muted),
                ),
              ],
            ),
          ),
          Text(time, style: text.labelLarge?.copyWith(color: _muted)),
        ],
      ),
    );
  }

  String _statusInitial(AttendanceStatus status) =>
      _statuses.firstWhere((e) => e.$1 == status).$3;

  String _statusName(AttendanceStatus status) => switch (status) {
    AttendanceStatus.present => 'Present',
    AttendanceStatus.late => 'Late',
    AttendanceStatus.leave => 'Leave',
    AttendanceStatus.absent => 'Absent',
  };

  Widget _section({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    bool onTeal = false,
    bool border = true,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: onTeal
            ? Colors.white.withValues(alpha: 0.14)
            : const Color(AppColors.background),
        border: border
            ? Border.all(
                color: onTeal ? Colors.white.withValues(alpha: 0.28) : _line,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  BoxDecoration _dateDecoration({Color? color, BoxBorder? border}) {
    return BoxDecoration(
      color: color ?? Colors.transparent,
      border: border,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
      ),
    ),
  );
}
