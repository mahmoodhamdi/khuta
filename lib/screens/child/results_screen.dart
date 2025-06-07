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
              // Results Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      HomeScreenTheme.getScoreColor(score, isDark),
                      HomeScreenTheme.getScoreColor(
                        score,
                        isDark,
                      ).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: HomeScreenTheme.getScoreColor(
                        score,
                        isDark,
                      ).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getScoreIcon(score),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getScoreTitle(score),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Score Interpretation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HomeScreenTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: HomeScreenTheme.accentBlue(
                              isDark,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: HomeScreenTheme.accentBlue(isDark),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'interpretation'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HomeScreenTheme.primaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getScoreInterpretation(score),
                      style: TextStyle(
                        fontSize: 14,
                        color: HomeScreenTheme.secondaryText(isDark),
                        height: 1.6,
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
                  boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: HomeScreenTheme.accentGreen(
                              isDark,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: HomeScreenTheme.accentGreen(isDark),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'recommendations'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HomeScreenTheme.primaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._getRecommendations(score).map(
                      (recommendation) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: HomeScreenTheme.accentGreen(isDark),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: HomeScreenTheme.secondaryText(isDark),
                                  height: 1.5,
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

              const SizedBox(height: 24),

              // Question Review
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HomeScreenTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: HomeScreenTheme.accentOrange(
                              isDark,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.quiz_outlined,
                            color: HomeScreenTheme.accentOrange(isDark),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'question_review'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HomeScreenTheme.primaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...questions.asMap().entries.map((entry) {
                      int index = entry.key;
                      Question question = entry.value;
                      int answerIndex = answers[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black12
                              : const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'question'.tr()} ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: HomeScreenTheme.accentBlue(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr(question.questionText),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: HomeScreenTheme.primaryText(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getAnswerColor(
                                  answerIndex,
                                  isDark,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                answerIndex >= 0 &&
                                        answerIndex < question.options.length
                                    ? question.options[answerIndex]
                                    : 'no_answer'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getAnswerColor(answerIndex, isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        foregroundColor: HomeScreenTheme.primaryText(isDark),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text('back_to_home'.tr()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _shareResults(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HomeScreenTheme.accentBlue(isDark),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share, size: 18),
                          const SizedBox(width: 8),
                          Text('share_results'.tr()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    if (score >= 40) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreTitle(double score) {
    if (score >= 80) return 'excellent_performance'.tr();
    if (score >= 60) return 'good_performance'.tr();
    if (score >= 40) return 'moderate_performance'.tr();
    return 'needs_attention'.tr();
  }

  String _getScoreInterpretation(double score) {
    if (score >= 80) {
      return 'high_score_interpretation'.tr();
    } else if (score >= 60) {
      return 'moderate_score_interpretation'.tr();
    } else if (score >= 40) {
      return 'low_score_interpretation'.tr();
    } else {
      return 'very_low_score_interpretation'.tr();
    }
  }

  List<String> _getRecommendations(double score) {
    if (score >= 80) {
      return [
        'continue_current_activities'.tr(),
        'maintain_routine_activities'.tr(),
        'regular_follow_up'.tr(),
      ];
    } else if (score >= 60) {
      return [
        'increase_social_activities'.tr(),
        'work_on_communication_skills'.tr(),
        'consult_specialist_if_needed'.tr(),
        'create_structured_routine'.tr(),
      ];
    } else if (score >= 40) {
      return [
        'seek_professional_evaluation'.tr(),
        'consider_therapy_programs'.tr(),
        'focus_on_social_skills_development'.tr(),
        'create_supportive_environment'.tr(),
      ];
    } else {
      return [
        'immediate_professional_consultation'.tr(),
        'comprehensive_evaluation_needed'.tr(),
        'consider_intensive_intervention'.tr(),
        'family_support_programs'.tr(),
      ];
    }
  }

  Color _getAnswerColor(int answerIndex, bool isDark) {
    switch (answerIndex) {
      case 0:
        return HomeScreenTheme.accentRed(isDark);
      case 1:
        return HomeScreenTheme.accentOrange(isDark);
      case 2:
        return isDark ? const Color(0xFFF6E05E) : const Color(0xFFECC94B);
      case 3:
        return HomeScreenTheme.accentGreen(isDark);
      default:
        return HomeScreenTheme.secondaryText(isDark);
    }
  }

  void _shareResults(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('results_saved_successfully'.tr()),
        backgroundColor: HomeScreenTheme.accentGreen(isDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
