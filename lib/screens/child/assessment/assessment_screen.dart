import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
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
  final List<Question> questions;
  const AssessmentScreen({
    super.key,
    required this.questions,
    required this.child,
  });

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
    questions = widget.questions;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
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

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: HomeScreenTheme.backgroundColor(isDark),
        body: Center(
          child: CircularProgressIndicator(
            color: HomeScreenTheme.accentBlue(isDark),
          ),
        ),
      );
    }

    if (error != null) {
      return _buildErrorScreen();
    }

    return WillPopScope(
      onWillPop: _controller.showExitConfirmation,
      child: Scaffold(
        backgroundColor: HomeScreenTheme.backgroundColor(isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text('assessment'.tr()),
      backgroundColor: HomeScreenTheme.cardBackground(isDark),
      foregroundColor: HomeScreenTheme.primaryText(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
        onPressed: _controller.showExitConfirmation,
      ),
    );
  }

  Widget _buildErrorScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text('assessment'.tr()),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: HomeScreenTheme.accentRed(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'error_loading_questions'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: HomeScreenTheme.primaryText(isDark),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadQuestions(),
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreenTheme.accentBlue(isDark),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
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
          QuestionText(text: currentQuestion.questionText, isRTL: isRTL),
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
