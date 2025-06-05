enum QuestionType { parent, teacher }

class Question {
  final String id;
  final String imageUrl;
  final String questionText; // النص الافتراضي أو المفتاح للترجمة
  final List<String> options;
  final QuestionType questionType;

  Question({
    required this.id,
    required this.imageUrl,
    required this.questionText,
    required this.options,
    this.questionType = QuestionType.parent,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      questionType: map['questionType'] ?? QuestionType.parent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'questionText': questionText,
      'options': options,
      'questionType': questionType,
    };
  }
}
