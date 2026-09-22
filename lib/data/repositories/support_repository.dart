import '../../core/constants/api_constants.dart';
import '../../core/utils/api_body.dart';
import '../models/legal_content.dart';
import '../models/support_category.dart';
import '../models/support_ticket.dart';
import 'base_repository.dart';

class SupportRepository extends BaseRepository {
  const SupportRepository(super.apiService);

  Future<List<FaqItem>> fetchFaqs() async {
    final json = await apiService.getJson(ApiConstants.supportFaq);
    return ApiBody.dataList(json)
        .where((item) => item['active'] != false)
        .map(FaqItem.fromJson)
        .where((item) => item.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<SupportCategory>> fetchCategories() async {
    final json = await apiService.getJson(ApiConstants.supportCategories);
    return ApiBody.dataList(json)
        .where((item) => item['active'] != false)
        .map(SupportCategory.fromJson)
        .where((item) => item.slug.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<SupportTicket>> fetchTickets() async {
    final json = await apiService.getJson(ApiConstants.supportTickets);
    return ApiBody.dataList(json)
        .map(SupportTicket.fromJson)
        .toList(growable: false);
  }

  Future<SupportTicket> fetchTicket(String id) async {
    final json = await apiService.getJson(ApiConstants.supportTicket(id));
    return SupportTicket.fromJson(ApiBody.dataMap(json));
  }

  Future<SupportTicket> createTicket({
    required String category,
    required String subject,
    required String message,
  }) async {
    final json = await apiService.postJson(ApiConstants.supportTickets, {
      'category': category.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
    });
    return SupportTicket.fromJson(ApiBody.dataMap(json));
  }

  Future<SupportMessage> sendMessage({
    required String ticketId,
    required String text,
  }) async {
    final json = await apiService.postJson(
      ApiConstants.supportTicketMessages(ticketId),
      {'text': text.trim()},
    );
    final map = ApiBody.dataMap(json);
    return SupportMessage.fromJson(map.isEmpty ? json : map);
  }
}
