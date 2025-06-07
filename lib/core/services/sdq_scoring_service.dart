import '../constants/scorring_map.dart';

class SdqScoringService {
  /// Converts raw answers (0-3) to SDQ T-scores based on age and gender
  static int calculateTScore({
    required List<int> answers,
    required String gender, // 'male' or 'female'
    required int age,
    required String assessmentType, // 'parent' or 'teacher'
  }) {
    // Calculate prorated score (sum of all answers)
    int proratedScore = answers.fold(0, (sum, answer) => sum + answer);

    // Determine age group based on age
    String ageGroup = '';
    if (age >= 6 && age <= 8) {
      ageGroup = '6-8';
    } else if (age >= 9 && age <= 11) {
      ageGroup = '9-11';
    } else if (age >= 12 && age <= 14) {
      ageGroup = '12-14';
    } else if (age >= 15 && age <= 17) {
      ageGroup = '15-17';
    } else {
      throw Exception('Age must be between 6 and 17');
    }

    // Get T-score using the scoring map
    int tScore = getTScore(assessmentType, gender, ageGroup, proratedScore);
    if (tScore == -1) {
      throw Exception('Invalid prorated score or parameters');
    }

    return tScore;
  }

  /// Get interpretation of T-score
  static String getScoreInterpretation(int tScore) {
    if (tScore >= 70) {
      return 'very_high_risk';
    } else if (tScore >= 65) {
      return 'high_risk';
    } else if (tScore >= 60) {
      return 'moderately_high_risk';
    } else if (tScore >= 45) {
      return 'normal_range';
    } else {
      return 'low_range';
    }
  }

  /// Get recommendations based on T-score
  static List<String> getRecommendations(int tScore) {
    if (tScore >= 70) {
      return [
        'immediate_professional_consultation',
        'comprehensive_evaluation_needed',
        'create_support_plan',
        'regular_monitoring',
      ];
    } else if (tScore >= 65) {
      return [
        'professional_consultation_recommended',
        'behavioral_intervention_plan',
        'parent_teacher_coordination',
        'regular_follow_up',
      ];
    } else if (tScore >= 60) {
      return [
        'monitor_behavior_closely',
        'consider_professional_consultation',
        'implement_support_strategies',
        'regular_assessment',
      ];
    } else if (tScore >= 45) {
      return [
        'continue_current_support',
        'maintain_regular_monitoring',
        'positive_reinforcement',
        'age_appropriate_activities',
      ];
    } else {
      return [
        'maintain_current_strategies',
        'encourage_positive_behaviors',
        'regular_development_monitoring',
        'age_appropriate_engagement',
      ];
    }
  }
}
