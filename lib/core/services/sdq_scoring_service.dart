import 'package:easy_localization/easy_localization.dart';

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

// دالة لجلب درجة T بناءً على البيانات المدخلة
int getTScore(
  String assessmentType,
  String gender,
  String ageGroup,
  int proratedScore,
) {
  return sdqParentTScoreTable[assessmentType]?[gender]?[ageGroup]?[proratedScore] ??
      -1;
}

class SdqScoringService {
  static int calculateTScore({
    required List<int> answers,
    required String gender, // 'male' or 'female'
    required int age,
    required String assessmentType, // 'parent' or 'teacher'
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

  /// Get interpretation of T-score
  static String getScoreInterpretation(int tScore) {
    if (tScore >= 70) {
      return 'extremely_above_average';
    } else if (tScore >= 66) {
      return 'significantly_above_average';
    } else if (tScore >= 61) {
      return 'above_average';
    } else if (tScore >= 56) {
      return 'slightly_above_average';
    } else if (tScore >= 45) {
      return 'average';
    } else if (tScore >= 40) {
      return 'slightly_below_average';
    } else if (tScore >= 35) {
      return 'below_average';
    } else if (tScore >= 30) {
      return 'significantly_below_average';
    } else {
      return 'extremely_below_average';
    }
  }

  /// Get recommendations based on T-score
}
