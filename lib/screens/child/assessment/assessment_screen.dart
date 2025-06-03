import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/screens/child/assessment/controllers/assessment_controller.dart';
import 'package:khuta/screens/child/assessment/widgets/answer_option.dart';
import 'package:khuta/screens/child/assessment/widgets/navigation_buttons.dart';
import 'package:khuta/screens/child/assessment/widgets/progress_bar.dart';
import 'package:khuta/screens/child/assessment/widgets/question_image.dart';
import 'package:khuta/screens/child/assessment/widgets/question_text.dart';

class AssessmentScreen extends StatefulWidget {
  final Child child;

  const AssessmentScreen({super.key, required this.child});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  List<Question> questions = [];
  List<int> answers = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  String? error;
  late AssessmentController _controller;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    try {
      setState(() {
        questions = _getSampleQuestions();
        answers = List.filled(questions.length, -1);
        isLoading = false;
      });

      _controller = AssessmentController(
        context: context,
        child: widget.child,
        questions: questions,
        answers: answers,
        onQuestionChanged: (index) =>
            setState(() => currentQuestionIndex = index),
        onAnswersChanged: (newAnswers) => setState(() => answers = newAnswers),
      );
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
      return _buildErrorScreen();
    }

    return WillPopScope(
      onWillPop: _controller.showExitConfirmation,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(isRTL),
        body: SafeArea(
          child: Column(
            children: [
              AssessmentProgressBar(
                currentQuestionIndex: currentQuestionIndex,
                totalQuestions: questions.length,
              ),
              Expanded(child: _buildQuestionContent(isRTL)),
              NavigationButtons(
                onPrevious: () =>
                    _controller.previousQuestion(currentQuestionIndex),
                onNext: () => _controller.nextQuestion(currentQuestionIndex),
                isFirstQuestion: currentQuestionIndex == 0,
                isLastQuestion: currentQuestionIndex == questions.length - 1,
                canProceed: answers[currentQuestionIndex] != -1,
                isRTL: isRTL,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isRTL) {
    return AppBar(
      title: Text('assessment'.tr()),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF2D3748),
      elevation: 0,
      leading: IconButton(
        icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
        onPressed: _controller.showExitConfirmation,
      ),
    );
  }

  Widget _buildErrorScreen() {
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

  Widget _buildQuestionContent(bool isRTL) {
    final currentQuestion = questions[currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          QuestionImage(imageUrl: currentQuestion.imageUrl),
          const SizedBox(height: 24),
          QuestionText(
            text:
                currentQuestion.questionTextLocalized[context
                    .locale
                    .languageCode] ??
                currentQuestion.questionText,
            isRTL: isRTL,
          ),
          const SizedBox(height: 24),
          ...currentQuestion.options.asMap().entries.map(
            (entry) => AnswerOption(
              option: entry.value,
              isSelected: answers[currentQuestionIndex] == entry.key,
              onTap: () =>
                  _controller.selectAnswer(currentQuestionIndex, entry.key),
            ),
          ),
        ],
      ),
    );
  }
}
