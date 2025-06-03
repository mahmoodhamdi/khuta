import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AssessmentProgressBar extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;

  const AssessmentProgressBar({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentQuestionIndex + 1) / totalQuestions;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'question'.tr()} ${currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '${currentQuestionIndex + 1} / $totalQuestions',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4299E1)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
