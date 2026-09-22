class LegalSection {
  const LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

class FaqItem {
  const FaqItem({required this.title, required this.answer});

  final String title;
  final String answer;

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      title: (json['question'] ?? json['title'])?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }
}
