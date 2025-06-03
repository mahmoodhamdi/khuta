import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class QuestionText extends StatelessWidget {
  final String text;
  final bool isRTL;

  const QuestionText({super.key, required this.text, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
       tr(text),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
          height: 1.5,
        ),
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}
