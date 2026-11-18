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
      mobile: 195.0,
      tablet: 240.0,
      desktop: 255.0,
    );
    final spacing = Responsive.value<double>(
      context,
      mobile: 10.0,
      tablet: 14.0,
    );

    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/sketchtale-wordmark.png',
            width: logoWidth,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(
              'SketchTale',
              style: isMobile
                  ? AppTypography.displayHero(color: AppColors.onSurface).copyWith(fontSize: 28)
                  : AppTypography.displayHero(color: AppColors.onSurface),
            ),
          ),
          SizedBox(height: spacing),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Mở trang sách nhỏ. Chạm thế giới lớn.',
              textAlign: TextAlign.center,
              style: isMobile
                  ? AppTypography.headlineSm(color: AppColors.onSurface).copyWith(fontSize: 15)
                  : AppTypography.headlineSm(color: AppColors.onSurface).copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

