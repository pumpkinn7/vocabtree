import 'dart:math';

import '../model/quiz_question_model.dart';

class QuizLogic {
  static List<QuizQuestionModel> arrangeAndShuffleQuestions(
      List<QuizQuestionModel> questions) {
    questions.shuffle(Random());
    return questions;
  }
}
