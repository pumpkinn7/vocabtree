import 'dart:math';

import '../model/quiz_question_model.dart';

class QuizLogic {
  /// จัดเรียงและสุ่มคำถาม
  /// - เรียงประเภท MultipleChoice -> DragAndDrop -> Matching
  /// - สุ่มคำถามภายในแต่ละประเภท
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

    // สุ่มลำดับภายในแต่ละประเภท
    multipleChoiceQuestions.shuffle(Random());
    dragDropQuestions.shuffle(Random());
    matchingQuestions.shuffle(Random());

    // รวมกลับเป็นลิสต์เดียว ตามลำดับประเภทที่ต้องการ
    return [
      ...multipleChoiceQuestions,
      ...dragDropQuestions,
      ...matchingQuestions,
    ];
  }

// หากต้องการฟังก์ชันอื่น ๆ เช่นคำนวณคะแนนหรือเปอร์เซ็นต์ก็สามารถเพิ่มได้
// แต่ในที่นี้ ฟังก์ชันดังกล่าวได้ถูกนำไปใช้ในหน้า quiz_topic_screen.dart โดยตรง

}
