import 'package:easy_localization/easy_localization.dart';

/// T-Score lookup table for SDQ (Strengths and Difficulties Questionnaire) scoring.
///
/// Structure: `assessmentType` -> `gender` -> `ageGroup` -> `rawScore` -> `tScore`
///
/// T-Scores are standardized scores with mean=50 and SD=10.
/// - 45-55: Average range
/// - 56-60: Slightly above average (mild concern)
/// - 61-65: Above average (moderate concern)
/// - 66-69: Significantly above average (high concern)
/// - ≥70: Extremely above average (very high concern)
Map<String, Map<String, Map<String, Map<int, int>>>> sdqParentTScoreTable = {
  'parent': {
    'male': {
      '6-8': {
        0: 37,
        1: 41,
        2: 45,
        3: 49,
        4: 50,
        5: 52,
        6: 55,
        7: 58,
        8: 60,
        9: 63,
        10: 67,
      },
      '9-11': {
        0: 37,
        1: 42,
        2: 46,
        3: 50,
        4: 51,
        5: 53,
        6: 56,
        7: 59,
        8: 61,
        9: 64,
        10: 68,
      },
      '12-14': {
        0: 36,
        1: 42,
        2: 46,
        3: 48,
        4: 50,
        5: 53,
        6: 56,
        7: 60,
        8: 62,
        9: 65,
        10: 69,
      },
      '15-17': {
        0: 39,
        1: 44,
        2: 48,
        3: 50,
        4: 52,
        5: 56,
        6: 57,
        7: 59,
        8: 62,
        9: 66,
        10: 70,
      },
    },
    'female': {
      '6-8': {
        0: 39,
        1: 45,
        2: 49,
        3: 51,
        4: 53,
        5: 56,
        6: 59,
        7: 62,
        8: 65,
        9: 68,
        10: 71,
      },
      '9-11': {
        0: 41,
        1: 46,
        2: 50,
        3: 52,
        4: 54,
        5: 57,
        6: 61,
        7: 63,
        8: 67,
        9: 69,
        10: 74,
      },
      '12-14': {
        0: 42,
        1: 47,
        2: 49,
        3: 51,
        4: 55,
        5: 58,
        6: 61,
        7: 64,
        8: 67,
        9: 71,
        10: 77,
      },
      '15-17': {
        0: 42,
        1: 48,
        2: 50,
        3: 52,
        4: 56,
        5: 60,
        6: 63,
        7: 65,
        8: 68,
        9: 74,
        10: 75,
      },
    },
  },
};

/// Retrieves the T-score from the lookup table based on input parameters.
///
/// Parameters:
/// - [assessmentType]: The type of assessment ('parent' or 'teacher')
/// - [gender]: The child's gender ('male' or 'female')
/// - [ageGroup]: The age group string ('6-8', '9-11', '12-14', '15-17')
/// - [proratedScore]: The sum of answer values (0-10 for 10 questions)
///
/// Returns the T-score from the table, or -1 if the combination is not found.
int getTScore(
  String assessmentType,
  String gender,
  String ageGroup,
  int proratedScore,
) {
  return sdqParentTScoreTable[assessmentType]?[gender]?[ageGroup]?[proratedScore] ??
      -1;
}

/// Service for calculating T-scores using the SDQ (Strengths and Difficulties
/// Questionnaire) scoring tables.
///
/// The T-score is a standardized score calculated based on:
/// - The sum of answer values (raw/prorated score)
/// - Child's age group (6-8, 9-11, 12-14, 15-17)
/// - Child's gender (male or female)
/// - Assessment type (parent or teacher questionnaire)
///
/// ## T-Score Interpretation
///
/// | T-Score Range | Interpretation |
/// |---------------|----------------|
/// | ≥70 | Extremely above average - very high concern |
/// | 66-69 | Significantly above average - high concern |
/// | 61-65 | Above average - moderate concern |
/// | 56-60 | Slightly above average - mild concern |
/// | 45-55 | Average - typical behavior |
/// | 40-44 | Slightly below average |
/// | 35-39 | Below average |
/// | 30-34 | Significantly below average |
/// | <30 | Extremely below average |
///
/// ## Example Usage
///
/// ```dart
/// final tScore = SdqScoringService.calculateTScore(
///   answers: [1, 2, 1, 0, 3, 2, 1, 0, 2, 1],
///   gender: 'male',
///   age: 8,
///   assessmentType: 'parent',
/// );
///
/// final interpretation = SdqScoringService.getScoreInterpretation(tScore);
/// ```
class SdqScoringService {
  /// Calculates the T-score for a given set of assessment answers.
  ///
  /// Parameters:
  /// - [answers]: List of answer values (typically 0-3 for each question).
  ///   Unanswered questions (-1) should be filtered before calling this method.
  /// - [gender]: The child's gender ('male' or 'female')
  /// - [age]: The child's age in years (must be between 6 and 17)
  /// - [assessmentType]: The type of assessment ('parent' or 'teacher')
  ///
  /// Returns the calculated T-score.
  ///
  /// Throws an [Exception] if:
  /// - Age is outside the valid range (6-17)
  /// - The score lookup fails (invalid combination of parameters)
  static int calculateTScore({
    required List<int> answers,
    required String gender,
    required int age,
    required String assessmentType,
  }) {
    // Calculate prorated score (sum of all answers)
    int proratedScore = answers.fold<int>(0, (sum, value) => sum + value);

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
      throw Exception('error_prorated_score'.tr());
    }

    return tScore;
  }

  /// Returns a human-readable interpretation of the T-score.
  ///
  /// The interpretation is localized using easy_localization.
  ///
  /// Parameters:
  /// - [tScore]: The T-score to interpret
  ///
  /// Returns a translated string describing the severity level.
  static String getScoreInterpretation(int tScore) {
    if (tScore >= 70) {
      return 'extremely_above_average'.tr();
    } else if (tScore >= 66) {
      return 'significantly_above_average'.tr();
    } else if (tScore >= 61) {
      return 'above_average'.tr();
    } else if (tScore >= 56) {
      return 'slightly_above_average'.tr();
    } else if (tScore >= 45) {
      return 'average'.tr();
    } else if (tScore >= 40) {
      return 'slightly_below_average'.tr();
    } else if (tScore >= 35) {
      return 'below_average'.tr();
    } else if (tScore >= 30) {
      return 'significantly_below_average'.tr();
    } else {
      return 'extremely_below_average'.tr();
    }
  }

}
