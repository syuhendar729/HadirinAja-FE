class DateTimeHelper {
  static String formattedDate() {
    final now = DateTime.now();

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  static String formattedTime() {
    final now = DateTime.now();

    final hour = now.hour.toString().padLeft(2, '0');

    final minute = now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  static String formattedTimeWithPeriod() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
