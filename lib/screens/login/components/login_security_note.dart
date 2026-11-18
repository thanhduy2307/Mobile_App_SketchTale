import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../login_styles.dart';

/// Dai ghi chu an toan cho be
class LoginSecurityNote extends StatelessWidget {
  const LoginSecurityNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: LoginStyles.securityBadgeDecoration,
      child: Text(
        'Đồng hành cùng bé • Giới hạn thời gian sử dụng an toàn',
        style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
    );
  }
}

