import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/constants/questions.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/test_result.dart';
import 'package:khuta/screens/child/assessment/assessment_screen.dart';

class ChildDetailsScreen extends StatefulWidget {
  final Child child;

  const ChildDetailsScreen({super.key, required this.child});

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(widget.child.name),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: HomeScreenTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color:
                            (widget.child.gender == 'male'
                                    ? HomeScreenTheme.accentBlue(isDark)
                                    : HomeScreenTheme.accentPink(isDark))
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        widget.child.gender == 'male' ? Icons.boy : Icons.girl,
                        size: 50,
                        color: widget.child.gender == 'male'
                            ? HomeScreenTheme.accentBlue(isDark)
                            : HomeScreenTheme.accentPink(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.child.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          color: HomeScreenTheme.secondaryText(isDark),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.child.age} ${'years_old'.tr()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: HomeScreenTheme.secondaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.child.gender == 'male'
                              ? Icons.male
                              : Icons.female,
                          color: HomeScreenTheme.secondaryText(isDark),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.child.gender.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: HomeScreenTheme.secondaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                    if (widget.child.testResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black12 : Colors.grey[50])!,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'test_summary'.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: HomeScreenTheme.primaryText(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  Icons.assignment_turned_in,
                                  widget.child.testResults.length.toString(),
                                  'total_tests'.tr(),
                                  HomeScreenTheme.accentBlue(isDark),
                                  isDark,
                                ),
                                _buildStatItem(
                                  context,
                                  Icons.trending_up,
                                  '${_calculateAverageScore().toStringAsFixed(1)}%',
                                  'average_score'.tr(),
                                  HomeScreenTheme.getScoreColor(
                                    _calculateAverageScore(),
                                    isDark,
                                  ),
                                  isDark,
                                ),
                                _buildStatItem(
                                  context,
                                  Icons.calendar_today,
                                  DateFormat.MMMd().format(
                                    widget.child.testResults.last.date,
                                  ),
                                  'last_test'.tr(),
                                  HomeScreenTheme.secondaryText(isDark),
                                  isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Assessment Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: HomeScreenTheme.cardBackground(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: HomeScreenTheme.accentBlue(
                              isDark,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.psychology,
                            color: HomeScreenTheme.accentBlue(isDark),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'assessment_title'.tr(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: HomeScreenTheme.primaryText(isDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'assessment_subtitle'.tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: HomeScreenTheme.secondaryText(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Parent Assessment Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentScreen(
                                child: widget.child,
                                questions: parentQuestions,
                              ),
                            ),
                          );
                        },
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
                            const Icon(Icons.family_restroom, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'parent_assessment'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentScreen(
                                questions: teacherQuestions,
                                child: widget.child,
                              ),
                            ),
                          );
                        },
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
                            const Icon(Icons.class_, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'teacher_assessment'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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

              // Previous Tests Section
              if (widget.child.testResults.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: HomeScreenTheme.cardBackground(isDark),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [HomeScreenTheme.cardShadow(isDark)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: HomeScreenTheme.accentGreen(
                                isDark,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.history,
                              color: HomeScreenTheme.accentGreen(isDark),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'previous_tests'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: HomeScreenTheme.primaryText(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...widget.child.testResults.map(
                        (test) => _buildTestResultCard(test, isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestResultCard(TestResult test, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black12 : const Color(0xFFF7FAFC)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.testType.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HomeScreenTheme.primaryText(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(test.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: HomeScreenTheme.secondaryText(isDark),
                  ),
                ),
                if (test.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    test.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: HomeScreenTheme.secondaryText(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: HomeScreenTheme.getScoreColor(
                test.score,
                isDark,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${test.score.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: HomeScreenTheme.getScoreColor(test.score, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: HomeScreenTheme.primaryText(isDark),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: HomeScreenTheme.secondaryText(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  double _calculateAverageScore() {
    if (widget.child.testResults.isEmpty) return 0;
    final sum = widget.child.testResults.fold(
      0.0,
      (sum, test) => sum + test.score,
    );
    return sum / widget.child.testResults.length;
  }
}
