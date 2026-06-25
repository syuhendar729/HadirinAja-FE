import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';
import '../../widgets/history/attendance_legend.dart';

const _bg = Color(0xFFF7F7F8);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF6B7280);
const _line = Color(0xFFE5E7EB);
const _primary = Color(0xFF2563EB);
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

  void _changeDate({int? month, int? year}) {
    final y = year ?? _focused.year;
    final m = month ?? _focused.month;
    final d = (_selected ?? _focused).day.clamp(1, DateTime(y, m + 1, 0).day);
    setState(() => _selected = _focused = DateTime(y, m, d));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _bg,
        foregroundColor: _ink,
      ),
      body: FutureBuilder<List<AttendanceModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return _message(snap.error.toString());

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _filterBar(),
                const SizedBox(height: 12),
                _summary(),
                const SizedBox(height: 12),
                const AttendanceLegend(),
                const SizedBox(height: 12),
                _calendar(),
                const SizedBox(height: 12),
                _dayList(_selected ?? _focused),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterBar() => _section(
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
        fillColor: _bg,
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
      child: Row(
        children: [
          for (final item in _statuses)
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${_monthItems.where((e) => e.status == item.$1).length}',
                    style: text.titleLarge?.copyWith(
                      color: item.$1.accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$2,
                    style: text.labelMedium?.copyWith(color: _muted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _calendar() => _section(
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
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
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
