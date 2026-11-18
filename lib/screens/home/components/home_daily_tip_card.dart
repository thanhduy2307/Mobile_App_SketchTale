import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../home_styles.dart';

///  Thẻ Mẹo Gia Đình: 10 Phút Bên Nhau
class HomeDailyTipCard extends StatelessWidget {
  const HomeDailyTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: HomeStyles.tipCardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/seed.webp',
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primaryDark,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '10 PHÚT BÊN NHAU',
                  style: AppTypography.labelSm(color: AppColors.primaryDark),
                ),
                const SizedBox(height: 2),
                Text(
                  'Một câu hỏi nhỏ, một cuộc trò chuyện hay.',
                  style: AppTypography.headlineSm(color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sau khi đọc, thử hỏi bé: "Con thích nhân vật nào nhất? Vì sao?"',
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

