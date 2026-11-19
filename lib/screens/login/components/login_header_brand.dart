import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';
import '../login_styles.dart';

/// Header thuong hieu SketchTale tu dong thich ung cho ca Dien thoai va iPad
class LoginHeaderBrand extends StatelessWidget {
  const LoginHeaderBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final logoWidth = Responsive.value<double>(
      context,
      mobile: 200.0,
      tablet: 290.0,
      desktop: 300.0,
    );
    final spacing = Responsive.value<double>(
      context,
      mobile: 8.0,
      tablet: 14.0,
    );

    return Center(
      child: Column(
        children: [
          // Khung huy hieu vien vang phat sang nhe giup logo noi bat 100% tren nen tranh
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 18 : 26,
              vertical: isMobile ? 8 : 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFFFCD34D),
                width: 2.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(0, 6),
                  blurRadius: 18,
                ),
                BoxShadow(
                  color: Color(0x35F59E0B),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/sketchtale-wordmark.png',
              width: logoWidth,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Text(
                'SketchTale',
                style: isMobile
                    ? AppTypography.displayHero(color: AppColors.onSurface).copyWith(fontSize: 28)
                    : AppTypography.displayHero(color: AppColors.onSurface).copyWith(fontSize: 34),
              ),
            ),
          ),
          SizedBox(height: spacing),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 18 : 22,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 1.2,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Mở trang sách nhỏ. Chạm thế giới lớn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 13.5 : 16.0,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF92400E),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

