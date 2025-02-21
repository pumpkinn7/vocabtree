class QuizQuestionModel {
  final String mainWord;
  final String mainPos; // เพิ่ม mainPos field
  final String definition;
  final List<String> options;
  final List<Map<String, dynamic>> senses;
  final String cefrLevel; // เพิ่ม cefrLevel field

  QuizQuestionModel({
    required this.mainWord,
    required this.mainPos,
    required this.definition,
    required this.options,
    required this.senses,
    required this.cefrLevel,
  });
}
