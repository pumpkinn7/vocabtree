class DailyVocabulary {
  final String word;
  final String type;
  final String cefrLevel;

  DailyVocabulary({
    required this.word,
    required this.type,
    required this.cefrLevel,
  });

  factory DailyVocabulary.fromMap(Map<String, dynamic> map) {
    return DailyVocabulary(
      word: map['word'] ?? '',
      type: map['type'] ?? '',
      cefrLevel: map['cefrLevel'] ?? '',
    );
  }
}
