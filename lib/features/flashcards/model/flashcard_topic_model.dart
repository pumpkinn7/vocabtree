class Flashcard {
  final String id;
  final String mainWord; // เปลี่ยนจาก word เป็น mainWord
  final String partOfSpeech;
  final String definition;
  final String hint;
  final String cefrLevel;

  const Flashcard({
    required this.id,
    required this.mainWord,
    required this.partOfSpeech,
    required this.definition,
    required this.hint,
    required this.cefrLevel,
  });

  factory Flashcard.fromWordDocument(
    String id,
    Map<String, dynamic> data,
    String categoryId,
    String cefrLevel,
  ) {
    final senses = data['senses'] as List? ?? [];
    final word = data['mainWord'] as String? ?? '';

    if (senses.isEmpty) {
      return Flashcard(
        id: id,
        mainWord: word,
        partOfSpeech: data['mainPos'] as String? ?? '',
        definition: '',
        hint: '',
        cefrLevel: cefrLevel,
      );
    }

    final firstSense = senses.first as Map<String, dynamic>;

    return Flashcard(
      id: id,
      mainWord: word,
      partOfSpeech: firstSense['partOfSpeech'] as String? ??
          data['mainPos'] as String? ??
          '',
      definition: firstSense['definition'] as String? ?? '',
      hint: firstSense['title'] as String? ?? '',
      cefrLevel: cefrLevel,
    );
  }

  factory Flashcard.fromMap(Map<String, dynamic> data) {
    return Flashcard(
      id: data['vocabulary_id'] ?? '',
      mainWord: data['word'] ?? '',
      partOfSpeech: data['type'] ?? '',
      definition: data['meaning'] ?? '',
      hint: data['hint'] ?? '',
      cefrLevel: data['cefrLevel'] ?? 'B1',
    );
  }
}

// เพิ่ม WordDetail model
class WordDetail {
  final String id;
  final String mainWord;
  final String partOfSpeech;
  final String definition;
  final String hint;
  final List<String> examples;
  final String cefrLevel;

  const WordDetail({
    required this.id,
    required this.mainWord,
    required this.partOfSpeech,
    required this.definition,
    required this.hint,
    required this.examples,
    required this.cefrLevel,
  });

  factory WordDetail.fromDocument(
    String documentId,
    Map<String, dynamic> data,
    String defaultCefrLevel,
  ) {
    final senses = data['senses'] as List? ?? [];
    final firstSense = senses.isNotEmpty
        ? senses.first as Map<String, dynamic>
        : <String, dynamic>{};

    return WordDetail(
      id: documentId,
      mainWord: data['mainWord'] ?? documentId,
      partOfSpeech: firstSense['partOfSpeech'] ?? data['mainPos'] ?? '',
      definition: firstSense['definition'] ?? '',
      hint: firstSense['title'] ?? '',
      examples: List<String>.from(firstSense['examples'] ?? []),
      cefrLevel: firstSense['cefr'] ?? defaultCefrLevel,
    );
  }
}
