class Flashcard {
  final String id;
  final String category; // ประเภทของหัวข้อ
  final String word;
  final String partOfSpeech;
  final String definition;
  final String hint;
  final String translation;
  final Map<String, String> exampleSentence; // ตัวอย่างประโยค
  final List<String> options; // ตัวเลือกคำศัพท์

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
      id: data['vocabulary_id'] ?? '', // ใช้ empty string ถ้าไม่มี
      category: data['category'] ?? '', // ใช้ empty string ถ้าไม่มี
      word: data['word'] ?? '', // ใช้ empty string ถ้าไม่มี
      partOfSpeech: data['type'] ?? '', // ใช้ empty string ถ้าไม่มี
      definition: data['meaning'] ?? '', // ใช้ empty string ถ้าไม่มี
      hint: data['hint'] ?? '', // ใช้ empty string ถ้าไม่มี
      translation: data['translation'] ?? '', // ใช้ empty string ถ้าไม่มี
      exampleSentence: {
        'sentence': data['example_sentence'] ?? '', // ใช้ empty string ถ้าไม่มี
        'translation': data['example_translation'] ?? '', // ใช้ empty string ถ้าไม่มี
      },
      options: [], // ถ้าต้องการใช้ options ให้เพิ่มข้อมูลที่นี่
    );
  }
}
