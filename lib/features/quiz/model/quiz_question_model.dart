enum QuestionType {
  multipleChoice,
  dragAndDrop,
  matching,
}

class QuizQuestionModel {
  final QuestionType type;

  // ฟิลด์พื้นฐานที่ทุกประเภทคำถามมีร่วมกัน
  final String question;

  // สำหรับ Multiple Choice
  final List<String> options;
  final String correctAnswer;
  final String partOfSpeech;
  final String exampleSentence;
  final String translatedSentence;

  // สำหรับ Drag and Drop
  final List<String> draggableItems;
  final List<String> targets;
  final Map<String, String> correctMatches;

  // สำหรับ Matching
  final List<String> leftItems;
  final List<String> rightItems;
  // สำหรับ Matching ใช้ correctMatches เช่นเดียวกับ Drag and Drop
  // เพราะต้องจับคู่ว่า item ไหนตรงกับ item ไหน
  // สามารถใช้ Map<String, String> เดียวกันได้
  // สำหรับ Matching เราอาจใช้ correctMatches ในรูปแบบเดียวกัน

  QuizQuestionModel({
    required this.type,
    this.question = '',
    this.options = const [],
    this.correctAnswer = '',
    this.partOfSpeech = '',
    this.exampleSentence = '',
    this.translatedSentence = '',
    this.draggableItems = const [],
    this.targets = const [],
    this.correctMatches = const {},
    this.leftItems = const [],
    this.rightItems = const [],
  });
}
