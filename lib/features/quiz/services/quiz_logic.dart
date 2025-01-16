import 'dart:math';

import '../model/quiz_question_model.dart';

class QuizLogic {
  /// - เรียงประเภท MultipleChoice -> DragAndDrop -> Matching
  static List<QuizQuestionModel> arrangeAndShuffleQuestions(List<QuizQuestionModel> questions) {
    List<QuizQuestionModel> multipleChoiceQuestions = [];
    List<QuizQuestionModel> dragDropQuestions = [];
    List<QuizQuestionModel> matchingQuestions = [];

    for (var q in questions) {
      switch (q.type) {
        case QuestionType.multipleChoice:
          multipleChoiceQuestions.add(q);
          break;
        case QuestionType.dragAndDrop:
          dragDropQuestions.add(q);
          break;
        case QuestionType.matching:
          matchingQuestions.add(q);
          break;
      }
    }

    multipleChoiceQuestions.shuffle(Random());
    dragDropQuestions.shuffle(Random());
    matchingQuestions.shuffle(Random());

    // รวมกลับเป็นลิสต์เดียว
    return [
      ...multipleChoiceQuestions,
      ...dragDropQuestions,
      ...matchingQuestions,
    ];
  }
}
