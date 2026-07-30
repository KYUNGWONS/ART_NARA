class BrandValue {
  const BrandValue({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.reasons,
    required this.trustTags,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
  });

  final String title;
  final String description;
  final String imageUrl;
  final List<BrandReason> reasons;
  final List<String> trustTags;
  final String primaryActionLabel;
  final String secondaryActionLabel;

  factory BrandValue.fromJson(Map<String, dynamic> json) {
    final reasons = json['reasons'] is List
        ? (json['reasons'] as List)
            .whereType<Map<String, dynamic>>()
            .map(BrandReason.fromJson)
            .toList()
        : const <BrandReason>[];
    final tags = json['trustTags'] is List
        ? (json['trustTags'] as List).whereType<String>().toList()
        : const <String>[];
    return BrandValue(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      reasons: reasons,
      trustTags: tags,
      primaryActionLabel: json['primaryActionLabel'] as String? ?? '',
      secondaryActionLabel: json['secondaryActionLabel'] as String? ?? '',
    );
  }
}

class BrandReason {
  const BrandReason({required this.title, required this.description});

  final String title;
  final String description;

  factory BrandReason.fromJson(Map<String, dynamic> json) {
    return BrandReason(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
