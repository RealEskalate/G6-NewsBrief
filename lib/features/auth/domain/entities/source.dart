class Source {
  final String? id; // optional
  final String slug;
  final String name;
  final String description;
  final String url;
  final String logoUrl;
  final String languages;
  final List<String> topics;
  final int reliabilityScore;

  Source({
    this.id,
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
    final data = {
      "slug": slug,
      "name": name,
      "description": description,
      "url": url,
      "logo_url": logoUrl,
      "languages": languages,
      "topics": topics,
      "reliability_score": reliabilityScore,
    };
    if (id != null) {
      data["id"] = id as Object;
    }
    return data;
  }

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      url: json['url'],
      logoUrl: json['logo_url'],
      languages: json['languages'],
      topics: json['topics'] != null
          ? List<String>.from(json['topics'])
          : [],
      reliabilityScore: json['reliability_score'] is int
          ? json['reliability_score']
          : (json['reliability_score'] as num).toInt(),
    );
  }
}