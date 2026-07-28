class BrandIntro {
  const BrandIntro({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
  });

  final String title;
  final String description;
  final String imageUrl;
  final String primaryActionLabel;
  final String secondaryActionLabel;

  factory BrandIntro.fromJson(Map<String, dynamic> json) {
    return BrandIntro(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      primaryActionLabel: json['primaryActionLabel'] as String? ?? '시작하기',
      secondaryActionLabel: json['secondaryActionLabel'] as String? ?? '건너뛰기',
    );
  }
}
