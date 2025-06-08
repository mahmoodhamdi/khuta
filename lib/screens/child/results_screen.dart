import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';

class ResultsScreen extends StatelessWidget {
  final Child child;
  final int score;
  final List<String> recommendations;
  final List<int> answers;
  final List<Question> questions;
  final String interpretation;

  const ResultsScreen({
    super.key,
    required this.recommendations,
    required this.child,
    required this.score,
    required this.answers,
    required this.questions,
    required this.interpretation,
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
                          interpretation.tr(),
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
                    ...recommendations.map(
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
