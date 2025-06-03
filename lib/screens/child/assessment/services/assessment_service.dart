import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khuta/models/child.dart';
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

  Future<void> saveTestResult(double score, String interpretation) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final testResult = TestResult(
        testType: 'autism_assessment',
        score: score,
        date: DateTime.now(),
        notes: interpretation,
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

  String getScoreInterpretation(double score) {
    if (score >= 80) return 'high_functionality';
    if (score >= 60) return 'moderate_functionality';
    if (score >= 40) return 'low_functionality';
    return 'very_low_functionality';
  }

  double calculateScore(List<int> answers) {
    double totalScore = 0;
    int answeredQuestions = 0;

    for (int answer in answers) {
      if (answer != -1) {
        totalScore += (answer + 1) * 25; // Each answer from 25 to 100
        answeredQuestions++;
      }
    }

    return answeredQuestions > 0 ? totalScore / answeredQuestions : 0;
  }
}
