import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Top Action Bar for Story Player: Back, Title, Progress Dots, Bilingual Switch, Report
class StoryHeaderBar extends StatelessWidget {
  final String title;
  final int currentPageIndex;
  final int totalPages;
  final ValueChanged<int> onPageDotTap;
  final bool showEnglish;
  final VoidCallback onToggleEnglish;
  final VoidCallback onReportTap;
  final VoidCallback onBackPressed;
  final bool showAnimationStudio;
  final VoidCallback? onToggleAnimationStudio;
  final VoidCallback? onRolesTap;
  final bool showRolesButton;
  final bool showLanguageSwitch;

  const StoryHeaderBar({
    super.key,
    required this.title,
    required this.currentPageIndex,
    required this.totalPages,
    required this.onPageDotTap,
    required this.showEnglish,
    required this.onToggleEnglish,
    required this.onReportTap,
    required this.onBackPressed,
    this.showAnimationStudio = false,
    this.onToggleAnimationStudio,
    this.onRolesTap,
    this.showRolesButton = false,
    this.showLanguageSwitch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          // Nút quay lại (Thư Viện)
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.outline, width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08001050),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text('Thư viện', style: AppTypography.labelSm(color: AppColors.secondary)),
                ],
              ),
            ),
          ),

          // Tiêu đề truyện & Điểm đánh dấu trang
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineSm(color: AppColors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < (totalPages > 0 ? totalPages : 1); i++)
                        GestureDetector(
                          onTap: () => onPageDotTap(i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: (i == currentPageIndex) ? 14 : 7,
                            height: 6,
                            decoration: BoxDecoration(
                              color: (i < currentPageIndex)
                                  ? AppColors.secondary
                                  : (i == currentPageIndex)
                                      ? AppColors.primaryContainer
                                      : AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        '${currentPageIndex + 1}/${totalPages > 0 ? totalPages : 1}',
                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nhóm nút tiện ích bên phải: Nhân vật của bé, VI/EN, Báo Cáo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Thêm / Đổi nhân vật của bé vào truyện (mặc định ẩn)
              if (showRolesButton && onRolesTap != null) ...[
                GestureDetector(
                  onTap: onRolesTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: const Color(0xFFFCD34D), width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.theater_comedy_rounded, size: 14, color: Color(0xFF92400E)),
                        const SizedBox(width: 4),
                        Text(
                          'Nhân vật',
                          style: AppTypography.labelSm(
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Nút song ngữ VI / EN (mặc định ẩn)
              if (showLanguageSwitch) ...[
                GestureDetector(
                  onTap: onToggleEnglish,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: showEnglish
                          ? AppColors.secondaryFixedDim.withValues(alpha: 0.6)
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFCFDAF2),
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.translate_rounded, color: AppColors.secondary, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          showEnglish ? 'EN' : 'VI',
                          style: AppTypography.labelSm(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Nút Báo cáo an toàn nội dung (Shield)
              GestureDetector(
                onTap: onReportTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECEB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFD5D2),
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.shield_rounded, color: AppColors.error, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
