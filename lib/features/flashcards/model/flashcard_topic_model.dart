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

// เพิ่มคลาส WordDetail ถ้ายังไม่มี
class WordDetail {
  final String id;
  final String mainWord;
  final String partOfSpeech;
  final String definition;
  final String cefr;
  final List<String> examples;
  final List<AdditionalMeaning> otherMeanings;

  WordDetail({
    required this.id,
    required this.mainWord,
    required this.partOfSpeech,
    required this.definition,
    required this.cefr,
    required this.examples,
    required this.otherMeanings,
  });

  factory WordDetail.fromMap(Map<String, dynamic> map) {
    return WordDetail(
      id: map['id'] ?? '',
      mainWord: map['mainWord'] ?? '',
      partOfSpeech: map['partOfSpeech'] ?? '',
      definition: map['definition'] ?? '',
      cefr: map['cefr'] ?? '',
      examples: List<String>.from(map['examples'] ?? []),
      otherMeanings: List<AdditionalMeaning>.from(
        (map['otherMeanings'] ?? []).map(
          (x) => AdditionalMeaning.fromMap(x),
        ),
      ),
    );
  }

  // เพิ่มเมธอด fromDocument
  factory WordDetail.fromDocument(
      String docId, Map<String, dynamic> doc, String cefrLevel) {
    List<AdditionalMeaning> otherMeanings = [];
    List<String> examples = [];
    String definition = '';
    String partOfSpeech = doc['mainPos'] ?? '';

    // ดึงข้อมูลจาก senses ถ้ามี
    if (doc['senses'] != null &&
        doc['senses'] is List &&
        (doc['senses'] as List).isNotEmpty) {
      final senses = doc['senses'] as List;

      // ดึงข้อมูลจาก sense แรก
      if (senses.isNotEmpty) {
        final firstSense = senses.first as Map<String, dynamic>;
        definition = firstSense['definition'] ?? '';
        partOfSpeech = firstSense['partOfSpeech'] ?? partOfSpeech;

        // ดึงตัวอย่างประโยค
        if (firstSense['examples'] != null && firstSense['examples'] is List) {
          examples = List<String>.from(firstSense['examples']);
        }
      }

      // ดึง senses อื่นๆ เป็น otherMeanings
      if (senses.length > 1) {
        for (var i = 1; i < senses.length; i++) {
          if (senses[i] is Map<String, dynamic>) {
            final sense = senses[i] as Map<String, dynamic>;
            List<String> senseExamples = [];

            if (sense['examples'] != null && sense['examples'] is List) {
              senseExamples = List<String>.from(sense['examples']);
            }

            otherMeanings.add(AdditionalMeaning(
              partOfSpeech: sense['partOfSpeech'] ?? '',
              definition: sense['definition'] ?? '',
              examples: senseExamples,
            ));
          }
        }
      }
    }

    return WordDetail(
      id: docId,
      mainWord: doc['mainWord'] ?? '',
      partOfSpeech: partOfSpeech,
      definition: definition,
      cefr: cefrLevel,
      examples: examples,
      otherMeanings: otherMeanings,
    );
  }
}

class AdditionalMeaning {
  final String partOfSpeech;
  final String definition;
  final List<String> examples;

  AdditionalMeaning({
    required this.partOfSpeech,
    required this.definition,
    required this.examples,
  });

  factory AdditionalMeaning.fromMap(Map<String, dynamic> map) {
    return AdditionalMeaning(
      partOfSpeech: map['partOfSpeech'] ?? '',
      definition: map['definition'] ?? '',
      examples: List<String>.from(map['examples'] ?? []),
    );
  }
}
