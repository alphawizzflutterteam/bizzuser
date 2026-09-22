import '../../core/constants/app_strings.dart';
import '../../core/utils/date_format_utils.dart';

class AppNotification {
  const AppNotification({
    this.id = '',
    required this.title,
    required this.body,
    required this.time,
    this.type = '',
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final String type;
  final bool read;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      time: DateFormatUtils.relative(
        json['createdAt']?.toString(),
        fallback: AppStrings.twoMinsAgo,
      ),
      type: json['type']?.toString() ?? '',
      read: json['read'] == true,
    );
  }

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      type: type,
      read: read ?? this.read,
    );
  }
}

class NotificationFeed {
  const NotificationFeed({this.unreadCount = 0, this.items = const []});

  final int unreadCount;
  final List<AppNotification> items;
}
