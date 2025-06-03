import 'package:flutter/material.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/screens/child/assessment/services/assessment_service.dart';
import 'package:khuta/screens/child/results_screen.dart';

class AssessmentController {
  final AssessmentService _service;
  final BuildContext context;
  final Child child;
  final List<Question> questions;
  final List<int> answers;
  final Function(int) onQuestionChanged;
  final Function(List<int>) onAnswersChanged;

  AssessmentController({
    required this.context,
    required this.child,
    required this.questions,
    required this.answers,
    required this.onQuestionChanged,
    required this.onAnswersChanged,
  }) : _service = AssessmentService(child: child);

  void previousQuestion(int currentIndex) {
    if (currentIndex > 0) {
      onQuestionChanged(currentIndex - 1);
    }
  }

  void nextQuestion(int currentIndex) {
    if (currentIndex < questions.length - 1) {
      onQuestionChanged(currentIndex + 1);
    } else {
      _showResults();
    }
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    final newAnswers = List<int>.from(answers);
    newAnswers[questionIndex] = optionIndex;
    onAnswersChanged(newAnswers);
  }

  Future<void> _showResults() async {
    final score = _service.calculateScore(answers);
    final interpretation = _service.getScoreInterpretation(score);

    try {
      await _service.saveTestResult(score, interpretation);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              child: child,
              score: score,
              answers: answers,
              questions: questions,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving results: $e')));
      }
    }
  }

  Future<bool> showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Assessment'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
