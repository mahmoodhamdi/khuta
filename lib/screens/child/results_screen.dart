import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/core/utils/accessibility_utils.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/models/question.dart';
import 'package:khuta/screens/main_screen.dart';
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
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              (route) => false,
            ),
            tooltip: 'exit_assessment'.tr(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Results Header with T-Score
              Semantics(
                label: AccessibilityUtils.getScoreAccessibilityLabel(score.toDouble()),
                child: Container(
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
                              Semantics(
                                excludeSemantics: true,
                                child: Icon(
                                  _getScoreIcon(score.toInt()),
                                  size: constraints.maxWidth * 0.08,
                                  color: Colors.white,
                                ),
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
                          const SizedBox(height: 8),
                          // Text label for score severity (accessibility)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AccessibilityUtils.getScoreSeverityText(score.toDouble()),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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
        debugPrint('Arabic font not found, using default font');
      }

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          textDirection:
              EasyLocalization.of(context)?.currentLocale?.languageCode == 'ar'
              ? pw.TextDirection.rtl
              : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (pw.Context context) {
            return [
              // Header with enhanced design
              pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [
                      _getPDFScoreColor(score),
                      _getPDFScoreColor(score).shade(0.8),
                    ],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                  borderRadius: pw.BorderRadius.circular(15),
                  boxShadow: [
                    pw.BoxShadow(
                      color: PdfColors.grey300,
                      offset: const PdfPoint(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(25),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'assessment_results'.tr(),
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: pw.BoxDecoration(color: PdfColors.white),
                        child: pw.Text(
                          '${'child_name'.tr()}: ${child.name}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: _getPDFScoreColor(
                              score,
                            ), // Enhanced: Use score color instead of white
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white.shade(
                            0.9,
                          ), // Enhanced: Semi-transparent white background
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          '${'date'.tr()}: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight:
                                pw.FontWeight.bold, // Enhanced: Medium weight
                            color: PdfColors
                                .grey800, // Enhanced: Dark grey instead of white
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              // Score Section with enhanced design
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(
                    color: _getPDFScoreColor(score),
                    width: 2,
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                  boxShadow: [
                    pw.BoxShadow(
                      color: PdfColors.grey200,
                      offset: const PdfPoint(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 30,
                          color: _getPDFScoreColor(score),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Text(
                          'score_interpretation'.tr(),
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: _getPDFScoreColor(score).shade(0.1),
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(
                          color: _getPDFScoreColor(score),
                          width: 1,
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'T-Score:',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.Text(
                            '${score.toInt()}',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: _getPDFScoreColor(score),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      interpretation.tr(),
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                        lineSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // Questions and Answers Section with enhanced design
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 30,
                          color: PdfColors.blue600,
                        ),
                        pw.SizedBox(width: 12),
                        pw.Text(
                          'questions_and_answers'.tr(),
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                  ],
                ),
              ),

              ...List.generate(questions.length, (index) {
                final question = questions[index];
                final answer = answers[index];
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  decoration: pw.BoxDecoration(
                    color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey200),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(15),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${index + 1}. ${question.questionText.tr()}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                            lineSpacing: 1.3,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: pw.BoxDecoration(
                            color: _getAnswerColor(answer),
                            borderRadius: pw.BorderRadius.circular(15),
                          ),
                          child: pw.Text(
                            '${'answer'.tr()}: ${_getAnswerText(answer)}',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              pw.SizedBox(height: 25),

              // Recommendations Section with enhanced design
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 4,
                          height: 30,
                          color: PdfColors.green600,
                        ),
                        pw.SizedBox(width: 12),
                        pw.Text(
                          'recommendations'.tr(),
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                  ],
                ),
              ),

              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Column(
                  children: recommendations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rec = entry.value;
                    return pw.Container(
                      margin: pw.EdgeInsets.only(
                        bottom: index < recommendations.length - 1 ? 15 : 0,
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 24,
                            height: 24,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green600,
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '${index + 1}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: pw.Text(
                              _cleanRecommendation(rec.tr()),
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey800,
                                lineSpacing: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ];
          },
        ),
      );

      // Use app-specific private directory instead of temp for security
      final output = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${output.path}/reports');

      // Create reports directory if it doesn't exist
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      // Clean up old reports (older than 24 hours)
      await _cleanupOldReports(pdfDir);

      // Sanitize child name for filename to prevent path traversal
      final sanitizedName = _sanitizeFileName(child.name);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'assessment_${sanitizedName}_$timestamp.pdf';

      final file = File('${pdfDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Share the PDF
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '${'assessment_results_for'.tr()} ${child.name}',
          subject: 'assessment_results'.tr(),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_generating_pdf'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error generating PDF: $e');
    }
  }

  /// Sanitizes a filename by removing special characters
  /// Prevents path traversal attacks and invalid filename characters
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Cleans up old PDF reports older than 24 hours
  Future<void> _cleanupOldReports(Directory pdfDir) async {
    try {
      if (await pdfDir.exists()) {
        final files = pdfDir.listSync();
        final now = DateTime.now();

        for (var file in files) {
          if (file is File && file.path.endsWith('.pdf')) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);

            // Delete files older than 24 hours
            if (age.inHours > 24) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old reports: $e');
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

  // Helper method to get answer color based on response
  PdfColor _getAnswerColor(int answer) {
    switch (answer) {
      case 0:
        return PdfColors.green600;
      case 1:
        return PdfColors.lightGreen600;
      case 2:
        return PdfColors.yellow600;
      case 3:
        return PdfColors.orange600;
      case 4:
        return PdfColors.red600;
      default:
        return PdfColors.grey500;
    }
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
