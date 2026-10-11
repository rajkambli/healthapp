import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static final DateFormat _dashboardHeaderFormat = DateFormat('EEEE, d MMMM y');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, h:mm a');

  /// Formats date as 'Sunday, 11 October 2026'
  static String formatDashboardDate(DateTime date) {
    return _dashboardHeaderFormat.format(date);
  }

  /// Formats time as '10:30 PM'
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Formats date and time as 'Oct 11, 10:30 PM'
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Formats duration as 'Xh Ym' (e.g. 7h 30m, 45m, 8h 0m)
  static String formatDurationHoursMinutes(Duration duration) {
    final totalMinutes = duration.inMinutes;
    if (totalMinutes <= 0) return '0m';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Formats last-updated time for the offline banner
  static String formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return '$mins min${mins > 1 ? 's' : ''} ago';
    } else if (diff.inHours < 24 && dateTime.day == now.day) {
      return 'Today at ${formatTime(dateTime)}';
    } else {
      return _dateTimeFormat.format(dateTime);
    }
  }

  /// Normalizes date to midnight UTC/Local for day-to-day comparisons
  static DateTime dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }
}
