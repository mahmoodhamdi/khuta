import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/services/ai_recommendations_service.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/screens/child/assessment/services/assessment_service.dart';
import 'package:khuta/screens/child/results_screen.dart';
import 'package:khuta/screens/main_screen.dart';
import 'package:khuta/widgets/loading_overlay.dart';

class AssessmentController {
  final AssessmentService _service;
  final BuildContext context;
  final Child child;
  final List<Question> questions;
  List<int> answers;
  final Function(int) onQuestionChanged;
  final Function(List<int>) onAnswersChanged;

  AssessmentController({
    required this.answers,
    required this.context,
    required this.child,
    required this.questions,
    required this.onQuestionChanged,
    required this.onAnswersChanged,
  }) : _service = AssessmentService(
         child: child,
         assessmentType: questions[0].questionType.toString(),
       );

  void previousQuestion(int currentIndex) {
    if (currentIndex > 0) {
      onQuestionChanged(currentIndex - 1);
    }
  }

  void nextQuestion(int currentIndex) {
    if (currentIndex < questions.length - 1) {
      onQuestionChanged(currentIndex + 1);
      debugPrint('currentIndex: $currentIndex');
      debugPrint('answers: $answers');
    } else {
      _showResults();
    }
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    answers[questionIndex] = optionIndex;
    onAnswersChanged(answers);
    debugPrint('Answer selected for question $questionIndex: $optionIndex');
    debugPrint('Current answers: $answers');
  }

  Future<void> _showResults() async {
    if (questions.isEmpty) return;

    try {
      if (!context.mounted) return;

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingOverlay(),
      );

      final score = answers.asMap().entries.fold<int>(
        0,
        (sum, entry) => sum + entry.value,
      );
      final interpretation = _service.getScoreInterpretation(score);
      final recommendations = await AiRecommendationsService.getRecommendations(
        score,
        questions,
        answers,
      );

      await _service.saveTestResult(score, interpretation, recommendations);

      // Hide loading overlay before showing results
      if (context.mounted) {
        Navigator.pop(context); // Remove loading overlay
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              interpretation: interpretation,
              child: child,
              score: score,
              answers: answers,
              questions: questions,
              recommendations: recommendations,
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading overlay on error
      if (context.mounted) {
        Navigator.pop(context); // Remove loading overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('Age must be between')
                  ? 'error_invalid_age'.tr()
                  : 'error_saving_results'.tr(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> showExitConfirmation() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        title: Text(
          'exit_assessment'.tr(),
          style: TextStyle(
            color: HomeScreenTheme.primaryText(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'exit_assessment_confirmation'.tr(),
          style: TextStyle(color: HomeScreenTheme.primaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'continue'.tr(),
              style: TextStyle(color: HomeScreenTheme.accentBlue(isDark)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            ),
            child: Text(
              'exit'.tr(),
              style: TextStyle(color: HomeScreenTheme.accentRed(isDark)),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
