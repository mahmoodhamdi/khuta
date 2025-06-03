import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isFirstQuestion;
  final bool isLastQuestion;
  final bool canProceed;
  final bool isRTL;

  const NavigationButtons({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.isFirstQuestion,
    required this.isLastQuestion,
    required this.canProceed,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          if (!isFirstQuestion)
            Expanded(
              child: ElevatedButton(
                onPressed: onPrevious,
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

          if (!isFirstQuestion) const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed: canProceed ? onNext : null,
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
                  Text(isLastQuestion ? 'show_results'.tr() : 'next'.tr()),
                  const SizedBox(width: 8),
                  Icon(
                    isLastQuestion
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
    );
  }
}
