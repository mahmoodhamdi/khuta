import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/models/question.dart';

class AiRecommendationsService {
  static final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
  );

  // Detect language based on question content
  static String _detectLanguage(List<Question> questions) {
    if (questions.isEmpty) return 'en';

    // Check if first question contains Arabic characters
    final firstQuestion = questions[0].questionText;
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');

    return arabicRegex.hasMatch(firstQuestion) ? 'ar' : 'en';
  }

  static String _formatPrompt(
    List<Question> questions,
    List<int> answers,
    int tScore,
    int? childAge,
    String? childGender,
  ) {
    final language = _detectLanguage(questions);
    final isArabic = language == 'ar';

    List<String> promptBuilder = [];

    // Add intro based on language
    if (isArabic) {
      promptBuilder.addAll([
        'تم تقييم طفل باستخدام مقياس كونرز لأعراض اضطراب فرط الحركة ونقص الانتباه (ADHD).',
        childAge != null ? 'عمر الطفل: $childAge سنة' : '',
        childGender != null ? 'جنس الطفل: $childGender' : '',
        'النتيجة الإجمالية: $tScore',
        '',
        'الأسئلة والإجابات:',
      ]);
    } else {
      promptBuilder.addAll([
        'A child has been assessed using the Conners Scale for ADHD symptoms.',
        childAge != null ? 'Child age: $childAge years' : '',
        childGender != null ? 'Child gender: $childGender' : '',
        'Total score: $tScore',
        '',
        'Questions and answers:',
      ]);
    }

    // Add questions and answers
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] >= 0) {
        promptBuilder.add(
          '${i + 1}. ${questions[i].questionText} - ${_translateAnswer(answers[i])}',
        );
      }
    }

    // Add instructions based on language
    if (isArabic) {
      promptBuilder.addAll([
        '',
        'المطلوب: قائمة توصيات مباشرة فقط (5-8 توصيات) بدون أي مقدمات أو كلمات مثل "بناءً على" أو "بالتأكيد" أو "مختصر بسيط".',
        'اكتب التوصيات مباشرة بصيغة الأمر باللغة العربية:',
        '• التوصية الأولى',
        '• التوصية الثانية',
        'وهكذا...',
      ]);
    } else {
      promptBuilder.addAll([
        '',
        'Required: Direct recommendations list only (5-8 recommendations) without any introductions or words like "based on", "certainly", or "brief summary".',
        'Write recommendations directly in imperative form in English:',
        '• First recommendation',
        '• Second recommendation',
        'And so on...',
      ]);
    }

    return promptBuilder.where((line) => line.isNotEmpty).join('\n');
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
    int tScore,
    List<Question> questions,
    List<int> answers, {
    int? childAge,
    String? childGender,
  }) async {
    try {
      final prompt = [
        Content.text(
          _formatPrompt(questions, answers, tScore, childAge, childGender),
        ),
      ];

      debugPrint('Prompt: ${prompt[0].parts[0].toString()}');
      final response = await model.generateContent(prompt);

      if (response.text == null || response.text!.isEmpty) {
        return _getFallbackRecommendations(
          tScore: tScore,
          language: _detectLanguage(questions),
        );
      }

      // Parse the response to extract recommendations
      final responseText = response.text!;
      final recommendations = _parseRecommendations(responseText);

      return recommendations.isEmpty
          ? _getFallbackRecommendations(
              tScore: tScore,
              language: _detectLanguage(questions),
            )
          : recommendations;
    } catch (e) {
      debugPrint('Error generating AI recommendations: $e');
      return _getFallbackRecommendations(
        tScore: tScore,
        language: _detectLanguage(questions),
      );
    }
  }

  static List<String> _parseRecommendations(String responseText) {
    final recommendations = <String>[];
    final lines = responseText.split('\n');

    for (String line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines
      if (trimmedLine.isEmpty) continue;

      // Skip introductory phrases in Arabic
      if (trimmedLine.contains('بناءً على') ||
          trimmedLine.contains('بالتأكيد') ||
          trimmedLine.contains('مختصر') ||
          trimmedLine.contains('التوصيات') ||
          trimmedLine.contains('النتائج') ||
          trimmedLine.contains('التحليل')) {
        continue;
      }

      // Skip introductory phrases in English
      if (trimmedLine.toLowerCase().contains('based on') ||
          trimmedLine.toLowerCase().contains('certainly') ||
          trimmedLine.toLowerCase().contains('summary') ||
          trimmedLine.toLowerCase().contains('recommendations') ||
          trimmedLine.toLowerCase().contains('analysis')) {
        continue;
      }

      // Extract bullet points or numbered items
      if (trimmedLine.startsWith('•') ||
          trimmedLine.startsWith('-') ||
          RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
        // Clean up the recommendation text
        String recommendation = trimmedLine
            .replaceFirst(RegExp(r'^[•\-\d\.]+\s*'), '')
            .trim();

        if (recommendation.isNotEmpty && recommendation.length > 5) {
          recommendations.add(recommendation);
        }
      }
    }

    return recommendations;
  }

  static List<String> _getFallbackRecommendations({
    int tScore = 0,
    String language = 'en',
  }) {
    final isArabic = language == 'ar';

    if (tScore >= 70) {
      return isArabic
          ? [
              'استشارة فورية مع أخصائي نفسي أو طبيب نفسي',
              'إجراء تقييم شامل لاضطراب فرط الحركة ونقص الانتباه',
              'وضع خطة دعم متكاملة في المنزل والمدرسة',
              'مراقبة منتظمة للسلوك والأعراض',
              'التنسيق بين الأهل والمعلمين',
              'النظر في التدخلات السلوكية المكثفة',
            ]
          : [
              'Immediate consultation with psychologist or psychiatrist',
              'Comprehensive ADHD evaluation needed',
              'Create integrated support plan for home and school',
              'Regular monitoring of behavior and symptoms',
              'Coordinate between parents and teachers',
              'Consider intensive behavioral interventions',
            ];
    } else if (tScore >= 65) {
      return isArabic
          ? [
              'استشارة مع أخصائي نفسي أو تربوي',
              'وضع خطة تدخل سلوكي',
              'تحسين التنسيق بين الأهل والمعلمين',
              'متابعة دورية للتقدم',
              'تطبيق استراتيجيات الدعم في البيئات المختلفة',
            ]
          : [
              'Consultation with psychologist or educational specialist',
              'Develop behavioral intervention plan',
              'Improve parent-teacher coordination',
              'Regular follow-up for progress',
              'Implement support strategies across environments',
            ];
    } else if (tScore >= 60) {
      return isArabic
          ? [
              'مراقبة السلوك عن كثب',
              'النظر في استشارة مهنية',
              'تطبيق استراتيجيات الدعم',
              'تقييم منتظم للوضع',
              'تعزيز السلوكيات الإيجابية',
            ]
          : [
              'Monitor behavior closely',
              'Consider professional consultation',
              'Implement support strategies',
              'Regular assessment of situation',
              'Reinforce positive behaviors',
            ];
    } else if (tScore >= 45) {
      return isArabic
          ? [
              'مواصلة الدعم الحالي',
              'المراقبة المنتظمة',
              'التعزيز الإيجابي',
              'الأنشطة المناسبة للعمر',
              'التشجيع المستمر',
            ]
          : [
              'Continue current support',
              'Maintain regular monitoring',
              'Positive reinforcement',
              'Age-appropriate activities',
              'Ongoing encouragement',
            ];
    } else {
      return isArabic
          ? [
              'المحافظة على الاستراتيجيات الحالية',
              'تشجيع السلوكيات الإيجابية',
              'مراقبة النمو العادي',
              'المشاركة المناسبة للعمر',
            ]
          : [
              'Maintain current strategies',
              'Encourage positive behaviors',
              'Regular development monitoring',
              'Age-appropriate engagement',
            ];
    }
  }
}
