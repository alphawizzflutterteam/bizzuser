import '../../core/constants/app_strings.dart';
import '../../core/utils/date_format_utils.dart';

class ChatMessage {
  const ChatMessage({
    this.id = '',
    this.rideId = '',
    required this.text,
    required this.isMine,
    required this.time,
  });

  final String id;
  final String rideId;
  final String text;
  final bool isMine;
  final String time;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role =
        (json['fromRole'] ?? json['role'] ?? json['senderRole'])
            ?.toString()
            .toLowerCase() ??
        '';
    final mine =
        role == 'user' ||
        role == 'rider' ||
        json['isMine'] == true ||
        json['mine'] == true;
    final nested = json['ride'];
    final nestedId = nested is Map
        ? (nested['_id'] ?? nested['id'])?.toString().trim() ?? ''
        : '';
    return ChatMessage(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      rideId: (json['rideId'] ?? json['ride_id'] ?? nestedId)
          .toString()
          .trim(),
      text: (json['text'] ?? json['message'] ?? json['body'])?.toString().trim() ??
          '',
      isMine: mine,
      time: DateFormatUtils.chatTime(
        json['createdAt']?.toString(),
        fallback: AppStrings.chatTime,
      ),
    );
  }
}
