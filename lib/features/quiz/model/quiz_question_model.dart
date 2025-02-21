enum QuestionType {
  multipleChoice,
}

class QuizQuestionModel {
  final String mainWord;
  final String mainPos;
  final List<Map<String, dynamic>> senses;
  final String cefrLevel;
  final List<String> options;
  final String definition;

  QuizQuestionModel({
    required this.mainWord,
    required this.mainPos,
    required this.senses,
    required this.cefrLevel,
    required this.options,
    required this.definition,
  });
}
