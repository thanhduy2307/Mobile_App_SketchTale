import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// 🏷️ Header gọn & Bộ chuyển chế độ vẽ (Vẽ tay vs Chụp tranh giấy)
class DrawingModeSelector extends StatelessWidget {
  final int activeDrawMode;
  final int parentCredits;
  final int remainingLimit;
  final ValueChanged<int> onModeChanged;
  final VoidCallback onCameraTap;

  const DrawingModeSelector({
    super.key,
    required this.activeDrawMode,
    required this.parentCredits,
    required this.remainingLimit,
    required this.onModeChanged,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A001050),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/rabbit.webp',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.palette_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Không Gian Sáng Tạo',
                    style: AppTypography.headlineSm(
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Vẽ tranh & tạo hình nhân vật',
                    style: AppTypography.labelSm(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFFCD34D),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'Còn $remainingLimit lượt tạo hôm nay',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Mode Toggle (Vẽ Tay vs Chụp Ảnh)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: AppColors.outline,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onModeChanged(0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: activeDrawMode == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Vẽ tay',
                      style: AppTypography.labelSm(
                        color: activeDrawMode == 0
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    onModeChanged(1);
                    onCameraTap();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: activeDrawMode == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 15,
                          color: activeDrawMode == 1
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tải ảnh lên',
                          style: AppTypography.labelSm(
                            color: activeDrawMode == 1
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

