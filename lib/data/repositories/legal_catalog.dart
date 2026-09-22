import '../../core/constants/app_strings.dart';
import '../models/legal_content.dart';

class LegalCatalog {
  LegalCatalog._();

  static const List<LegalSection> sections = [
    LegalSection(
      title: AppStrings.dataCollection,
      body: AppStrings.legalSectionBody,
    ),
    LegalSection(
      title: AppStrings.dataUsage,
      body: AppStrings.legalSectionBody,
    ),
    LegalSection(
      title: AppStrings.dataSecurity,
      body: AppStrings.legalSectionBody,
    ),
    LegalSection(
      title: AppStrings.thirdPartyServices,
      body: AppStrings.legalSectionBody,
    ),
    LegalSection(
      title: AppStrings.userRights,
      body: AppStrings.legalSectionBody,
    ),
    LegalSection(
      title: AppStrings.contactInformation,
      body: AppStrings.legalSectionBody,
    ),
  ];

  static const List<FaqItem> faqs = [
    FaqItem(title: AppStrings.faqItemTitle, answer: AppStrings.faqItemAnswer),
    FaqItem(title: AppStrings.faqItemTitle, answer: AppStrings.faqItemAnswer),
    FaqItem(title: AppStrings.faqItemTitle, answer: AppStrings.faqItemAnswer),
    FaqItem(title: AppStrings.faqItemTitle, answer: AppStrings.faqItemAnswer),
    FaqItem(title: AppStrings.faqItemTitle, answer: AppStrings.faqItemAnswer),
  ];
}
