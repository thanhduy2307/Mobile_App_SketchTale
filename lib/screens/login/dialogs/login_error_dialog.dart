import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// ❌ Pop-up báo lỗi khi đăng nhập không thành công
class LoginErrorDialog extends StatelessWidget {
  final String errorMessage;

  const LoginErrorDialog({super.key, required this.errorMessage});

  static Future<void> show(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (_) => LoginErrorDialog(errorMessage: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied_rounded,
                color: AppColors.error,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Đăng Nhập Thất Bại',
              style: AppTypography.headlineSm(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Thử Lại',
                  style: AppTypography.labelMd(color: AppColors.onPrimaryContainer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

