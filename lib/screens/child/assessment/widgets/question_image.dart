import 'package:flutter/material.dart';

class QuestionImage extends StatelessWidget {
  final String imageUrl;

  const QuestionImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF4299E1).withValues(alpha: 0.1),
              child: const Icon(
                Icons.image,
                size: 50,
                color: Color(0xFF4299E1),
              ),
            );
          },
        ),
      ),
    );
  }
}
