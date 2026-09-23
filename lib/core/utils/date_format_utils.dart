class DateFormatUtils {
  DateFormatUtils._();

  static const _months = [
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

  static const _monthsLong = [
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

  static DateTime? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim())?.toLocal();
  }

  static String relative(String? raw, {String fallback = ''}) {
    final dt = parse(raw);
    if (dt == null) return fallback;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return mins == 1 ? '1 min ago' : '$mins mins ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }
    if (diff.inDays < 7) {
      final days = diff.inDays;
      return days == 1 ? '1 day ago' : '$days days ago';
    }
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  static String updatedOn(String? raw, {String fallback = ''}) {
    final dt = parse(raw);
    if (dt == null) return fallback;
    return 'Updated On: ${_months[dt.month - 1]} ${dt.year}';
  }

  static String walletDate(String? raw, {String fallback = ''}) {
    final dt = parse(raw);
    if (dt == null) return fallback;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }

  /// `dd MMM yyyy, hh:mm a` in local time, e.g. `05 Mar 2026, 09:07 PM`.
  static String dateTime(String? raw, {String fallback = ''}) {
    final dt = parse(raw);
    if (dt == null) return fallback;
    final day = dt.day.toString().padLeft(2, '0');
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hour = hour12.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day ${_months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }

  static String ticketDate(String? raw, {String fallback = ''}) {
    final dt = parse(raw);
    if (dt == null) return fallback;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${_monthsLong[dt.month - 1]} ${dt.year} | $hour:$minute $period';
  }

  static String chatTime(String? raw, {String fallback = ''}) {
    final dt = parse(raw);
    if (dt == null) return fallback;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
