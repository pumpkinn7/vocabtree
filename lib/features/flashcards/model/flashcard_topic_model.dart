class Flashcard {
  final String id;
  final String category;
  final String word;
  final String partOfSpeech;
  final String definition;
  final String hint;
  final String translation;
  final Map<String, String> exampleSentence;
  final List<String> options;

  Flashcard({
    required this.id,
    required this.category,
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.hint,
    required this.translation,
    required this.exampleSentence,
    required this.options,
  });

  factory Flashcard.fromMap(Map<String, dynamic> data) {
    return Flashcard(
      id: data['vocabulary_id'] ?? '',
      category: data['category'] ?? '',
      word: data['word'] ?? '',
      partOfSpeech: data['type'] ?? '',
      definition: data['meaning'] ?? '',
      hint: data['hint'] ?? '',
      translation: data['translation'] ?? '',
      exampleSentence: {
        'sentence': data['example_sentence'] ?? '',
        'translation': data['example_translation'] ?? '',
      },
      options: [],
    );
  }
}
