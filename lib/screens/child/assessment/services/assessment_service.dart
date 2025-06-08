import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/services/ai_recommendations_service.dart';
import 'package:khuta/core/services/sdq_scoring_service.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/models/test_result.dart';

class AssessmentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Child child;

  AssessmentService({
    required this.child,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  Future<void> saveTestResult(int score, String interpretation, List<String> recommendations) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

   

      final testResult = TestResult(
        testType: 'sdq_assessment'.tr(),
        score: score.toDouble(),
        date: DateTime.now(),
        notes: interpretation,
        recommendations: recommendations,
      );

      // Add result to child's list
      child.testResults.add(testResult);

      // Update in Firebase
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .doc(child.id)
          .update({
            'testResults': child.testResults.map((e) => e.toMap()).toList(),
          });
    } catch (e) {
      debugPrint('Error saving test result: $e');
      rethrow;
    }
  }

  /// Get the interpretation text based on the T-score
  String getScoreInterpretation(int tScore) {
    return SdqScoringService.getScoreInterpretation(tScore);
  }

  /// Calculate the SDQ T-score based on raw answers
  int calculateScore(List<int> answers, QuestionType questionType) {
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
      assessmentType: questionType == QuestionType.parent
          ? 'parent'
          : 'teacher',
    );
  }
}
