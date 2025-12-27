import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/core/di/service_locator.dart';
import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/core/repositories/test_result_repository.dart';
import 'package:khuta/core/services/sdq_scoring_service.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/test_result.dart';

class AssessmentService {
  final ChildRepository _childRepository;
  final TestResultRepository _testResultRepository;
  final Child child;
  final String assessmentType;

  AssessmentService({
    required this.assessmentType,
    required this.child,
    ChildRepository? childRepository,
    TestResultRepository? testResultRepository,
  }) : _childRepository = childRepository ?? ServiceLocator().childRepository,
       _testResultRepository = testResultRepository ?? ServiceLocator().testResultRepository;

  Future<void> saveTestResult(
    int score,
    String interpretation,
    List<String> recommendations,
  ) async {
    try {
      final testResult = TestResult(
        testType: assessmentType.tr(),
        score: score.toDouble(),
        date: DateTime.now(),
        notes: interpretation,
        recommendations: recommendations,
      );

      // Save to subcollection via repository
      await _testResultRepository.saveTestResult(child.id, testResult);

      // Also update embedded results for UI compatibility
      child.testResults.add(testResult);
      await _childRepository.updateChild(child);
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving test result: $e');
      rethrow;
    }
  }

  /// Get the interpretation text based on the T-score
  String getScoreInterpretation(int tScore) {
    return SdqScoringService.getScoreInterpretation(tScore);
  }

  /// Calculate the SDQ T-score based on raw answers
  int calculateScore(List<int> answers, String questionType) {
    if (child.age < 6 || child.age > 17) {
      throw Exception('Age must be between 6 and 17');
    }

    // Filter out unanswered questions (-1) and map to SDQ scores
    final validAnswers = answers.where((a) => a != -1).toList();

    if (validAnswers.isEmpty) {
      throw Exception('No valid answers provided');
    }

    return SdqScoringService.calculateTScore(
      answers: validAnswers,
      gender: child.gender.toLowerCase(),
      age: child.age,
      assessmentType: questionType,
    );
  }
}
