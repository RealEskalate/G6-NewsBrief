Map<String, String> mapNewsIdsToNames({
  required Map<String, dynamic> userState,
  required String topicId,
  required String sourceId,
}) {
  String topicLabel = topicId;
  String sourceName = sourceId;

  // Map topicId → label
  if (userState['topics'] != null) {
    final topicMatch = (userState['topics'] as List)
        .firstWhere((t) => t['id'] == topicId, orElse: () => {});
    if (topicMatch.isNotEmpty) {
      topicLabel = topicMatch['label']['en'] ?? topicId;
    }
  }

  // Map sourceId → name
  if (userState['sources'] != null) {
    final sourceMatch = (userState['sources'] as List)
        .firstWhere((s) => s['id'] == sourceId, orElse: () => {});
    if (sourceMatch.isNotEmpty) {
      sourceName = sourceMatch['name'] ?? sourceMatch['slug'] ?? sourceId;
    }
  }

  return {'topic': topicLabel, 'source': sourceName};
}
