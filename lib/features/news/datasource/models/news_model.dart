import 'dart:ui';

class News {
  final String id;
  final String titleEn;
  final String titleAm;
  final String descriptionEn;
  final String descriptionAm;
  final String source;
  final String imageUrl;
  final List<String>? topics; // <-- optional topics field

  News({
    required this.id,
    required this.titleEn,
    required this.titleAm,
    required this.descriptionEn,
    required this.descriptionAm,
    required this.source,
    required this.imageUrl,
    this.topics, // <-- optional
  });

  /// Returns title based on current locale
  String title(Locale locale) => locale.languageCode == 'am' ? titleAm : titleEn;

  /// Returns description based on current locale
  String description(Locale locale) =>
      locale.languageCode == 'am' ? descriptionAm : descriptionEn;

  /// Convert JSON from backend to News object
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAm: json['title_am'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionAm: json['description_am'] ?? '',
      source: json['source'] ?? '',
      imageUrl: json['image_url'] ?? '',
      topics: (json['topics'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  /// Convert News object to JSON (useful for caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_am': titleAm,
      'description_en': descriptionEn,
      'description_am': descriptionAm,
      'source': source,
      'image_url': imageUrl,
      'topics': topics, // <-- include topics in JSON
    };
  }
}
