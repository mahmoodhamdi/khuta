import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/models/test_result.dart';

import 'results_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final Child child;

  const AssessmentScreen({super.key, required this.child});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Question> questions = [];
  List<int> answers = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      // Load sample questions - في التطبيق الحقيقي ستحمل من Firebase
      setState(() {
        questions = _getSampleQuestions();
        answers = List.filled(questions.length, -1);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<Question> _getSampleQuestions() {
    return [
      Question(
        id: '1',
        imageUrl:
            'https://via.placeholder.com/300x200/4299E1/FFFFFF?text=Question+1',
        questionText: 'How often does your child engage in social activities?',
        questionTextLocalized: {
          'en': 'How often does your child engage in social activities?',
          'ar': 'كم مرة ينخرط طفلك في الأنشطة الاجتماعية؟',
        },
        options: ['never'.tr(), 'rarely'.tr(), 'sometimes'.tr(), 'often'.tr()],
      ),
      Question(
        id: '2',
        imageUrl:
            'https://via.placeholder.com/300x200/48BB78/FFFFFF?text=Question+2',
        questionText:
            'Does your child maintain eye contact during conversations?',
        questionTextLocalized: {
          'en': 'Does your child maintain eye contact during conversations?',
          'ar': 'هل يحافظ طفلك على التواصل البصري أثناء المحادثات؟',
        },
        options: ['never'.tr(), 'rarely'.tr(), 'sometimes'.tr(), 'often'.tr()],
      ),
      Question(
        id: '3',
        imageUrl:
            'https://via.placeholder.com/300x200/ED64A6/FFFFFF?text=Question+3',
        questionText: 'How does your child respond to changes in routine?',
        questionTextLocalized: {
          'en': 'How does your child respond to changes in routine?',
          'ar': 'كيف يتجاوب طفلك مع التغييرات في الروتين؟',
        },
        options: ['never'.tr(), 'rarely'.tr(), 'sometimes'.tr(), 'often'.tr()],
      ),
    ];
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      answers[currentQuestionIndex] = optionIndex;
    });
  }

  Future<void> _showResults() async {
    // حساب النتيجة
    double totalScore = 0;
    int answeredQuestions = 0;

    for (int i = 0; i < answers.length; i++) {
      if (answers[i] != -1) {
        totalScore += (answers[i] + 1) * 25; // كل إجابة من 25 إلى 100
        answeredQuestions++;
      }
    }

    double finalScore = answeredQuestions > 0
        ? totalScore / answeredQuestions
        : 0;

    // حفظ النتيجة في Firebase
    await _saveTestResult(finalScore);

    // الانتقال لصفحة النتائج
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            child: widget.child,
            score: finalScore,
            answers: answers,
            questions: questions,
          ),
        ),
      );
    }
  }

  Future<void> _saveTestResult(double score) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final testResult = TestResult(
        testType: 'autism_assessment'.tr(),
        score: score,
        date: DateTime.now(),
        notes: _getScoreInterpretation(score),
      );

      // إضافة النتيجة لقائمة نتائج الطفل
      widget.child.testResults.add(testResult);

      // تحديث البيانات في Firebase
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .doc(widget.child.id)
          .update({
            'testResults': widget.child.testResults
                .map((e) => e.toMap())
                .toList(),
          });
    } catch (e) {
      debugPrint('Error saving test result: $e');
    }
  }

  String _getScoreInterpretation(double score) {
    if (score >= 80) return 'high_functionality'.tr();
    if (score >= 60) return 'moderate_functionality'.tr();
    if (score >= 40) return 'low_functionality'.tr();
    return 'very_low_functionality'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text('assessment'.tr()),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D3748),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('error_loading_questions'.tr()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('assessment'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
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
                        '${currentQuestionIndex + 1} / ${questions.length}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4299E1),
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
            ),

            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Question Image
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          currentQuestion.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(
                                0xFF4299E1,
                              ).withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Color(0xFF4299E1),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question Text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        currentQuestion.questionTextLocalized[context
                                .locale
                                .languageCode] ??
                            currentQuestion.questionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                          height: 1.5,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer Options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      int index = entry.key;
                      String option = entry.value;
                      bool isSelected = answers[currentQuestionIndex] == index;

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(
                                        0xFF4299E1,
                                      ).withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4299E1)
                                      : Colors.grey.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF4299E1)
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? const Color(0xFF4299E1)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF4299E1)
                                            : const Color(0xFF2D3748),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  if (currentQuestionIndex > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _previousQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: const Color(0xFF2D3748),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isRTL ? Icons.arrow_forward : Icons.arrow_back,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text('previous'.tr()),
                          ],
                        ),
                      ),
                    ),

                  if (currentQuestionIndex > 0) const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: answers[currentQuestionIndex] != -1
                          ? _nextQuestion
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4299E1),
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
                          Text(
                            currentQuestionIndex == questions.length - 1
                                ? 'show_results'.tr()
                                : 'next'.tr(),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            currentQuestionIndex == questions.length - 1
                                ? Icons.check
                                : isRTL
                                ? Icons.arrow_back
                                : Icons.arrow_forward,
                            size: 20,
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
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('exit_assessment'.tr()),
        content: Text('exit_assessment_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('continue'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('exit'.tr()),
          ),
        ],
      ),
    );
  }
}
