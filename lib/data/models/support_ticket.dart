import '../../core/constants/app_strings.dart';
import '../../core/utils/date_format_utils.dart';

class SupportMessage {
  const SupportMessage({
    this.id = '',
    required this.text,
    required this.isMine,
    required this.time,
  });

  final String id;
  final String text;
  final bool isMine;
  final String time;

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    final role = json['fromRole']?.toString().toLowerCase() ?? '';
    return SupportMessage(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isMine: role == 'user',
      time: DateFormatUtils.chatTime(json['createdAt']?.toString()),
    );
  }
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.date,
    required this.status,
    required this.title,
    required this.description,
    this.ticketCode = '',
    this.category = '',
    this.messages = const [],
  });

  final String id;
  final String date;
  final String status;
  final String title;
  final String description;
  final String ticketCode;
  final String category;
  final List<SupportMessage> messages;

  String get displayCode => ticketCode.isNotEmpty ? ticketCode : id;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] is List
        ? (json['messages'] as List)
              .whereType<Map>()
              .map(
                (item) => SupportMessage.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <SupportMessage>[];

    return SupportTicket(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      ticketCode: json['ticketCode']?.toString() ?? '',
      date: DateFormatUtils.ticketDate(
        json['createdAt']?.toString(),
        fallback: AppStrings.ticketDate,
      ),
      status: (json['statusLabel'] ?? json['status'])?.toString() ??
          AppStrings.pending,
      title: json['subject']?.toString() ?? '',
      description: json['message']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      messages: messages,
    );
  }
}
