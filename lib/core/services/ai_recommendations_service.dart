import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/models/question.dart';

class AiRecommendationsService {
  static final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
  );
  static String _formatPrompt(
    List<Question> questions,
    List<int> answers,
    int tScore,
  ) {
    final List<String> promptBuilder = [
      'فيما يلي نتائج تقييم مقياس كونرز لتقييم أعراض اضطراب فرط الحركة ونقص الانتباه (ADHD) لدى طفل، حيث تُظهر كل إجابة تقييم المعلم أو الوالد.',
      '',
    ];

    for (int i = 0; i < questions.length; i++) {
      if (answers[i] >= 0) {
        promptBuilder.add(
          'السؤال ${i + 1}: ${questions[i].questionText}\nالإجابة: ${_translateAnswer(answers[i])}',
        );
      }
    }

    promptBuilder.addAll([
      '',
      'بناءً على هذه النتائج، قدم نصائح محددة لاستراتيجيات أو تدخلات يمكن أن تساعد الطفل. قدم النصائح في شكل قائمة نقطية.',
    ]);

    return promptBuilder.join('\n');
  }

  static String _translateAnswer(int answer) {
    switch (answer) {
      case 0:
        return "never".tr();
      case 1:
        return "rarely".tr();
      case 2:
        return "sometimes".tr();
      case 3:
        return "often".tr();

      default:
        return 'Not Answered';
    }
  }

  static Future<List<String>> getRecommendations(
    int s,
    List<Question> questions,
    List<int> answers,
  ) async {
    try {

      final prompt = [Content.text(_formatPrompt(questions, answers, s))];
      debugPrint('Prompt: ${prompt[0].parts[0].toString()}');
      final response = await model.generateContent(prompt);


      if (response.text == null || response.text!.isEmpty) {
        return _getFallbackRecommendations( tScore: s);
      }

      // Split the response into individual recommendations
      final recommendations = response.text!
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();

      return recommendations.isEmpty
          ? _getFallbackRecommendations()
          : recommendations;
    } catch (e) {
      debugPrint('Error generating AI recommendations: $e');
      return _getFallbackRecommendations();
    }
  }

  static List<String> _getFallbackRecommendations( {int tScore = 0}) {
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
