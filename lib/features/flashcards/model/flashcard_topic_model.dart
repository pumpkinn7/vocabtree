class Flashcard {
  final String id;
  final String category;
  final String word;
  final String partOfSpeech;
  final String definition;
  final String hint;
  final Map<String, String> exampleSentence;
  final String cefrLevel;

  Flashcard({
    required this.id,
    required this.category,
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.hint,
    required this.exampleSentence,
    required this.cefrLevel,
  });

  factory Flashcard.fromWordDocument(String documentId,
      Map<String, dynamic> data, String categoryId, String cefrLevel) {
    // Get the first sense if available
    final List<dynamic> senses = data['senses'] ?? [];
    final Map<String, dynamic> firstSense =
        senses.isNotEmpty ? Map<String, dynamic>.from(senses.first) : {};

    // Get examples from the first sense
    final List<dynamic> examples = firstSense['examples'] ?? [];
    final String exampleSentence = examples.isNotEmpty ? examples.first : '';

    // Get CEFR level from sense or use the provided one
    String senseCefrLevel = firstSense['cefr'] ?? cefrLevel;

    return Flashcard(
      id: documentId,
      category: categoryId,
      word: data['mainWord'] ?? documentId,
      partOfSpeech: firstSense['partOfSpeech'] ?? data['mainPos'] ?? '',
      definition: firstSense['definition'] ?? '',
      hint: firstSense['title'] ?? '',
      exampleSentence: {
        'sentence': exampleSentence,
      },
      cefrLevel: senseCefrLevel,
    );
  }

  // สำหรับ backward compatibility
  factory Flashcard.fromMap(Map<String, dynamic> data) {
    return Flashcard(
      id: data['vocabulary_id'] ?? '',
      category: data['category'] ?? '',
      word: data['word'] ?? '',
      partOfSpeech: data['type'] ?? '',
      definition: data['meaning'] ?? '',
      hint: data['hint'] ?? '',
      exampleSentence: {
        'sentence': data['example_sentence'] ?? '',
      },
      cefrLevel: data['cefrLevel'] ?? '',
    );
  }
}
