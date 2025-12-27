import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/core/services/ai_recommendations_service.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/screens/child/assessment/services/assessment_service.dart';

part 'assessment_state.dart';

class AssessmentCubit extends Cubit<AssessmentState> {
  final Child child;
  final List<Question> questions;
  final AssessmentService _service;

  AssessmentCubit({
    required this.child,
    required this.questions,
    AssessmentService? service,
  })  : _service = service ??
            AssessmentService(
              child: child,
              assessmentType: questions.isNotEmpty
                  ? questions[0].questionType
                  : 'parent',
            ),
        super(AssessmentState.initial(questions.length));

  /// Select an answer for a specific question
  void selectAnswer(int questionIndex, int answerIndex) {
    final newAnswers = List<int>.from(state.answers);
    newAnswers[questionIndex] = answerIndex;
    emit(state.copyWith(answers: newAnswers));
    debugPrint('Answer selected for question $questionIndex: $answerIndex');
  }

  /// Navigate to the next question
  void nextQuestion() {
    if (state.currentIndex < questions.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  /// Navigate to the previous question
  void previousQuestion() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  /// Check if current question is the last one
  bool get isLastQuestion => state.currentIndex == questions.length - 1;

  /// Check if user can proceed (current question has answer)
  bool get canProceed => state.answers[state.currentIndex] >= 0;

  /// Check if all questions have been answered
  bool get allQuestionsAnswered => !state.answers.contains(-1);

  /// Get the number of unanswered questions
  int get unansweredCount => state.answers.where((a) => a < 0).length;

  /// Calculate raw score (sum of answers)
  int calculateRawScore() {
    return state.answers.where((a) => a >= 0).fold(0, (sum, a) => sum + a);
  }

  /// Submit the assessment and get results
  Future<void> submitAssessment() async {
    if (!allQuestionsAnswered) {
      emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: 'please_answer_all_questions',
      ));
      return;
    }

    emit(state.copyWith(status: AssessmentStatus.submitting));

    try {
      // Calculate the raw score
      final rawScore = calculateRawScore();

      // Get interpretation
      final interpretation = _service.getScoreInterpretation(rawScore);

      // Get AI recommendations
      final recommendations = await AiRecommendationsService.getRecommendations(
        rawScore,
        questions,
        state.answers,
        childAge: child.age,
        childGender: child.gender,
      );

      // Save the result
      await _service.saveTestResult(rawScore, interpretation, recommendations);

      // Emit success state with results
      emit(state.copyWith(
        status: AssessmentStatus.success,
        finalScore: rawScore,
        interpretation: interpretation,
        recommendations: recommendations,
      ));
    } catch (e) {
      debugPrint('Error submitting assessment: $e');
      final errorMessage = e.toString().contains('Age must be between')
          ? 'error_invalid_age'
          : 'error_saving_results';
      emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  /// Reset error state
  void clearError() {
    emit(state.copyWith(
      status: AssessmentStatus.inProgress,
      errorMessage: null,
    ));
  }
}
