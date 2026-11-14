import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../login_styles.dart';

/// 🌟 Header thương hiệu SketchTale
class LoginHeaderBrand extends StatelessWidget {
  const LoginHeaderBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/sketchtale-widget.png',
            width: 64,
            height: 64,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.onPrimary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Image.asset(
            'assets/images/sketchtale-wordmark.png',
            width: 148,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(
              'SketchTale',
              style: AppTypography.displayHero(color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: LoginStyles.kickerDecoration,
            child: Text(
              'MỖI NGÀY, MỘT CÂU CHUYỆN',
              style: AppTypography.labelSm(color: const Color(0xFF946000)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Mở trang sách nhỏ.\nChạm thế giới lớn.',
            textAlign: TextAlign.center,
            style: AppTypography.headlineLg(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Một trang sách mới đang chờ bố mẹ và bé.\nCùng đọc, cùng cười, cùng lớn lên.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

