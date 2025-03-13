class WordCategoryModel {
  final String topicId;
  final List<String> words;

  WordCategoryModel({
    required this.topicId,
    required this.words,
  });

  factory WordCategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return WordCategoryModel(
      topicId: id,
      words: List<String>.from(data['words'] ?? []),
    );
  }
}
