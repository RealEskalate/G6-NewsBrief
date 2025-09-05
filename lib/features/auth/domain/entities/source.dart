class Source {
  final String slug;
  final String name;
  final String description;
  final String url;
  final String logoUrl;
  final String languages;
  final List<String> topics;
  final int reliabilityScore;

  Source({
    required this.slug,
    required this.name,
    required this.description,
    required this.url,
    required this.logoUrl,
    required this.languages,
    required this.topics,
    required this.reliabilityScore,
  });

  Map<String, dynamic> toJson() {
    return {
      "slug": slug,
      "name": name,
      "description": description,
      "url": url,
      "logo_url": logoUrl,
      "languages": languages,
      "topics": topics,
      "reliability_score": reliabilityScore,
    };
  }

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      url: json['url'],
      logoUrl: json['logo_url'],
      languages: json['languages'],
      topics: List<String>.from(json['topics']),
      reliabilityScore: json['reliability_score'],
    );
  }
}
