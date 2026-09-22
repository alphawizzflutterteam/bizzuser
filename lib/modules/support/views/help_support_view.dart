import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page_loader.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/cream_wash_scaffold.dart';
import '../../../core/widgets/pill_header.dart';
import '../../../data/models/support_ticket.dart';
import '../controllers/help_support_controller.dart';

class HelpSupportView extends GetView<HelpSupportController> {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamWashScaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            onPressed: controller.addTicket,
            backgroundColor: AppColors.brandBlack,
            foregroundColor: AppColors.white,
            elevation: 2,
            child: const Icon(Icons.add, color: AppColors.white, size: 28),
          ),
        ),
      ),
      body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: PillHeader(title: AppStrings.helpAndSupport),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isPageLoading.value) {
                    return const AppPageLoader();
                  }
                  final tickets = controller.tickets;
                  if (tickets.isEmpty) {
                    return const Center(
                      child: AppText(
                        text: AppStrings.noTickets,
                        color: AppColors.tabInactive,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                    itemCount: tickets.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return _TicketCard(
                        ticket: ticket,
                        onChat: () => controller.openChat(ticket),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onChat});

  final SupportTicket ticket;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.brandYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 18,
                  color: AppColors.brandBlack,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      text: '${AppStrings.ticketIdPrefix}${ticket.displayCode}',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlack,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: ticket.date,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.tabInactive,
                  maxLines: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  text: ticket.status,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: ticket.title,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.brandBlack,
          ),
          const SizedBox(height: 6),
          AppText(
            text: ticket.description,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.tabInactive,
            height: 1.4,
          ),
          const SizedBox(height: 14),
          AppButton(
            title: AppStrings.chat,
            height: 46,
            borderRadius: 24,
            backgroundColor: AppColors.brandBlack,
            textColor: AppColors.white,
            onPressed: onChat,
          ),
        ],
      ),
    );
  }
}
