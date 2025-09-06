class Topic {
  final String? id;
  final String slug; // required
  final Map<String, String> label; // required, e.g., {"en": "Science", "am": "ሳይንስ"}
  final Map<String, String>? description; // optional, e.g., {"en": "Topic about science"}

  Topic({
    this.id,
    required this.slug,
    required this.label,
    this.description,
  });

  // Convert Topic instance to JSON
  Map<String, dynamic> toJson() {
    final data = {
      "slug": slug,
      "label": label,
    };
    if (description != null) {
      data["description"] = description as Object; // cast to Object
    }
    if (id != null) {
      data["id"] = id as Object;
    }
    return data;
  }


  // Create Topic instance from JSON
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      slug: json['slug'],
      label: Map<String, String>.from(json['label']),
      description: json['description'] != null
          ? Map<String, String>.from(json['description'])
          : null,
    );
  }

  // Get label for current language safely
  String getLabel(String langCode) {
    return label[langCode] ?? label.values.first;
  }

  // Get description for current language safely
  String? getDescription(String langCode) {
    return description?[langCode];
  }
}
