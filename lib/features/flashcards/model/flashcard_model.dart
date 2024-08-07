import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Flashcard.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Flashcard(
      id: doc.id,
      category: data['category'],
      word: data['word'],
      partOfSpeech: data['partOfSpeech'],
      definition: data['definition'],
      hint: data['hint'],
      translation: data['translation'],
      exampleSentence: Map<String, String>.from(data['exampleSentence']),
      options: List<String>.from(data['options']),
    );
  }
}
