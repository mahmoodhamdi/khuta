import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

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
          // PDF Share Button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResultsAsPDF(context),
            tooltip: 'share_results'.tr(),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getScoreIcon(score.toInt()),
                              size: constraints.maxWidth * 0.08,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: AutoSizeText(
                                interpretation.tr(),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                minFontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AutoSizeText(
                          'T-Score: ${score.toInt()}',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
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
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'recommendations'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HomeScreenTheme.primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: recommendations
                          .map(
                            (rec) => Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: HomeScreenTheme.backgroundColor(isDark),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: HomeScreenTheme.accentBlue(
                                    isDark,
                                  ).withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 22,
                                    color: HomeScreenTheme.accentBlue(isDark),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _cleanRecommendation(rec.tr()),
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: HomeScreenTheme.secondaryText(
                                          isDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
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

  // PDF Generation and Sharing Method
  Future<void> _shareResultsAsPDF(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final pdf = pw.Document();

      // Load Arabic font if needed
      pw.Font? arabicFont;
      try {
        final fontData = await rootBundle.load(
          'assets/fonts/NotoSansArabic-Regular.ttf',
        );
        arabicFont = pw.Font.ttf(fontData);
      } catch (e) {
        // Fallback to default font if Arabic font not available
        print('Arabic font not found, using default font');
      }

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection:
              EasyLocalization.of(context)?.currentLocale?.languageCode == 'ar'
              ? pw.TextDirection.rtl
              : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: _getPDFScoreColor(score),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'assessment_results'.tr(),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '${'child_name'.tr()}: ${child.name}',
                      style: const pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      '${'date'.tr()}: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Score Section
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'score_interpretation'.tr(),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'T-Score: ${score.toInt()}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _getPDFScoreColor(score),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      interpretation.tr(),
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Questions and Answers Section
              pw.Text(
                'questions_and_answers'.tr(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              ...List.generate(questions.length, (index) {
                final question = questions[index];
                final answer = answers[index];
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${index + 1}. ${question.questionText.tr()}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${'answer'.tr()}: ${_getAnswerText(answer)}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 20),

              // Recommendations Section
              pw.Text(
                'recommendations'.tr(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              ...recommendations.map(
                (rec) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                      pw.Expanded(
                        child: pw.Text(
                          _cleanRecommendation(rec.tr()),
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Center(
                child: pw.Text(
                  '${'generated_on'.tr()} ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF to temporary directory
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/assessment_results_${child.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Close loading dialog
      Navigator.pop(context);

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${'assessment_results_for'.tr()} ${child.name}',
        subject: 'assessment_results'.tr(),
      );
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_generating_pdf'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to get answer text
  String _getAnswerText(int answer) {
    switch (answer) {
      case 0:
        return 'never'.tr();
      case 1:
        return 'rarely'.tr();
      case 2:
        return 'sometimes'.tr();
      case 3:
        return 'often'.tr();
      case 4:
        return 'always'.tr();
      default:
        return 'unknown'.tr();
    }
  }

  // Helper method to get PDF color based on score
  PdfColor _getPDFScoreColor(int tScore) {
    if (tScore >= 70) return PdfColors.red700;
    if (tScore >= 65) return PdfColors.orange700;
    if (tScore >= 60) return PdfColors.yellow700;
    if (tScore >= 45) return PdfColors.green500;
    return PdfColors.blue500;
  }

  String _cleanRecommendation(String input) {
    return input
        .replaceAll(RegExp(r'^[\*\-\•]\s*'), '')
        .replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*'),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(RegExp(r'__(.*?)__'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '')
        .replaceAllMapped(RegExp(r'_(.*?)_'), (match) => match.group(1) ?? '');
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
