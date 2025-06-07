import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';

class ResultsScreen extends StatelessWidget {
  final Child child;
  final double score;
  final List<int> answers;
  final List<Question> questions;

  const ResultsScreen({
    super.key,
    required this.child,
    required this.score,
    required this.answers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('assessment_results'.tr()),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Results Header with T-Score
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getScoreGradient(score.toInt(), isDark),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getScoreIcon(score.toInt()),
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getScoreTitle(score.toInt()),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'T-Score: ${score.toInt()}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Interpretation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HomeScreenTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'interpretation'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getScoreInterpretation(score.toInt()).tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: HomeScreenTheme.secondaryText(isDark),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recommendations
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HomeScreenTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'recommendations'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._getRecommendations(score.toInt()).map(
                      (recommendation) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: HomeScreenTheme.accentBlue(isDark),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recommendation.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: HomeScreenTheme.secondaryText(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getScoreIcon(int tScore) {
    if (tScore >= 70) return Icons.error;
    if (tScore >= 65) return Icons.warning;
    if (tScore >= 60) return Icons.info;
    if (tScore >= 45) return Icons.check_circle;
    return Icons.thumb_up;
  }

  String _getScoreTitle(int tScore) {
    if (tScore >= 70) return 'very_high_risk'.tr();
    if (tScore >= 65) return 'high_risk'.tr();
    if (tScore >= 60) return 'moderately_high_risk'.tr();
    if (tScore >= 45) return 'normal_range'.tr();
    return 'low_range'.tr();
  }

  String _getScoreInterpretation(int tScore) {
    return 'sdq_score_${_getScoreTitle(tScore).toLowerCase()}'.tr();
  }

  List<String> _getRecommendations(int tScore) {
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

  List<Color> _getScoreGradient(int tScore, bool isDark) {
    if (tScore >= 70) {
      return [Colors.red.shade700, Colors.red.shade900];
    } else if (tScore >= 65) {
      return [Colors.orange.shade700, Colors.orange.shade900];
    } else if (tScore >= 60) {
      return [Colors.yellow.shade700, Colors.yellow.shade900];
    } else if (tScore >= 45) {
      return [Colors.green.shade500, Colors.green.shade700];
    } else {
      return [Colors.blue.shade500, Colors.blue.shade700];
    }
  }
}
