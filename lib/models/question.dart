class Question {
  final String id;
  final String imageUrl;
  final String questionText;
  final List<String> options;
  final Map<String, String> questionTextLocalized;

  Question({
    required this.id,
    required this.imageUrl,
    required this.questionText,
    required this.options,
    required this.questionTextLocalized,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      questionTextLocalized: Map<String, String>.from(
        map['questionTextLocalized'] ?? {},
      ),
    );
  }
}
