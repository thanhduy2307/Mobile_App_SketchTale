import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../quiz_reward_styles.dart';

/// 💡 Thẻ gợi ý từ bạn Gấu đồng hành
class QuizHintCard extends StatelessWidget {
  final QuizQuestion quiz;
  final bool showHint;
  final VoidCallback onToggleHint;

  const QuizHintCard({
    super.key,
    required this.quiz,
    required this.showHint,
    required this.onToggleHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF93CCFF),
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.lightbulb_outline_rounded, size: 22, color: AppColors.onSurface)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gợi Ý Của Gấu Pô', style: AppTypography.labelSm(color: AppColors.secondary)),
                    Text(
                      quiz.hintText,
                      style: AppTypography.bodySm(color: AppColors.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onToggleHint,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 2),
                    Text('Mở Thêm', style: AppTypography.labelSm(color: AppColors.secondary)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Expanded Explanation Card
        if (showHint && quiz.explanation.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: QuizRewardStyles.hintCardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GIẢI THÍCH CHI TIẾT',
                  style: AppTypography.labelSm(color: AppColors.secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  quiz.explanation,
                  style: AppTypography.bodySm(color: const Color(0xFF0369A1)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

