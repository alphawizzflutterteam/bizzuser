class SupportCategory {
  const SupportCategory({
    this.id = '',
    required this.slug,
    required this.name,
  });

  final String id;
  final String slug;
  final String name;

  factory SupportCategory.fromJson(Map<String, dynamic> json) {
    return SupportCategory(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      slug: (json['slug'] ?? json['key'] ?? json['value'])?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
    );
  }
}
