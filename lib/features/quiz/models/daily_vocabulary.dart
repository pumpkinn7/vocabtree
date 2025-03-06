class DailyVocabulary {
  final String word;
  final String type;
  final String cefrLevel;
  final String? translation;
  final String? definition;
  final String? example;

  DailyVocabulary({
    required this.word,
    required this.type,
    required this.cefrLevel,
    this.translation,
    this.definition,
    this.example,
  });

  bool get hasDefinition => definition != null && definition!.isNotEmpty;
  bool get hasTranslation => translation != null && translation!.isNotEmpty;
  bool get hasExample => example != null && example!.isNotEmpty;

  factory DailyVocabulary.fromMap(Map<String, dynamic> map) {
    return DailyVocabulary(
      word: map['word'] ?? '',
      type: map['type'] ?? '',
      cefrLevel: map['cefrLevel'] ?? '',
    );
  }
}
