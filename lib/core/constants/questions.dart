import 'package:khuta/models/question.dart';

List<Question> getSampleQuestions() {
  return [
    Question(
      id: 't1',
      imageUrl: 'assets/images/parents_questions/Stomach_pain.jpg',
      questionText: 'Stomach_pain', // مفتاح الترجمة
      options: ['never', 'rarely', 'sometimes', 'often'],
    ),
     Question(
      id: 't3',
      imageUrl: 'assets/images/parents_questions/Stomach_pain.jpg',
      questionText: 'Stomach_pain', // مفتاح الترجمة
      options: ['never', 'rarely', 'sometimes', 'often'],
    ), ];
}
