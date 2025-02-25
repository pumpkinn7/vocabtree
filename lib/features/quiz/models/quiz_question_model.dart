class QuizQuestionModel {
  final String mainWord;
  final String mainPos; // เพิ่ม mainPos field
  final String thaiWord; // Add this field
  final String definition;
  final List<String> options;
  final List<Map<String, dynamic>> senses;
  final String cefrLevel; // เพิ่ม cefrLevel field

  QuizQuestionModel({
    required this.mainWord,
    required this.mainPos,
    required this.thaiWord, // Add this parameter
    required this.definition,
    required this.options,
    required this.senses,
    required this.cefrLevel,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      mainWord: json['mainWord'] as String,
      mainPos: json['mainPos'] as String,
      thaiWord: json['thaiWord'] as String, // Add this field
      definition: json['definition'] as String,
      options: List<String>.from(json['options']),
      senses: List<Map<String, dynamic>>.from(json['senses']),
      cefrLevel: json['cefrLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainWord': mainWord,
      'mainPos': mainPos,
      'thaiWord': thaiWord, // Add this field
      'definition': definition,
      'options': options,
      'senses': senses,
      'cefrLevel': cefrLevel,
    };
  }
}
