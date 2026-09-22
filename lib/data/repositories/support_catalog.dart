import '../../core/constants/app_strings.dart';
import '../models/support_category.dart';
import '../models/support_ticket.dart';

class SupportCatalog {
  SupportCatalog._();

  static const List<SupportTicket> tickets = [
    SupportTicket(
      id: AppStrings.ticketIdValue,
      ticketCode: AppStrings.ticketIdValue,
      date: AppStrings.ticketDate,
      status: AppStrings.pending,
      title: AppStrings.lostAndFoundRequest,
      description: AppStrings.ticketDescription,
    ),
  ];

  static const List<SupportCategory> categories = [
    SupportCategory(slug: 'lost_found', name: AppStrings.lostAndFound),
    SupportCategory(slug: 'payment', name: AppStrings.paymentIssue),
    SupportCategory(slug: 'ride', name: AppStrings.rideIssue),
  ];
}
